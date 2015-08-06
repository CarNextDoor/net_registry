module NetRegistry
  class Response
    attr_accessor :text, :code, :status, :full_response

    def initialize(response = "")
      # Defaults to failed response
      @text   = "Unknown Error"
      @code   = -1
      @status = "failed"
      parse(response)
    end

    def failed?
      @code == -1 ||
        (!@full_response.nil? && @full_response.first == "failed")
    end

    def success?
      !failed?
    end

  end
end
