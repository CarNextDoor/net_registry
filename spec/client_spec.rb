require "spec_helper"

RSpec.describe NetRegistry::Client do
  let(:username) { "username" }
  let(:password) { "password" }
  let(:client)   { NetRegistry::Client.new(username, password) }
  let(:params)   do
    {
      amount:     100.0,
      card_number: 111111111111,
      card_expiry: "10/15",
    }
  end

  describe "#initialize" do
    it { expect(client.merchant).to eq(username) }
    it { expect(client.password).to eq(password) }
  end

  describe "#purchase" do
    context "parameter is a hash" do
      it { expect { client.purchase(params) }.not_to raise_error }
    end

    context "parameter is anything but a hash" do
      it { expect { client.purchase(1) }.to raise_error(TypeError) }
    end
  end

  describe "#refund" do

  end

  describe "#status" do

  end

  describe "#preauth" do

  end
end
