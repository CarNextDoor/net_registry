module NetRegistry
  class Transaction
    attr_accessor :settlement_date,
                  :amount,
                  :reference,
                  :bank_reference,
                  :command,
                  :time,
                  :number,
                  :rrn,
                  :merchant_id,
                  :receipt

    def card=(card)
      raise TypeError, "Invalid class" if !card.is_a? NetRegistry::Card
      @card = card
    end

    def card
      @card ||= NetRegistry::Card.new
    end

  end
end
