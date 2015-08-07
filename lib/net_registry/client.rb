require "net/http"

module NetRegistry
  class Client

    attr_accessor :merchant, :password, :base_url, :factory, :url

    def initialize(merchant = ENV["NET_REGISTRY_MERCHANT"], password = ENV["NET_REGISTRY_PASSWORD"])
      @merchant, @password = merchant, password

      @LOGIN    = "#{@merchant}/#{@password}"
      @base_url = "https://paygate.ssllock.net/external2.pl"
      @uri      = URI(@base_url)
      @factory  = NetRegistry::ResponseFactory.new
    end

    def purchase(params = {})
      raise TypeError, "params is not a hash" if !params.is_a?(Hash)
      request(params.merge!(COMMAND: "purchase"))
    end

    def refund(params = {})
      raise TypeError, "params is not a hash" if !params.is_a?(Hash)
      request(params.merge!(COMMAND: "refund"))
    end

    def status(params = {})
      raise TypeError, "params is not a hash" if !params.is_a?(Hash)
      request(params.merge!(COMMAND: "status"))
    end

    def preauth(params = {})
      raise TypeError, "params is not a hash" if !params.is_a?(Hash)
      request(params.merge!(COMMAND: "preauth"))
    end

    def request(params = {})
      raise TypeError, "params is not a hash" if !params.is_a?(Hash)
      params.merge!(LOGIN: @LOGIN)
      @factory.verify_params(params) ? send_request(params) : @factory.create
    end

    private

    def send_request(params)
      res = Net::HTTP.post_form(@uri, params)
      @factory.parse(res.body).create
    end

    def commands
      @commands = ["purchase", "status", "preauth", "refund"]
    end

  end
end
