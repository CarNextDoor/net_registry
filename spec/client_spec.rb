require "spec_helper"

RSpec.describe NetRegistry::Client do
  let(:username) { "username" }
  let(:password) { "password" }
  let(:client)   { NetRegistry::Client.new(username, password) }
  let(:params)   do
    {
      AMOUNT: 100.0,
      CCNUM: 111111111111,
      CCEXP: "10/15",
      TXNREF: "DSF4oeriw0343"
    }
  end

  before do
    # stub_request(:post, "https://paygate.ssllock.net/external2.pl").to_return(status: 200, body: "", headers: {})
  end

  describe "#initialize" do
    it { expect(client.merchant).to eq(username) }
    it { expect(client.password).to eq(password) }
  end

  describe "#purchase" do
    context "parameter is a hash" do
      it { expect { client.purchase(params) }.not_to raise_error }
      it "has key :AMOUNT with nil as value" do
        response = client.purchase(params.merge!(AMOUNT: nil))
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("AMOUNT not found")
        expect(response.code).to   eq(-1)
        expect(response.status).to eq("failed")
      end

      it "has key :AMOUNT with empty string as value" do
        response = client.purchase(params.merge!(AMOUNT: ""))
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("AMOUNT not found")
        expect(response.code).to   eq(-1)
        expect(response.status).to eq("failed")
      end

      it "has key :AMOUNT with a non-empty value" do
        response = client.purchase(params)
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("")
        expect(response.code).to   eq(0)
        expect(response.status).to eq("")
      end

      it "has key :CCNUM with nil as value" do
        response = client.purchase(params.merge!(CCNUM: nil))
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("CCNUM not found")
        expect(response.code).to   eq(-1)
        expect(response.status).to eq("failed")
      end

      it "has key :CCNUM with empty string as value" do
        response = client.purchase(params.merge!(CCNUM: ""))
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("CCNUM not found")
        expect(response.code).to   eq(-1)
        expect(response.status).to eq("failed")
      end

      it "has key :CCNUM with a non-empty value" do
        response = client.purchase(params)
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("")
        expect(response.code).to   eq(0)
        expect(response.status).to eq("")
      end

    end

    context "parameter is anything but a hash" do
      it { expect { client.purchase(1) }.to raise_error(TypeError) }
    end
  end

  describe "#refund" do
    context "parameter is a hash" do
      it { expect { client.refund(params) }.not_to raise_error }
      it "has key :AMOUNT with nil as value" do
        response = client.refund(params.merge!(AMOUNT: nil))
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("AMOUNT not found")
        expect(response.code).to   eq(-1)
        expect(response.status).to eq("failed")
      end

      it "has key :AMOUNT with empty string as value" do
        response = client.refund(params.merge!(AMOUNT: ""))
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("AMOUNT not found")
        expect(response.code).to   eq(-1)
        expect(response.status).to eq("failed")
      end

      it "has key :AMOUNT with a non-empty value" do
        response = client.refund(params)
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("")
        expect(response.code).to   eq(0)
        expect(response.status).to eq("")
      end

      it "has key :TXNREF with nil as value" do
        response = client.refund(params.merge!(TXNREF: nil))
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("TXNREF not found")
        expect(response.code).to   eq(-1)
        expect(response.status).to eq("failed")
      end

      it "has key :TXNREF with empty string as value" do
        response = client.refund(params.merge!(TXNREF: ""))
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("TXNREF not found")
        expect(response.code).to   eq(-1)
        expect(response.status).to eq("failed")
      end

      it "has key :TXNREF with a non-empty value" do
        response = client.refund(params)
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("")
        expect(response.code).to   eq(0)
        expect(response.status).to eq("")
      end

    end

    context "parameter is anything but a hash" do
      it { expect { client.refund(1) }.to raise_error(TypeError) }
    end

  end

  describe "#status" do

  end

  describe "#preauth" do

  end
end
