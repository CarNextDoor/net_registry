require "net_registry/version"
require "net/http"

module NetRegistry
  attr_accessor :merchant, :password

  class Client
    def initialize(merchant, password)
      @merchant, @password = merchant, password
    end

    def purchase(amount, card_number, card_expiry, ccv = nil, comment = "")
      uri = base_uri
      res = Net::HTTP.post_form(uri, "COMMAND" => "purchase",
                                     "AMOUNT"  => amount,
                                     "CCNUM"   => card_number,
                                     "CCEXP"   => card_expiry,
                                     "COMMENT" => comment)
    end

    def refund(txn_ref, amount, comment = "")
      uri = base_uri
      res = Net::HTTP.post_form(uri, "COMMAND" => "refund",
                                     "AMOUNT"  => amount,
                                     "TXNREF"  => txn_ref)
    end

    def status(txn_ref)
      uri = base_uri
      res = Net::HTTP.post_form(uri, "TXNREF"  => txn_ref)
    end

    def preauth(card_number, card_expiry, amount, ccv = nil, comment = "")
      uri = base_uri
      res = Net::HTTP.post_form(uri, "COMMAND" => "preauth",
                                     "AMOUNT"  => amount,
                                     "CCNUM"   => card_number,
                                     "TXNREF"  => txn_ref,
                                     "COMMENT" => comment)
    end

    private
    def base_uri
      "https://paygate.ssllock.net/external2.pl?/LOGIN=#{merchant}/#{password}"
    end
  end
end
