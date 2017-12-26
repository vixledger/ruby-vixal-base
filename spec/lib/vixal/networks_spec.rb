require "spec_helper"

describe VIXAL, ".default_network=" do

  before(:each){ VIXAL.default_network = "foo" }
  after(:each){ VIXAL.default_network = nil }

  it "sets the value returned by current_network " do
    expect(VIXAL.current_network).to eql("foo")
  end

end

describe VIXAL, ".current_network" do

  after(:each){ VIXAL.default_network = nil }

  it "returns the public network absent any other configuration" do
    expect(VIXAL.current_network).to eql(VIXAL::Networks::TESTNET)
  end

  it "returns the default network if configured and not within a call to on_network" do
    VIXAL.default_network = "foo"
    expect(VIXAL.current_network).to eql("foo")
  end

  it "returns the network as specified by on_network, even when a default is set" do
    VIXAL.default_network = "foo"

    VIXAL.on_network "bar" do
      expect(VIXAL.current_network).to eql("bar")
    end

    expect(VIXAL.current_network).to eql("foo")
  end
end

describe VIXAL, ".current_network_id" do
  it "returns the sha256 of the current_network" do
    expect(VIXAL.current_network_id).to eql(Digest::SHA256.digest(VIXAL.current_network))
  end
end

describe VIXAL, ".on_network" do

  after(:each){ Thread.current["vixal_network_passphrase"] = nil }


  it "sets the current_network and a thread local" do
    VIXAL.on_network "bar" do
      expect(VIXAL.current_network).to eql("bar")
      expect(Thread.current["vixal_network_passphrase"]).to eql("bar")
    end
  end


  it "nests" do
    VIXAL.on_network "foo" do
      expect(VIXAL.current_network).to eql("foo")
      VIXAL.on_network "bar" do
        expect(VIXAL.current_network).to eql("bar")
      end
      expect(VIXAL.current_network).to eql("foo")
    end
  end


  it "resets the network value when an error is raised" do
    begin
      VIXAL.on_network "foo" do
        raise "kablow"
      end
    rescue
      expect(VIXAL.current_network).to_not eql("foo")
    end
  end
end
