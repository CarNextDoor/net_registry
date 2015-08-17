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
      success = false
      params  = process_params(params)
      case params[:COMMAND]
      when "purchase"
        @response.text, success = validate_purchase_params(params)
      when "refund"
        @response.text, success = validate_refund_params(params)
      when "preauth"
        @response.text, success = validate_preauth_params(params)
      when "status"
        @response.text, success = validate_status_params(params)
      when "completion"
        @response.text, success = validate_completion_params(params)
      else
        @response.text = "Invalid command. Only [purchase status preauth refund completion] are valid."
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
    # return builder itself.
    # To get the response object, use #create method
    def parse(response)
      raise TypeError, "Response is not a string" if !response.is_a?(String)
      @full_response = response.split("\n").map(&:strip)
      if @full_response.first == "failed"
        parse_failed_response
      else
        @full_response.each do |line|
          data  = line.split("=")
          parse_success_line(key: data[0], value: data[1])
        end
        @receipt = @full_response.drop_while { |line| !line.include?("Reciept follows") }
        if @receipt.include?("Reciept follows")
          # Don't want the "Reciept follows" line, nor the "." and "done" line.
          # Only want the receipt in between
          @receipt = @receipt[1...-2]
          @response.transaction.receipt = @receipt.join("\n")
        end
      end

      self
    end

    protected
    def parse_failed_response
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
    end

    def parse_success_line(key:, value:)
      case key
      when "card_number", "card_no"
        @response.transaction.card.number = value
      when "response_text"
        @response.text = value
      when "response_code"
        @response.code = value
      when "status"
        @response.status = value
      when "result"
        @response.result = value
      when "amount", "total_amount"
        @response.transaction.amount = value
      when "time"
        @response.transaction.time = value
      when "command"
        @response.transaction.command = value
      when "txnref", "txn_ref"
        @response.transaction.reference = value
      when "transaction_no"
        @response.transaction.number = value
      when "bank_ref"
        @response.transaction.bank_reference = value
      when "settlement_date"
        @response.transaction.settlement_date = value
      when "rrn"
        @response.transaction.rrn = value
      when "MID"
        @response.transaction.merchant_id = value
      when "card_type"
        @response.transaction.card.type = value
      when "card_expiry"
        @response.transaction.card.expiry = value
      when "card_desc"
        @response.transaction.card.description = value
      when "comment"
        @response.transaction.comment = value
      end
    end

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

    def validate_completion_params(params)
      if params[:PREAUTHNUM].nil? || params[:PREAUTHNUM].empty?
        return "PREAUTHNUM not found", false
      elsif params[:CCNUM].nil? || params[:CCNUM].empty?
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
