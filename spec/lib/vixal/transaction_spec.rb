require "spec_helper"

describe Vixal::Transaction do
  subject do
    Vixal::Transaction.new({
      source_account: Vixal::AccountID.new(:public_key_type_ed25519, "\x00" * 32),
      fee:            10,
      seq_num:        1,
      memo:           Vixal::Memo.new(:memo_none),
      ext:            Vixal::Transaction::Ext.new(0),
      operations:     [
        Vixal::Operation.new(body: Vixal::Operation::Body.new(:inflation))
      ]
    })
  end
  let(:key_pair){ Vixal::KeyPair.random }

  describe "#sign" do
    let(:result){ subject.sign(key_pair) }

    it "returns a signature of SHA256(signature_base of the transaction)" do
      hash     = Digest::SHA256.digest(subject.signature_base)
      expected = key_pair.sign(hash)
      expect(result).to eq(expected)
    end
  end

  describe  "#to_envelope" do
    let(:result){ subject.to_envelope(*key_pairs) }


    context "with a single key pair as a parameter" do
      let(:key_pairs){ [key_pair] }

      it "return a Vixal::TransactionEnvelope" do
        expect(result).to be_a(Vixal::TransactionEnvelope)
      end

      it "correctly signs the transaction" do
        expect(result.signatures.length).to eq(1)
        expect(result.signatures.first).to be_a(Vixal::DecoratedSignature)
        expect(result.signatures.first.hint).to eq(key_pair.signature_hint)
        expect(result.signatures.first.signature).to eq(subject.sign(key_pair))
      end
    end

    context "with no keypairs provided as parameters" do
      let(:key_pairs){ [] }

      it "return a Vixal::TransactionEnvelope" do
        expect(result).to be_a(Vixal::TransactionEnvelope)
      end

      it "adds no signatures" do
        expect(result.signatures.length).to eq(0)
      end
    end
  end

  describe "#signature_base" do

    it "is prefixed with the current network id" do
      expect(subject.signature_base).to start_with(Vixal.current_network_id)
    end

    it "includes the envelope type" do
      expect(subject.signature_base[32...36]).to eql("\x00\x00\x00\x02")
    end

  end

  describe ".for_account's memo assignment" do
    let(:attrs){{account: Vixal::KeyPair.random, sequence: 1}}

    def make(memo)
      tx = Vixal::Transaction.for_account(attrs.merge(memo: memo))
      tx.memo
    end

    it "sets to an ID memo when a number is provided" do
      expect(make(3)).to eql(Vixal::Memo.new(:memo_id, 3))
    end

    it "sets to an text memo when a number is provided" do
      expect(make("hello")).to eql(Vixal::Memo.new(:memo_text, "hello"))
    end

    it "uses the provided value directly if already a memo" do
      expect(make(Vixal::Memo.new(:memo_text, "hello"))).to eql(Vixal::Memo.new(:memo_text, "hello"))
    end


    it "allows a 2-element array as shorthand" do
      expect(make([:id, 3])).to eql(Vixal::Memo.new(:memo_id, 3))
      expect(make([:text, "h"])).to eql(Vixal::Memo.new(:memo_text, "h"))
      expect(make([:hash, "h"])).to eql(Vixal::Memo.new(:memo_hash, "h"))
      expect(make([:return, "h"])).to eql(Vixal::Memo.new(:memo_return, "h"))
    end
  end
end
