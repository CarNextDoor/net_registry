module NetRegistry
  class Response
    attr_accessor :text, :status, :full_response, :transaction
    attr_reader   :code, :result

    def initialize(text: "Unknown Error", code: -1, status: "failed", result: -1)
      @text, @code, @status, @result = text, code, status, result
    end

    def failed?
      @code == -1 ||
        (!@full_response.nil? && @full_response.first == "failed")
    end

    def success?
      !failed?
    end

    def code=(code)
      @code = code.to_i
    end

    def result=(result)
      @result = result.to_i
    end

    def transaction=(transaction)
      raise TypeError, "Not NetRegistry::Transaction" if !transaction.is_a?(NetRegistry::Transaction)
      @transaction = transaction
    end

  end
end
