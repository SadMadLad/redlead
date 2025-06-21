require "faraday"

Faraday.default_connection_options = Faraday::ConnectionOptions.new({ timeout: 10000 })
