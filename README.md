# VIXAL::Base

[![Build Status](https://travis-ci.org/vixledger/ruby-vixal-base.svg)](https://travis-ci.org/vixledgerr/ruby-vixal-base)
[![Code Climate](https://codeclimate.com/github/vixledger/ruby-vixal-base/badges/gpa.svg)](https://codeclimate.com/github/vixledger/ruby-vixal-base)

The vixal-base library is the lowest-level vixal helper library.  It consists of classes
to read, write, hash, and sign the xdr structures that are used in vixaled.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vixal-base'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vixal-base

Also requires libsodium. Installable via `brew install libsodium` on OS X.

## Supported Ruby Versions

Please see [travis.yml](.travis.yml) for what versions of ruby are currently tested by our continuous integration system.  Any ruby in that list is officially supported.

### JRuby

It seems as though jruby is particularly slow when it comes to BigDecimal math; the source behind this slowness has not been investigated, but it is something to be aware of.

## Usage

[Examples are here](examples)

In addition to the code generated from the XDR definition files (see [ruby-xdr](https://github.com/vixledger/ruby-xdr) for example usage), this library also provides some vixledger specific features.  Let's look at some of them.

We wrap rbnacl with `VIXAL::KeyPair`, providing some vixledger specific functionality as seen below:

```ruby

# Create a keypair from a vixledger secret seed
signer = VIXAL::KeyPair.from_seed("SCBASSEX34FJNIPLUYQPSMZHHYXXQNWOOV42XYZFXM6EGYX2DPIZVIA3")

# Create a keypair from a vixledger address
verifier = VIXAL::KeyPair.from_address("GBQWWBFLRP3BXD2RI2FH7XNNU2MKIYVUI7QXUAIVG34JY6MQGXVUO3RX")

# Produce a vixledger compliant "decorated signature" that is compliant with vixledger transactions

signer.sign_decorated("Hello world!") # => #<VIXAL::DecoratedSignature ...>

```

This library also provides an impementation of VIXAL's "StrKey" encoding (RFC-4648 Base32 + CCITT-XModem CRC16):

```ruby

VIXAL::Util::StrCheck.check_encode(:account_id, "\xFF\xFF\xFF\xFF\xFF\xFF\xFF") # => "GD777777777764TU"
VIXAL::Util::StrCheck.check_encode(:seed, "\x00\x00\x00\x00\x00\x00\x39") # => "SAAAAAAAAAADST3H"

# To prevent interpretation mistakes, you must pass the expected version byte
# when decoding a check_encoded value

encoded = VIXAL::Util::StrCheck.check_encode(:account_id, "\x61\x6b\x04\xab\x8b\xf6\x1b")
VIXAL::Util::StrCheck.check_decode(:account_id, encoded) # => "\x61\x6b\x04\xab\x8b\xf6\x1b"
VIXAL::Util::StrCheck.check_decode(:seed, encoded) # => throws ArgumentError: Unexpected version: :account_id

```

## Updating Generated Code

The generated code of this library must be refreshed each time the VIXAL network's protocol is updated.  To perform this task, run `rake xdr:update`, which will download the latest `.x` files into the `xdr` folder and will run `xdrgen` to regenerate the built ruby code.

## Caveats

The current integration of user-written code with auto-generated classes is to put it nicely, weird.  We intend to segregate the auto-generated code into its own namespace and refrain from monkey patching them.  This will happen before 1.0, and hopefully will happen soon.

## Contributing

Please [see CONTRIBUTING.md for details](CONTRIBUTING.md).
