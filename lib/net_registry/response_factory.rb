module NetRegistry
  class ResponseFactory

    # Parameters:
    # command (String): Denotes which action we're taking.
    #                   Only accepts the following actions:
    #                   purchase, refund, preauth, status.
    # params (Hash):    Variables to pass to NetRegistry
    def self.create(command, **params)
      response = NetRegistry::Response.new
      success  = false
      case command
      when "purchase"
        response.text, success = validate_purchase_params(params)
      when "refund"
        response.text, success = validate_refund_params(params)
      when "preauth"
        response.text, success = validate_preauth_params(params)
      when "status"
        response.text, success = validate_status_params(params)
      else
        nil
      end
      response.code   = 0  if success
      response.status = "" if success

      response
    end

    private
    def initialize; end

    protected
    # Preliminary validation for the purchase method
    # Returns a Response Object
    def self.validate_purchase_params(params)
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

    def self.validate_refund_params(params)
      if params[:AMOUNT].nil? || params[:AMOUNT].empty?
        return "AMOUNT not found", false
      elsif params[:TXNREF].nil? || params[:TXNREF].empty?
        return "TXNREF not found", false
      else
        return "", true
      end
    end

    def self.validate_preauth_params(params)
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

    def self.validate_status_params(params)
      if params[:TXNREF].nil? || params[:TXNREF].empty?
        return "Missing transaction reference", false
      else
        return "", true
      end
    end


    def self.valid_expiry_format?(card_expiry)
      raise TypeError if !card_expiry.is_a?(String)
      begin
        Date.parse(card_expiry)
        !NetRegistry::Helpers::EXPIRY_REGEX.match(card_expiry).nil?
      rescue ArgumentError
        false
      end
    end
  end

end
