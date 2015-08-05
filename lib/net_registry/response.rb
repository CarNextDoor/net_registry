module NetRegistry
  class Response
    attr_accessor :text, :code, :status

    def initialize(response = "")
      # Defaults to failed response
      @text   = "Unknown Error"
      @code   = -1
      @status = "failed"
      parse(response)
    end

    def parse(response)
      raise TypeError if !response.is_a?(String)
      @full_response = response.split("\n").map(&:strip)

      lines = @full_response.drop_while do |x|
        puts x
        x != "Reciept follows"
      end

      puts lines

      self
    end

    def failed?
      @code == -1 ||
        (!@full_response.nil? && @full_response.first == "failed")
    end

  end
end
