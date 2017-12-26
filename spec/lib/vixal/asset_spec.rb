require "spec_helper"

describe VIXAL::Asset, ".native" do
  it "returns a asset instance whose type is 'AssetType.asset_type_native'" do
    expect(VIXAL::Asset.native.type).to eq(VIXAL::AssetType.asset_type_native)
  end
end

describe VIXAL::Asset, ".alphanum4" do
  it "returns a asset instance whose type is 'AssetType.asset_type_credit_alphanum4'" do
    result = VIXAL::Asset.alphanum4("USD", VIXAL::KeyPair.master)
    expect(result.type).to eq(VIXAL::AssetType.asset_type_credit_alphanum4)
  end

  it "pads the code to 4 bytes, padding on the right and with null bytes" do
    result = VIXAL::Asset.alphanum4("USD", VIXAL::KeyPair.master)
    expect(result.code).to eq("USD\x00")
  end
end

describe VIXAL::Asset, ".alphanum12" do
  it "returns a asset instance whose type is 'AssetType.asset_type_credit_alphanum12'" do
    result = VIXAL::Asset.alphanum12("USD", VIXAL::KeyPair.master)
    expect(result.type).to eq(VIXAL::AssetType.asset_type_credit_alphanum12)
  end

  it "pads the code to 12 bytes, padding on the right and with null bytes" do
    result = VIXAL::Asset.alphanum12("USD", VIXAL::KeyPair.master)
    expect(result.code).to eq("USD\x00\x00\x00\x00\x00\x00\x00\x00\x00")
  end
end

describe VIXAL::Asset, "#code" do
  it "returns the asset_code for either alphanum4 or alphanum12 assets" do
    a4 = VIXAL::Asset.alphanum4("USD", VIXAL::KeyPair.master)
    a12 = VIXAL::Asset.alphanum12("USD", VIXAL::KeyPair.master)

    expect(a4.code.strip).to eq("USD")
    expect(a12.code.strip).to eq("USD")
  end

  it "raises an error when called on a native asset" do
    expect{ VIXAL::Asset.native.code }.to raise_error(RuntimeError)
  end
end
