Rails.application.config.after_initialize do
  INFORMER_GTE = Informers.pipeline("embedding", "Supabase/gte-small")
  # INFORMER_MXBAI = Informers.pipeline("embedding", "mixedbread-ai/mxbai-embed-large-v1")
  # INFORMER_NOMIC = Informers.pipeline("embedding", "nomic-ai/nomic-embed-text-v1")
end
