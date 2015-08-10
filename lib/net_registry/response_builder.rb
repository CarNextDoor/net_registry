require 'date'

module NetRegistry
  class ResponseBuilder

    attr_reader :response

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
      @response.result = 0  if success
      @response.status = "" if success

      @response.success?
    end

    def create
      @response
    end

    # parse HTTP request response body into a response object
    # return factory itself.
    # To get the response object, use #create method
    def parse(response)
      raise TypeError, "Response is not a string" if !response.is_a?(String)
      @full_response = response.split("\n").map(&:strip)
      if @full_response.first == "failed"
        # remove all spaces until the dot
        lines = @full_response.drop_while { |x| x != "." }
        if lines.empty?
          @response.text = @full_response[1]
        else
          lines.shift
          lines[0].slice!("response_text=")
          @response.text = lines[0]
        end
        @response.status = "failed"
        @response.code   = -1
      else
        @full_response.each do |line|
          data = line.split("=")
          case data.first
          when "card_number", "card_no"
            @response.transaction.card.number = data[1]
          when "response_text"
            @response.text = data[1].to_s
          when "amount", "total_amount"
            @response.transaction.amount = data[1]
          when "status"
            @response.status = data[1]
          when "txnref", "txn_ref"
            @response.transaction.reference = data[1]
          when "transaction_no"
            @response.transaction.number = data[1]
          when "bank_ref"
            @response.transaction.bank_reference = data[1]
          when "card_desc"
            @response.transaction.card.description = data[1]
          when "response_code"
            @response.code = data[1]
          when "card_type"
            @response.transaction.card.type = data[1]
          when "time"
            @response.transaction.time = data[1]
          when "command"
            @response.transaction.command = data[1]
          when "card_expiry"
            @response.transaction.card.expiry = data[1]
          when "result"
            @response.result = data[1]
          when "settlement_date"
            @response.transaction.settlement_date = data[1]
          when "rrn"
            @response.transaction.rrn = data[1]
          when "MID"
            @response.transaction.merchant_id = data[1]
          else
          end
        end
        @receipt = @full_response.drop_while { |line| !line.include?("Reciept follows") }
        if @receipt.include?("Reciept follows")
          @receipt = @receipt[1...-2]
          @response.transaction.receipt = @receipt.join("\n")
        end
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
        return "CCNUM not found", false
      elsif params[:CCEXP].nil? || params[:CCEXP].empty?
        return "CCEXP not found", false
      elsif !valid_expiry_format?(params[:CCEXP])
        return "CCEXP invalid format", false
      elsif params[:AMOUNT].nil? || params[:AMOUNT].empty?
        return "AMOUNT not found", false
      else
        return "", true
      end
    end

    def validate_status_params(params)
      if params[:TXNREF].nil? || params[:TXNREF].empty?
        return "TXNREF not found", false
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
