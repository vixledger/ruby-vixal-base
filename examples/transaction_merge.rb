#!/usr/bin/env ruby

require 'vixal-base'

master      = VIXAL::KeyPair.master
destination = VIXAL::KeyPair.master

tx1 = VIXAL::Transaction.payment({
  account:     master,
  destination: destination,
  sequence:    1,
  amount:      [:native, 20]
})

tx2 = VIXAL::Transaction.payment({
  account:     master,
  destination: destination,
  sequence:    2,
  amount:      [:native, 20]
})

hex = tx1.merge(tx2).to_envelope(master).to_xdr(:base64)
puts hex
