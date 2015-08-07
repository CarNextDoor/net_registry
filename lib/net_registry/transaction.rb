module NetRegistry
  class Transaction
    attr_accessor :settlement_date,
                  :amount,
                  :reference,
                  :bank_reference,
                  :command,
                  :time
    attr_reader   :card

    def card=(card)
      raise TypeError, "Invalid class" if !card.is_a? NetRegistry::Card
      @card = card
    end

  end
end
