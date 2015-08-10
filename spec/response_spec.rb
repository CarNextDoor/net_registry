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
