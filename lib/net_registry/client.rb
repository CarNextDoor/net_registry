# Copyright (c) 2015 Car Next Door
# Author: Ray Tung
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require "net/http"

module NetRegistry
  class Client

    attr_accessor :merchant_id, :password, :base_url, :factory, :url, :login

    def initialize(merchant_id: ENV["NET_REGISTRY_MERCHANT"], password: ENV["NET_REGISTRY_PASSWORD"])
      @merchant_id, @password = merchant_id, password

      @login    = "#{@merchant_id}/#{@password}"
      @base_url = "https://paygate.ssllock.net/external2.pl"
      @uri      = URI(@base_url)
      @builder  = NetRegistry::ResponseBuilder.new
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

    # Alias for
    # require(COMMAND: "completion", PREAUTHNUM: .... etc)
    def completion(params = {})
      raise TypeError, "params is not a hash" if !params.is_a?(Hash)
      request(params.merge!(COMMAND: "completion"))
    end

    def request(params = {})
      raise TypeError, "params is not a hash" if !params.is_a?(Hash)
      params.merge!(LOGIN: @login)
      @builder.verify_params(params) ? send_request(params) : @builder.create
    end

    private

    def send_request(params)
      res = Net::HTTP.post_form(@uri, params)
      @builder.parse(res.body).create
    end

  end
end
