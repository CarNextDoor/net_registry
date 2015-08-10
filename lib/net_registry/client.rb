require "net/http"

module NetRegistry
  class Client

    attr_accessor :merchant_id, :password, :base_url, :factory, :url, :login

    def initialize(merchant_id: ENV["NET_REGISTRY_MERCHANT"], password: ENV["NET_REGISTRY_PASSWORD"])
      @merchant_id, @password = merchant_id, password

      @login    = "#{@merchant_id}/#{@password}"
      @base_url = "https://paygate.ssllock.net/external2.pl"
      @uri      = URI(@base_url)
      @factory  = NetRegistry::ResponseBuilder.new
    end

    # Alias for
    # request(COMMAND: "purchase", AMOUNT: 100 ... etc)
    def purchase(params = {})
      raise TypeError, "params is not a hash" if !params.is_a?(Hash)
      request(params.merge!(COMMAND: "purchase"))
    end

    # Alias for
    # request(COMMAND: "refund", AMOUNT: 100 ... etc)
    def refund(params = {})
      raise TypeError, "params is not a hash" if !params.is_a?(Hash)
      request(params.merge!(COMMAND: "refund"))
    end

    # Alias for
    # request(COMMAND: "status", AMOUNT: 100 ... etc)
    def status(params = {})
      raise TypeError, "params is not a hash" if !params.is_a?(Hash)
      request(params.merge!(COMMAND: "status"))
    end

    # Alias for
    # request(COMMAND: "preauth", AMOUNT: 100 ... etc)
    def preauth(params = {})
      raise TypeError, "params is not a hash" if !params.is_a?(Hash)
      request(params.merge!(COMMAND: "preauth"))
    end

    def request(params = {})
      raise TypeError, "params is not a hash" if !params.is_a?(Hash)
      params.merge!(LOGIN: @login)
      @factory.verify_params(params) ? send_request(params) : @factory.create
    end

    private

    def send_request(params)
      res = Net::HTTP.post_form(@uri, params)
      @factory.parse(res.body).create
    end

  end
end
