require 'date'

module NetRegistry
  class ResponseFactory

    attr_accessor :response

    def initialize
      @response = NetRegistry::Response.new
    end

    # command (String): Denotes which action we're taking.
    #                   Only accepts the following actions:
    #                   purchase, refund, preauth, status.
    # params (Hash):    Variables to pass to NetRegistry
    def verify_params(params = {})
      success  = false
      params = process_params(params)
      case params[:COMMAND]
      when "purchase"
        @response.text, success = validate_purchase_params(params)
      when "refund"
        @response.text, success = validate_refund_params(params)
      when "preauth"
        @response.text, success = validate_preauth_params(params)
      when "status"
        @response.text, success = validate_status_params(params)
      else
        @response.text = "Invalid command. Only [purchase status preauth refund] are valid."
        success        = false
      end
      @response.code   = 0  if success
      @response.status = "" if success

      @response.success?
    end

    def create
      @response
    end

    def parse(response)
      raise TypeError, "Response is not a string" if !response.is_a?(String)
      @full_response = response.split("\n").map(&:strip)
      if @full_response.first == "failed"
        @text   = @full_response.second
        @status = "failed"
        @code   = -1
      end

      lines = @full_response.drop_while do |x|
        x != "Reciept follows"
      end

      self
    end

    protected
    # Preliminary validation for the purchase method
    # Returns a Response Object
    def validate_purchase_params(params)
      if params[:AMOUNT].nil?   || params[:AMOUNT].empty?
        return "AMOUNT not found", false
      elsif params[:CCNUM].nil? || params[:CCNUM].empty?
        return "CCNUM not found", false
      elsif params[:CCEXP].nil? || params[:CCEXP].empty?
        return "CCEXP not found", false
      elsif !valid_expiry_format?(params[:CCEXP])
        return "CCEXP invalid format", false
      else
        return "", true
      end
    end

    def validate_refund_params(params)
      if params[:AMOUNT].nil? || params[:AMOUNT].empty?
        return "AMOUNT not found", false
      elsif params[:TXNREF].nil? || params[:TXNREF].empty?
        return "TXNREF not found", false
      else
        return "", true
      end
    end

    def validate_preauth_params(params)
      if params[:CCNUM].nil? || params[:CCNUM].empty?
        return "Missing Credit Card Number", false
      elsif params[:CCEXP].nil? || params[:CCEXP].empty?
        return "Missing transaction reference", false
      elsif params[:AMOUNT].nil? || params[:AMOUNT].empty?
        return "Missing amount", false
      else
        return "", true
      end
    end

    def validate_status_params(params)
      if params[:TXNREF].nil? || params[:TXNREF].empty?
        return "Missing transaction reference", false
      else
        return "", true
      end
    end


    def valid_expiry_format?(card_expiry)
      raise TypeError if !card_expiry.is_a?(String)
      begin
        Date.parse(card_expiry)
        !NetRegistry::Helpers::EXPIRY_REGEX.match(card_expiry).nil?
      rescue ArgumentError
        false
      end
    end

    # Pre-process parameters. In this instance, pre-process
    # all parameters into strings, for easy params validation
    def process_params(params)
      params.each { |key, value| params[key] = value.to_s }
    end
  end

end
