require "spec_helper"
RSpec.describe NetRegistry::ResponseFactory do
  let(:factory) { NetRegistry::ResponseFactory.new }
  let(:invalid_login_format) do
    <<-RESPONSE
    failed
    Invalid login format
    RESPONSE
  end
  let(:invalid_credit_card_number) do
    <<-RESPONSE
    failed


    .
    response_text=Invalid Credit card number
    status=failed
    response_code=-1
    result=-1
    RESPONSE
  end
  let(:status_invalid_transaction) do
    <<-RESPONSE
    card_number=XXXXXXXXXXXX1111
    settlement_date=31/07/00
    response_text=INVALID TRANSACTION
    amount=100
    status=complete
    txnref=0007311428202312
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
    RESPONSE
  end
  describe "#init" do
    it { expect(factory.response.class).to be(NetRegistry::Response) }
  end

  describe "#parse" do
    context "response is not a string" do
      it { expect {factory.parse(1)}.to raise_error(TypeError)}
    end
    context "failed response (invalid params)" do
      before :each do
        @response = factory.parse(invalid_credit_card_number).create
      end
      it { expect(@response.text).to   eq("Invalid Credit card number") }
      it { expect(@response.status).to eq("failed")                     }
      it { expect(@response.code).to   eq(-1)                           }
      it { expect(@response.result).to eq(-1)                           }
    end
    context "failed response (invalid login)" do
      before :each do
        @response = factory.parse(invalid_login_format).create
      end
      it { expect(@response.text).to   eq("Invalid login format")       }
      it { expect(@response.status).to eq("failed")                     }
      it { expect(@response.code).to   eq(-1)                           }
      it { expect(@response.result).to eq(-1)                           }
    end
    context "#status_invalid_transaction" do
      before :each do
        @response = factory.parse(status_invalid_transaction).create
      end
      it { expect(@response.text).to eq("INVALID TRANSACTION") }
      it { expect(@response.transaction.card.number).to eq("XXXXXXXXXXXX1111") }
      it { expect(@response.transaction.amount).to eq("100") }
      it { expect(@response.status).to eq("complete") }
      it { expect(@response.transaction.reference).to eq("0007311428202312") }
      it { expect(@response.transaction.bank_reference).to eq("000731000024")}
      it { expect(@response.transaction.card.description).to eq("VISA")}
      it { expect(@response.code).to eq(12) }
      it { expect(@response.transaction.card.type).to eq("6")}
      it { expect(@response.transaction.time).to eq("2000­07­31 14:28:20")}
      it { expect(@response.transaction.command).to eq("purchase")}
      it { expect(@response.result).to eq(0)}
    end

  end

  describe "#create" do
    let(:invalid_status_params)   { { TXNREF: nil } }
    it { expect(factory.create.class).to be(NetRegistry::Response) }
    it "has invalid status params" do
      factory.verify_params(invalid_status_params.merge!(COMMAND: "status"))
      response = factory.create
      expect(response.text).to eq("TXNREF not found")
      expect(response.status).to eq("failed")
      expect(response.code).to eq(-1)
    end

    it "has not provided with a COMMAND" do
      factory.verify_params(invalid_status_params)
      response = factory.create
      expect(response.text).to eq("Invalid command. Only [purchase status preauth refund] are valid.")
      expect(response.status).to eq("failed")
      expect(response.code).to eq(-1)
    end
  end

  describe "#verify_params" do
    let(:status_params)   { { TXNREF: "1234567" } }
    let(:refund_params)   { { AMOUNT: "100", TXNREF: "1234567"} }
    let(:purchase_params) { { AMOUNT: "100", CCNUM: "111111111111", CCEXP: "10/15"} }
    let(:preauth_params)  { { AMOUNT: "100", CCNUM: "111111111111", CCEXP: "10/15"} }

    it { expect(factory.verify_params(preauth_params.merge!(COMMAND: "preauth"))).to be(true) }
    it { expect(factory.verify_params(preauth_params.merge!(COMMAND: "purchase"))).to be(true)}
    it { expect(factory.verify_params(preauth_params.merge!(COMMAND: "refund"))).to be(false) }
    it { expect(factory.verify_params(preauth_params.merge!(COMMAND: "status"))).to be(false) }

    it { expect(factory.verify_params(refund_params.merge!(COMMAND: "preauth"))).to be(false) }
    it { expect(factory.verify_params(refund_params.merge!(COMMAND: "purchase"))).to be(false)}
    it { expect(factory.verify_params(refund_params.merge!(COMMAND: "refund"))).to be(true)   }
    it { expect(factory.verify_params(refund_params.merge!(COMMAND: "status"))).to be(true)   }

    it { expect(factory.verify_params(purchase_params.merge!(COMMAND: "preauth"))).to be(true) }
    it { expect(factory.verify_params(purchase_params.merge!(COMMAND: "purchase"))).to be(true)}
    it { expect(factory.verify_params(purchase_params.merge!(COMMAND: "refund"))).to be(false) }
    it { expect(factory.verify_params(purchase_params.merge!(COMMAND: "status"))).to be(false) }

    it { expect(factory.verify_params(status_params.merge!(COMMAND: "preauth"))).to be(false) }
    it { expect(factory.verify_params(status_params.merge!(COMMAND: "purchase"))).to be(false)}
    it { expect(factory.verify_params(status_params.merge!(COMMAND: "refund"))).to be(false)  }
    it { expect(factory.verify_params(status_params.merge!(COMMAND: "status"))).to be(true)   }
  end

  describe "#validate_preauth_params" do
    let(:params) { {CCNUM: "111111111111", CCEXP: "10/14", AMOUNT: "100"} }
    it { expect(factory.send(:validate_preauth_params, params)). to eq(["", true]) }
    it "does not have AMOUNT in params hash" do
      expect(factory.send(:validate_preauth_params, params.merge!(AMOUNT: nil))).to eq(["AMOUNT not found", false])
      expect(factory.send(:validate_preauth_params, params.merge!(AMOUNT: ""))).to eq(["AMOUNT not found", false])
    end
    it "does not have CCNUM in params hash" do
      expect(factory.send(:validate_preauth_params, params.merge!(CCNUM: nil))).to eq(["CCNUM not found", false])
      expect(factory.send(:validate_preauth_params, params.merge!(CCNUM: ""))).to eq(["CCNUM not found", false])
    end
    it "does not have CCEXP in params hash" do
      expect(factory.send(:validate_preauth_params, params.merge!(CCEXP: nil))).to eq(["CCEXP not found", false])
      expect(factory.send(:validate_preauth_params, params.merge!(CCEXP: ""))).to eq(["CCEXP not found", false])
    end
    it "invalid CCEXP format" do
      expect(factory.send(:validate_preauth_params, params.merge!(CCEXP: "what'sup"))).to eq(["CCEXP invalid format", false])
      expect(factory.send(:validate_preauth_params, params.merge!(CCEXP: "12/20/2015"))).to eq(["CCEXP invalid format", false])
    end
  end

  describe "#validate_status_params" do
    let(:params) { { TXNREF: "1234567" } }
    it { expect(factory.send(:validate_status_params, params)). to eq(["", true]) }
    it "does not have txnref in params hash" do
      expect(factory.send(:validate_status_params, params.merge!(TXNREF: nil))).to eq(["TXNREF not found", false])
      expect(factory.send(:validate_status_params, params.merge!(TXNREF: ""))).to eq(["TXNREF not found", false])
    end
  end

  describe "#vaidate_refund_params" do
    let(:params) { {AMOUNT: "100", TXNREF: "1234567"} }
    it { expect(factory.send(:validate_refund_params, params)). to eq(["", true]) }
    it "does not have amount in params hash" do
      expect(factory.send(:validate_refund_params, params.merge!(AMOUNT: nil))).to eq(["AMOUNT not found", false])
      expect(factory.send(:validate_refund_params, params.merge!(AMOUNT: ""))).to eq(["AMOUNT not found", false])
    end
    it "does not have txnref in params hash" do
      expect(factory.send(:validate_refund_params, params.merge!(TXNREF: nil))).to eq(["TXNREF not found", false])
      expect(factory.send(:validate_refund_params, params.merge!(TXNREF: ""))).to eq(["TXNREF not found", false])
    end
  end

  describe "#validate_purchase_params" do
    let(:params) { {AMOUNT: "100", CCNUM: "111111111111", CCEXP: "10/15"}}
    it { expect(factory.send(:validate_purchase_params, params)). to eq(["", true]) }
    it "does not have amount in params hash" do
      expect(factory.send(:validate_purchase_params, params.merge!(AMOUNT: nil))).to eq(["AMOUNT not found", false])
      expect(factory.send(:validate_purchase_params, params.merge!(AMOUNT: ""))).to eq(["AMOUNT not found", false])
    end

    it "does not have CCNUM in params hash" do
      expect(factory.send(:validate_purchase_params, params.merge!(CCNUM: nil))).to eq(["CCNUM not found", false])
      expect(factory.send(:validate_purchase_params, params.merge!(CCNUM: ""))).to eq(["CCNUM not found", false])
    end

    it "does not have CCEXP in params hash" do
      expect(factory.send(:validate_purchase_params, params.merge!(CCEXP: nil))).to eq(["CCEXP not found", false])
      expect(factory.send(:validate_purchase_params, params.merge!(CCEXP: ""))).to eq(["CCEXP not found", false])
    end

    it "invalid CCEXP format" do
      expect(factory.send(:validate_purchase_params, params.merge!(CCEXP: "12/29/2015"))).to eq(["CCEXP invalid format", false])
      expect(factory.send(:validate_purchase_params, params.merge!(CCEXP: "What's up"))).to eq(["CCEXP invalid format", false])
    end
  end
end
