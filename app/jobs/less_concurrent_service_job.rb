class LessConcurrentServiceJob < CallServiceJob
  limits_concurrency to: 5, key: :concurrency, duration: 15.seconds
end
