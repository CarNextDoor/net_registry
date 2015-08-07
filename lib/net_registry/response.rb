module NetRegistry
  class Response
    attr_accessor :text, :status, :full_response
    attr_reader   :code

    def initialize(text: "Unknown Error", code: -1, status: "failed")
      @text, @code, @status = text, code, status
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

  end
end
