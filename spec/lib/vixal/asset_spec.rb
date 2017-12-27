require "spec_helper"

describe Vixal::Asset, ".native" do
  it "returns a asset instance whose type is 'AssetType.asset_type_native'" do
    expect(Vixal::Asset.native.type).to eq(Vixal::AssetType.asset_type_native)
  end
end

describe Vixal::Asset, ".alphanum4" do
  it "returns a asset instance whose type is 'AssetType.asset_type_credit_alphanum4'" do
    result = Vixal::Asset.alphanum4("USD", Vixal::KeyPair.master)
    expect(result.type).to eq(Vixal::AssetType.asset_type_credit_alphanum4)
  end

  it "pads the code to 4 bytes, padding on the right and with null bytes" do
    result = Vixal::Asset.alphanum4("USD", Vixal::KeyPair.master)
    expect(result.code).to eq("USD\x00")
  end
end

describe Vixal::Asset, ".alphanum12" do
  it "returns a asset instance whose type is 'AssetType.asset_type_credit_alphanum12'" do
    result = Vixal::Asset.alphanum12("USD", Vixal::KeyPair.master)
    expect(result.type).to eq(Vixal::AssetType.asset_type_credit_alphanum12)
  end

  it "pads the code to 12 bytes, padding on the right and with null bytes" do
    result = Vixal::Asset.alphanum12("USD", Vixal::KeyPair.master)
    expect(result.code).to eq("USD\x00\x00\x00\x00\x00\x00\x00\x00\x00")
  end
end

describe Vixal::Asset, "#code" do
  it "returns the asset_code for either alphanum4 or alphanum12 assets" do
    a4 = Vixal::Asset.alphanum4("USD", Vixal::KeyPair.master)
    a12 = Vixal::Asset.alphanum12("USD", Vixal::KeyPair.master)

    expect(a4.code.strip).to eq("USD")
    expect(a12.code.strip).to eq("USD")
  end

  it "raises an error when called on a native asset" do
    expect{ Vixal::Asset.native.code }.to raise_error(RuntimeError)
  end
end
