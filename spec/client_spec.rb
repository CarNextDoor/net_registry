require "spec_helper"

RSpec.describe NetRegistry::Client do
  let(:username) { "username" }
  let(:password) { "password" }
  let(:client)   { NetRegistry::Client.new(merchant_id: username, password: password) }
  let(:params)   do
    {
      AMOUNT: "100.0",
      CCNUM: "111111111111",
      CCEXP: "10/15",
      TXNREF: "0007311428202312"
    }
  end
  let(:body) { params.merge!(LOGIN: "#{username}/#{password}")}
  let(:status_success_response) do
    <<-STATUS
    card_number=#{params[:CCNUM]}
    settlement_date=31/07/00
    response_text=INVALID TRANSACTION
    amount=#{params[:AMOUNT]}
    status=complete
    txnref=#{params[:TXNREF]}
    bank_ref=000731000024
    card_desc=VISA
    response_code=12
    card_expiry=01/01
    MID=24
    card_type=6
    time=2000­07­31 14:28:20
    command=purchase
    result=0
    .
    done=1
    STATUS
  end

  let(:purchase_success_response) do
    <<-PURCHASE
    training_mode=0
    pld=0
    approved=0
    settlement_date=31/07/00
    transaction_no=332546
    status=declined
    version=V1.0
    operator_no=22546
    refund_mode=0
    merchant_index=24
    response_code=12
    receipt_array=ARRAY(0x8221b9c)
    cashout_amount=0
    account_type=CREDIT A/C
    rrn=000782000024
    response_text=INVALID TRANSACTION
    txn_ref=0007311458332546
    card_no=4111111111111111
    total_amount=100
    card_desc=VISA
    card_expiry=01/01
    card_type=6
    result=0
    Reciept follows
    Transaction No: 00332546
    ­­­­­­­­­­­­­­­­­­­­­­­­
    TYRELL CORPORATION    
    MERCH ID        99999999
    TERM  ID          Y9TB99
    COUNTRY CODE AU
    31/07/00           14:32
    RRN         000782000024
    VISA
    411111­111
    CREDIT A/C         01/01
    AUTHORISATION��NO:
    DECLINED   12
    PURCHASE           $1.00
    TOTAL   AUD        $1.00
    PLEASE RETAIN AS RECORD 
    OF PURCHASE
    (SUBJECT TO CARDHOLDER'S
    ACCEPTANCE)      
    ­­­­­­­­­­­­­­­­­­­­­­­­
    .
    done=1
    PURCHASE
  end

  describe "#initialize" do
    it { expect(client.merchant_id).to eq(username) }
    it { expect(client.password).to eq(password) }
  end

  describe "#purchase" do
    context "parameter is a hash" do
      it "should not raise any errors" do
        stub_request(:post, /https:\/\/paygate\.ssllock\.net\/external2\.pl/)
        .with(body: body.merge!(COMMAND: "purchase"))
        .to_return(status: 200, body: purchase_success_response, headers: {})
        expect { client.purchase(params) }.not_to raise_error
      end
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
        stub_request(:post, /https:\/\/paygate\.ssllock\.net\/external2\.pl/)
        .with(body: body.merge!(COMMAND: "purchase"))
        .to_return(status: 200, body: purchase_success_response, headers: {})

        response = client.purchase(params)
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("INVALID TRANSACTION")
        expect(response.code).to   eq(12)
        expect(response.status).to eq("declined")
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
        stub_request(:post, /https:\/\/paygate\.ssllock\.net\/external2\.pl/)
        .with(body: body.merge!(COMMAND: "purchase"))
        .to_return(status: 200, body: purchase_success_response, headers: {})
        response = client.purchase(params)
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("INVALID TRANSACTION")
        expect(response.code).to   eq(12)
        expect(response.status).to eq("declined")
      end

    end

    context "parameter is anything but a hash" do
      it { expect { client.purchase(1) }.to raise_error(TypeError) }
    end
  end

  describe "#refund" do
    context "parameter is a hash" do
      it "does not raise error" do
        stub_request(:post, /https:\/\/paygate\.ssllock\.net\/external2\.pl/)
        .with(body: body.merge!(COMMAND: "refund"))
        .to_return(status: 200, body: purchase_success_response, headers: {})
        expect { client.refund(params) }.not_to raise_error
      end
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
        stub_request(:post, /https:\/\/paygate\.ssllock\.net\/external2\.pl/)
        .with(body: body.merge!(COMMAND: "refund"))
        .to_return(status: 200, body: purchase_success_response, headers: {})
        response = client.refund(params)
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("INVALID TRANSACTION")
        expect(response.code).to   eq(12)
        expect(response.status).to eq("declined")
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
        stub_request(:post, /https:\/\/paygate\.ssllock\.net\/external2\.pl/)
        .with(body: body.merge!(COMMAND: "refund"))
        .to_return(status: 200, body: purchase_success_response, headers: {})
        response = client.refund(params)
        expect(response.class).to  eq(NetRegistry::Response)
        expect(response.text).to   eq("INVALID TRANSACTION")
        expect(response.code).to   eq(12)
        expect(response.status).to eq("declined")
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
