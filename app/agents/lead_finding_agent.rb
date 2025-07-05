class LeadFindingAgent < ApplicationAgent
  attr_reader :embedding_agent

  SERVICE_QUERIES = {
    best_tool:       { text: "What is the best tool for {business}?", method: :singularize },
    top_services:    { text: "Top services for {business}?", method: :pluralize },
    platforms:       { text: "Which platforms are best for {business}?", method: :pluralize },
    alternatives:    { text: "Alternatives to popular platforms for {business}", method: :pluralize },
    which_to_use:    { text: "Which {business} tool should I use?", method: :singularize }
  }.freeze

  RECOMMENDATION_QUERIES = {
    best_place:      { text: "Best place to get {product}?", method: :pluralize },
    recommendations: { text: "Recommendations for {product}?", method: :pluralize },
    market:          { text: "What is the best place to find good {product}", method: :singularize }
  }.freeze

  provider :google
  model :gemini_20_flash
  prompt "You are an expert at identifying posts that signal high commercial intent.
    Rank the following Reddit posts/comments based on how likely a response could convert into a sale, lead, or business opportunity.
    Prioritize posts where a user is actively asking for recommendations, help, or discussing a pain point that a business could solve.
    ".squish
  google_schema type: "object",
    properties: {
      resources: {
        type: "array",
        description: "Rank-ordered list of subreddit posts or comments (most relevant first)",
        items: {
          type: "object",
          properties: {
            resource_id: {
              type: "string",
              description: "Reddit resource ID"
            },
            resource_type: {
              type: "string",
              description: "Indicates where the resource is the original post or a comment (if it has a selftext, it is a SubredditPost, else if it has a body, it is a SubredditPostComment)",
              enum: %w[ SubredditPost SubredditPostComment ]
            },
            score: {
              type: "number",
              description: "Relevance score - 0 (worst) to 10 (best)."
            }
          },
          required: %w[ resource_id resource_type score ]
        }
      }
    },
    required: %w[ resources ]

  def fetch_leads(business)
    @business = business
    @products = business.products
    @embedding_agent = GteEmbeddingAgent.new
    @business_embedding = @business.embeddings.find_by(embedding_model: :informer_gte)

    fetched_recommendations = fetch_recommendations.flatten.map(&:embeddable).uniq
    hashed_recommendations = fetched_recommendations.as_json(only: %i[ id title selftext body ])
    chunked_messages = chunkify_recommendations(hashed_recommendations)

    resources = complete_by_google(*chunked_messages, already_processed: true)
    process_resources(resources)
  rescue JSON::ParserError, Faraday::ConnectionError
    # Fallback if request to LLM fails
    process_by_reranking(fetched_recommendations)
  end

  private
    def fetch_recommendations
      [
        direct_business_recommendations,
        business_recommendations,
        products_recommendations
      ]
    end

    def chunkify_recommendations(recommendations)
      chunked_messages = Utils::Chunkifier.call(messages: recommendations, google: true, truncation: { selftext: 250, body: 250 })
      chunked_messages.unshift google_message(business_prompt)

      chunked_messages
    end

    def business_prompt
      full_prompt = "
        Business you are helping - here are the details of the business:
        Business Type #{@business.business_type}
        Description: #{@business.description}
        #{"Intelligent Summary: #{@business.intelligent_scraped_summary?}" if @business.intelligent_scraped_summary? }"

      full_prompt += "
        Products and their descriptions:
        #{products_prompt}" if @products.present?

      full_prompt.squeeze(" ").squeeze("\n").strip
    end

    def business_recommendations
      recommendations(SERVICE_QUERIES.values, "{business}", @business.business_type)
    end

    def direct_business_recommendations
      return [] if @business_embedding.blank?

      fetch_neighbors(@business_embedding.embedding)
    end

    def products_recommendations
      @products.map do |product|
        recommendations(RECOMMENDATION_QUERIES.values, "{product}", product.title)
      end
    end

    def recommendations(query_prefixes, to_replace, to_replace_with)
      query_prefixes.map do |query_prefix|
        text, method = query_prefix.values_at(:text, :method)

        prepared_query = text.sub(to_replace, to_replace_with.downcase.public_send(method))
        prepared_query = embedding_agent.embed(prepared_query)

        fetch_neighbors(prepared_query.first)
      end
    end

    def fetch_neighbors(query_embedding)
      limit = @products.present? ? 15 : 30

      Embedding
        .where(embeddable_type: %w[ SubredditPost SubredditPostComment ])
        .informer_gte
        .nearest_neighbors(:embedding, query_embedding, distance: "cosine")
        .limit(limit)
        .includes(:embeddable)
    end

    def process_resources(resources)
      resources = JSON.parse(resources)["resources"]
      recommended_posts, recommended_comments = resources
                                                  .group_by { |resource| resource["resource_type"] }
                                                  .values_at("SubredditPost", "SubredditPostComment")
                                                  .map { |resources| resources.pluck("resource_id") }

      recommended_posts = SubredditPost.where(id: recommended_posts)
      recommended_comments = SubredditPostComment.where(id: recommended_comments)

      lookup = {
        "SubredditPost" => recommended_posts.index_by(&:id),
        "SubredditPostComment" => recommended_comments.index_by(&:id)
      }

      resources.map do |r|
        record = lookup.dig(r["resource_type"], r["resource_id"].to_i)
        record.ranking_score = r["score"] if record.present?

        record
      end.compact
    end

    def process_by_reranking(fetched_recommendations)
      reranking_prompt = "People asking for recommendations for #{@business.business_type}"
      reranking_prompt += "Or People asking for #{products_prompt}" if @products.present?
      reranking_prompt = reranking_prompt.squeeze("\n").squeeze(" ").strip

      normalized_texts = fetched_recommendations.pluck(:title, :body, :selftext).map do |plucked_data|
        plucked_data.join("\n").squeeze("\n").squeeze(" ").strip
      end

      reranked_results = ApplicationAgent.quick_rerank(:informer, :jina, reranking_prompt, normalized_texts)
      reranked_results.map do |v|
        record = fetched_recommendations[v[:doc_id]]
        record.ranking_score = (v[:score] * 10).round(2)
        record
      end
    end

    def products_prompt
      return if @products.blank?

      @products.map do |product|
        "Title: #{product.title} - Description: #{product.description}"
      end.join("\n")
    end
end
