require "spec_helper"

describe Vixal, ".default_network=" do

  before(:each){ Vixal.default_network = "foo" }
  after(:each){ Vixal.default_network = nil }

  it "sets the value returned by current_network " do
    expect(Vixal.current_network).to eql("foo")
  end

end

describe Vixal, ".current_network" do

  after(:each){ Vixal.default_network = nil }

  it "returns the public network absent any other configuration" do
    expect(Vixal.current_network).to eql(Vixal::Networks::TESTNET)
  end

  it "returns the default network if configured and not within a call to on_network" do
    Vixal.default_network = "foo"
    expect(Vixal.current_network).to eql("foo")
  end

  it "returns the network as specified by on_network, even when a default is set" do
    Vixal.default_network = "foo"

    Vixal.on_network "bar" do
      expect(Vixal.current_network).to eql("bar")
    end

    expect(Vixal.current_network).to eql("foo")
  end
end

describe Vixal, ".current_network_id" do
  it "returns the sha256 of the current_network" do
    expect(Vixal.current_network_id).to eql(Digest::SHA256.digest(Vixal.current_network))
  end
end

describe Vixal, ".on_network" do

  after(:each){ Thread.current["vixal_network_passphrase"] = nil }


  it "sets the current_network and a thread local" do
    Vixal.on_network "bar" do
      expect(Vixal.current_network).to eql("bar")
      expect(Thread.current["vixal_network_passphrase"]).to eql("bar")
    end
  end


  it "nests" do
    Vixal.on_network "foo" do
      expect(Vixal.current_network).to eql("foo")
      Vixal.on_network "bar" do
        expect(Vixal.current_network).to eql("bar")
      end
      expect(Vixal.current_network).to eql("foo")
    end
  end


  it "resets the network value when an error is raised" do
    begin
      Vixal.on_network "foo" do
        raise "kablow"
      end
    rescue
      expect(Vixal.current_network).to_not eql("foo")
    end
  end
end
