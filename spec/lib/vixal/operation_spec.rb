require 'spec_helper'

describe Vixal::Operation, ".payment" do


  it "correctly translates the provided amount to the native representation" do
    op = Vixal::Operation.payment(destination: Vixal::KeyPair.random, amount: [:native, 20])
    expect(op.body.value.amount).to eql(20_0000000)
    op = Vixal::Operation.payment(destination: Vixal::KeyPair.random, amount: [:native, "20"])
    expect(op.body.value.amount).to eql(20_0000000)
  end

end


describe Vixal::Operation, ".manage_data" do

  it "works" do
    op = Vixal::Operation.manage_data(name: "my name", value: "hello")
    expect(op.body.manage_data_op!.data_name).to eql("my name")
    expect(op.body.manage_data_op!.data_value).to eql("hello")
    expect{ op.to_xdr }.to_not raise_error

    op = Vixal::Operation.manage_data(name: "my name")
    expect(op.body.manage_data_op!.data_name).to eql("my name")
    expect(op.body.manage_data_op!.data_value).to be_nil
    expect{ op.to_xdr }.to_not raise_error
  end

end
