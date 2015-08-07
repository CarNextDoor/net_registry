require "spec_helper"

RSpec.describe NetRegistry::Response do
  describe "#init" do
    context "no argument is supplied to constructor" do
      let(:response) { NetRegistry::Response.new }
      it { expect(response.text).to eq("Unknown Error") }
      it { expect(response.code).to eq(-1)              }
      it { expect(response.status).to eq("failed")      }
      it { expect(response.failed?).to be(true)         }
      it { expect(response.success?).to be(false)       }
    end

    context "argument is supplied" do
      text   = "Something"
      code   = 1
      status = "success"
      let(:response) { NetRegistry::Response.new(text: text, code: code, status: status) }
      it { expect(response.text).to eq(text)     }
      it { expect(response.code).to eq(code)     }
      it { expect(response.status).to eq(status) }
      it { expect(response.failed?).to be(false) }
      it { expect(response.success?).to be(true) }
    end
  end

  text   = "Something"
  code   = 1
  status = "success"
  let(:response) { NetRegistry::Response.new(text: text, code: code, status: status) }
  describe "#text" do
    it "assigns new text" do
      new_text = "Say Something"
      expect(response.text).to eq(text)
      response.text = new_text
      expect(response.text).to eq(new_text)
    end
  end

  describe "#status" do
    it "assigns new status" do
      new_status = "I'm giving up on you"
      expect(response.status).to eq(status)
      response.status = new_status
      expect(response.status).to eq(new_status)
    end
  end

  describe "#code" do
    it "assigns new code" do
      new_code = -1
      expect(response.code).to eq(code)
      response.code = new_code
      expect(response.code).to eq(new_code)
      expect(response.failed?).to eq(true)
      expect(response.success?).to eq(false)

      new_code = "I'll be the one if you want me to"
      response.code = new_code
      expect(response.code).to eq(0)
      expect(response.failed?).to eq(false)
      expect(response.success?).to eq(true)
    end
  end
end
