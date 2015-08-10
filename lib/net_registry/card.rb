module NetRegistry
  class Card
    attr_accessor :number,
                  :description,
                  :expiry,
                  :ccv,
                  :type

    def initialize(number: nil, description: nil, expiry: nil, ccv: nil, type: nil)
      @number      = number
      @description = description
      @expiry      = expiry
      @ccv         = ccv
      @type        = type
    end

  end
end
