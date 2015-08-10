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

RSpec.describe NetRegistry::Card do
  let(:card) { NetRegistry::Card.new }
  describe "#number" do
    it "assigns number" do
      number = "111111111111"
      expect(card.number).to be_nil
      card.number = number
      expect(card.number).to eq(number)
    end
  end

  describe "#description" do
    it "assigns description" do
      desc = "VISA"
      expect(card.description).to be_nil
      card.description= desc
      expect(card.description).to eq(desc)
    end
  end

  describe "#expiry" do
    it "assigns expiry" do
      expiry = "10/15"
      expect(card.expiry).to be_nil
      card.expiry = expiry
      expect(card.expiry).to eq(expiry)
    end
  end

  describe "#ccv" do
    it "assigns CCV" do
      ccv = "935"
      expect(card.ccv).to be_nil
      card.ccv = ccv
      expect(card.ccv).to eq(ccv)
    end
  end

  describe "#type" do
    it "assigns type" do
      type = "9"
      expect(card.type).to be_nil
      card.type = type
      expect(card.type).to eq(type)
    end
  end
end
