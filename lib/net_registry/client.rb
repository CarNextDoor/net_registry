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

    def command(params = {})
      raise TypeError            if !params.is_a?(Hash)
      raise CommandNotFoundError if !commands.include?(params[:COMMAND])
      params.merge!(LOGIN: @LOGIN, COMMAND: params[:COMMAND])
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
