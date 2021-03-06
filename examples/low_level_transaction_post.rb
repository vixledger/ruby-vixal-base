#!/usr/bin/env ruby

# This is an example of using the raw xdr objects to post a transaction
# notice that we must manually hash/sign the structures and we must manually
# fill out all the fields.
#
# Look at mid_level_transaction_post.rb to see a friendlier form

require 'rbnacl'
require 'vixal-base'
require 'faraday'
require 'digest/sha2'

master      = RbNaCl::SigningKey.new("allmylifemyhearthasbeensearching")
destination = RbNaCl::SigningKey.new("allmylifemyhearthasbeensearching")

tx            = Vixal::Transaction.new
tx.account    = master.verify_key.to_bytes
tx.fee        = 1000
tx.seq_num    = 1

payment = Vixal::PaymentOp.new
payment.destination = destination.verify_key.to_bytes
payment.asset = Vixal::Asset.new(:native)
payment.amount = 200 * Vixal::ONE

op = Vixal::Operation.new
op.body = Vixal::Operation::Body.new(:payment, payment)

tx.operations = [op]

raw       = tx.to_xdr
tx_hash   = Digest::SHA256.digest raw
signature = master.sign(tx_hash)

env = Vixal::TransactionEnvelope.new
env.tx = tx
env.signatures = [Vixal::DecoratedSignature.new({
  hint:master.verify_key.to_bytes[0...4],
  signature:signature
})]

env_hex = env.to_xdr.unpack("H*").first

result = Faraday.get('http://localhost:39132/tx', blob: env_hex)
puts result.body
