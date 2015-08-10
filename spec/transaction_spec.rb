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

require "spec_helper"

RSpec.describe NetRegistry::Transaction do
  let(:transaction) { NetRegistry::Transaction.new }
  let(:card)        { NetRegistry::Card.new        }

  describe "#card" do
    it "assigns card object" do
      transaction.card = card
      expect(transaction.card).to eq(card)
    end

    it "assigns incorrect card object" do
      expect { transaction.card = "Hello yo"}.to raise_error(TypeError)
    end
  end

  describe "#settlement_date" do
    it "assigns settlement_date" do
      date = "31/07/00"
      expect(transaction.settlement_date).to be_nil
      transaction.settlement_date = date
      expect(transaction.settlement_date).to eq(date)
    end
  end

  describe "#amount" do
    it "assigns amount" do
      amount = "100.0"
      expect(transaction.amount).to be_nil
      transaction.amount = amount
      expect(transaction.amount).to eq(amount)
    end
  end

  describe "#reference" do
    it "assigns reference" do
      reference = "0007311428202312"
      expect(transaction.reference).to be_nil
      transaction.reference= reference
      expect(transaction.reference).to eq(reference)
    end
  end

  describe "#bank_reference" do
    it "assigns bank_reference" do
      reference = "0007311428202312"
      expect(transaction.bank_reference).to be_nil
      transaction.bank_reference = reference
      expect(transaction.bank_reference).to eq(reference)
    end
  end

  describe "#command" do
    it "assigns command" do
      command = "purchase"
      expect(transaction.command).to be_nil
      transaction.command = command
      expect(transaction.command).to eq(command)
    end
  end

  describe "#time" do
    it "assigns time" do
      time = "2000­07­31 14:28:20"
      expect(transaction.time).to be_nil
      transaction.time = time
      expect(transaction.time).to eq(time)
    end
  end


end
