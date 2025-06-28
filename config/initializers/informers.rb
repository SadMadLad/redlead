Rails.application.config.after_initialize do
  INFORMER_GTE = Informers.pipeline("embedding", "Supabase/gte-small")

  RANKING_JINA = Informers.pipeline("reranking", "jinaai/jina-reranker-v1-turbo-en")
end
