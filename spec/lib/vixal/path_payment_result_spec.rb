require "spec_helper"

describe Vixal::PathPaymentResult, "#send_amount" do


  context "when the result is not successful" do
    subject{ Vixal::PathPaymentResult.new(:path_payment_malformed) }

    it "raises an exception if the result is not successful" do
      expect{ subject.send_amount }.to raise_error(XDR::ArmNotSetError)
    end
  end

  context "when the result has no claimed offers" do
    let(:simple_success){ Vixal::SimplePaymentResult.new(amount: 100) }
    let(:path_success){ Vixal::PathPaymentResult::Success.new(last: simple_success) }

    subject{ Vixal::PathPaymentResult.new(:path_payment_success, path_success) }

    it "returns the amount from the 'last' component" do
      expect(subject.send_amount).to eql(100)
    end
  end


  context "with simple 1-hop result" do
    let(:simple_success){ Vixal::SimplePaymentResult.new(amount: 100) }
    let(:offers) do
      [Vixal::ClaimOfferAtom.new(asset_bought: Vixal::Asset.native, amount_bought: 200)]
    end

    let(:path_success) do
      Vixal::PathPaymentResult::Success.new({
        offers: offers,
        last:   simple_success,
      })
    end

    subject{ Vixal::PathPaymentResult.new(:path_payment_success, path_success) }

    it "returns the amount from the ClaimOfferAtom" do
      expect(subject.send_amount).to eql(200)
    end
  end

  context "with 1-hop result that claimed multiple offers" do
    let(:simple_success){ Vixal::SimplePaymentResult.new(amount: 100) }
    let(:offers) do
      [
        Vixal::ClaimOfferAtom.new(asset_bought: Vixal::Asset.native, amount_bought: 200),
        Vixal::ClaimOfferAtom.new(asset_bought: Vixal::Asset.native, amount_bought: 200),
      ]
    end

    let(:path_success) do
      Vixal::PathPaymentResult::Success.new({
        offers: offers,
        last:   simple_success,
      })
    end

    subject{ Vixal::PathPaymentResult.new(:path_payment_success, path_success) }

    it "returns the summed amount from the ClaimOfferAtoms" do
      expect(subject.send_amount).to eql(400)
    end
  end


  context "with multi-hop result that claimed multiple offers" do
    let(:simple_success){ Vixal::SimplePaymentResult.new(amount: 100) }
    let(:otherAsset){ Vixal::Asset.alphanum4("USD", Vixal::KeyPair.random) }
    let(:offers) do
      [
        Vixal::ClaimOfferAtom.new(asset_bought: Vixal::Asset.native, amount_bought: 200),
        Vixal::ClaimOfferAtom.new(asset_bought: Vixal::Asset.native, amount_bought: 200),
        Vixal::ClaimOfferAtom.new(asset_bought: otherAsset, amount_bought: 200),
      ]
    end

    let(:path_success) do
      Vixal::PathPaymentResult::Success.new({
        offers: offers,
        last:   simple_success,
      })
    end

    subject{ Vixal::PathPaymentResult.new(:path_payment_success, path_success) }

    it "returns the summed amount from the ClaimOfferAtoms" do
      expect(subject.send_amount).to eql(400)
    end
  end

end
