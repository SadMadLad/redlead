class ApplicationClient
  attr_reader :client

  PROXY_LIST = [
    ["95.129.101.73", 80],
    ["86.180.158.25", 8080],
    ["141.147.150.58", 3128],
    ["112.199.40.53", 8080],
    ["103.129.201.35", 8080],
    ["206.189.140.195", 3128],
    ["5.61.62.24", 8118],
    ["193.247.213.70", 8080]
  ].freeze

  protected
    def random_proxy_url
      ip, port = PROXY_LIST.sample

      "http://#{ip}:#{port}"
    end
end
