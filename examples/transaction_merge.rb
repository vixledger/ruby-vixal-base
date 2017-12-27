#!/usr/bin/env ruby

require 'vixal-base'

master      = Vixal::KeyPair.master
destination = Vixal::KeyPair.master

tx1 = Vixal::Transaction.payment({
  account:     master,
  destination: destination,
  sequence:    1,
  amount:      [:native, 20]
})

tx2 = Vixal::Transaction.payment({
  account:     master,
  destination: destination,
  sequence:    2,
  amount:      [:native, 20]
})

hex = tx1.merge(tx2).to_envelope(master).to_xdr(:base64)
puts hex
