class LeadService < ApplicationService
  SERVICE_QUERIES = {
    best_tool:       { text: "What is the best tool for {business}?", method: :singularize },
    top_services:    { text: "Top services for {business}?", method: :pluralize },
    platforms:       { text: "Which platforms are best for {business}?", method: :pluralize },
    alternatives:    { text: "Alternatives to popular platforms for {business}", method: :pluralize },
    which_to_use:    { text: "Which {business} tool should I use?", method: :singularize },
  }.freeze

  RECOMMENDATION_QUERIES = {
    best_place:      { text: "Best place to get {product}?", method: :pluralize },
    recommendations: { text: "Recommendations for {product}?", method: :pluralize },
    market:          { text: "What is the best place to find good {product}", method: :singularize }
  }.freeze

  required_params :products, :business

  def call
    [business_leads, products_leads]
  end

  private
    def business_leads
      recommendations = SERVICE_QUERIES.values.map do |query_prefix|
        text, method = query_prefix.values_at(:text, :method)

        SubredditPost.recommendations text.sub("{business}", @business.title.downcase.public_send(method))
      end

      recommendations = recommendations.flatten.uniq

      InformerClient.new.rerank(
        :informer_jina,
        recommendations.flatten.uniq.map { |recommendation| "#{recommendation.title} #{recommendation.selftext}".strip },
        "People asking for services of a #{@business.title}"
      ).map do |v|
        record = recommendations[v[:doc_id]]
        record.ranking_score = v[:score]

        record
      end
    end

    def products_leads
      @products.zip(reranked_results_products).to_h
    end

    def semantic_posts_leads_products
      @products.map do |product|
        queries = RECOMMENDATION_QUERIES.values.map do |query_prefix|
          text, method = query_prefix.values_at(:text, :method)

          text.sub("{product}", product.title.downcase.public_send(method))
        end

        SubredditPost.multi_query_recommendations(queries)
      end
    end

    def reranked_results_products
      results = semantic_posts_leads_products.map { |leads| leads.flatten.uniq }

      ranked_results = @products.zip(results).map do |product, product_leads|
        InformerClient.new.rerank(
          :informer_jina,
          product_leads.map{ |lead| "#{lead.title} #{lead.selftext}".strip },
          "People asking for recommendations for #{product.title}."
        )
      end

      results.zip(ranked_results).map do |result, ranked_result|
        ranked_result.map do |v|
          record = result[v[:doc_id]]
          record.ranking_score = v[:score]

          record
        end
      end
    end
end
