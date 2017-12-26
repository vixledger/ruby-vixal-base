require 'bigdecimal'

module VIXAL
  class Operation


    #
    # Construct a new VIXAL::Operation from the provided
    # source account and body
    #
    # @param [Hash] attributes the attributes to create the operation with
    # @option attributes [VIXAL::KeyPair] :source_account
    # @option attributes [VIXAL::Operation::Body] :body
    #
    # @return [VIXAL::Operation] the built operation
    def self.make(attributes={})
      source_account = attributes[:source_account]
      body           = VIXAL::Operation::Body.new(*attributes[:body])

      op = VIXAL::Operation.new(body:body)

      if source_account
        raise ArgumentError, "Bad :source_account" unless source_account.is_a?(VIXAL::KeyPair)
        op.source_account = source_account.account_id
      end

      return op
    end


    #
    # Helper method to create a valid PaymentOp, wrapped
    # in the necessary XDR structs to be included within a
    # transactions `operations` array.
    #
    # @see VIXAL::Asset
    #
    # @param [Hash] attributes the attributes to create the operation with
    # @option attributes [VIXAL::KeyPair] :destination the receiver of the payment
    # @option attributes [Array] :amount the amount to pay
    # @return [VIXAL::Operation] the built operation, containing a
    #                              VIXAL::PaymentOp body
    def self.payment(attributes={})
      destination = attributes[:destination]
      asset, amount = extract_amount(attributes[:amount])

      raise ArgumentError unless destination.is_a?(KeyPair)


      op             = PaymentOp.new
      op.asset       = asset
      op.amount      = amount
      op.destination = destination.account_id

      return make(attributes.merge({
        body:[:payment, op]
      }))
    end

    #
    # Helper method to create a valid PathPaymentOp, wrapped
    # in the necessary XDR structs to be included within a
    # transactions `operations` array.
    #
    # @see VIXAL::Asset
    #
    # @param [Hash] attributes the attributes to create the operation with
    # @option attributes [VIXAL::KeyPair] :destination the receiver of the payment
    # @option attributes [Array] :amount the amount to pay
    # @option attributes [Array] :with the source asset and maximum allowed source amount to pay with
    # @option attributes [Array<VIXAL::Asset>] :path the payment path to use
    #
    # @return [VIXAL::Operation] the built operation, containing a
    #                              VIXAL::PaymentOp body
    def self.path_payment(attributes={})
      destination             = attributes[:destination]
      asset, amount           = extract_amount(attributes[:amount])
      send_asset, send_max    = extract_amount(attributes[:with])
      path                    = (attributes[:path] || []).map{|p| VIXAL::Asset.send(*p)}

      raise ArgumentError unless destination.is_a?(KeyPair)

      op               = PathPaymentOp.new
      op.send_asset    = send_asset
      op.send_max      = send_max
      op.destination   = destination.account_id
      op.dest_asset    = asset
      op.dest_amount   = amount
      op.path          = path

      return make(attributes.merge({
        body:[:path_payment, op]
      }))
    end

    def self.create_account(attributes={})
      destination      = attributes[:destination]
      starting_balance = interpret_amount(attributes[:starting_balance])

      raise ArgumentError unless destination.is_a?(KeyPair)

      op = CreateAccountOp.new()
      op.destination = destination.account_id
      op.starting_balance = starting_balance

      return make(attributes.merge({
        body:[:create_account, op]
      }))
    end

    #
    # Helper method to create a valid ChangeTrustOp, wrapped
    # in the necessary XDR structs to be included within a
    # transactions `operations` array.
    #
    # @param [Hash] attributes the attributes to create the operation with
    # @option attributes [VIXAL::Currrency] :line the asset to trust
    # @option attributes [Fixnum] :limit the maximum amount to trust
    #
    # @return [VIXAL::Operation] the built operation, containing a
    #                              VIXAL::ChangeTrustOp body
    def self.change_trust(attributes={})
      line  = Asset.send(*attributes[:line])
      limit =interpret_amount(attributes[:limit])

      raise ArgumentError, "Bad :limit #{limit}" unless limit.is_a?(Integer)

      op = ChangeTrustOp.new(line: line, limit: limit)

      return make(attributes.merge({
        body:[:change_trust, op]
      }))
    end

    def self.manage_offer(attributes={})
      buying     = Asset.send(*attributes[:buying])
      selling    = Asset.send(*attributes[:selling])
      amount     = interpret_amount(attributes[:amount])
      offer_id   = attributes[:offer_id] || 0
      price      = interpret_price(attributes[:price])

      op = ManageOfferOp.new({
        buying:     buying,
        selling:    selling,
        amount:     amount,
        price:      price,
        offer_id:   offer_id
      })

      return make(attributes.merge({
        body:[:manage_offer, op]
      }))
    end

    def self.create_passive_offer(attributes={})
      buying     = Asset.send(*attributes[:buying])
      selling    = Asset.send(*attributes[:selling])
      amount     = interpret_amount(attributes[:amount])
      price      = interpret_price(attributes[:price])

      op = CreatePassiveOfferOp.new({
        buying:     buying,
        selling:    selling,
        amount:     amount,
        price:      price,
      })

      return make(attributes.merge({
        body:[:create_passive_offer, op]
      }))
    end

    #
    # Helper method to create a valid SetOptionsOp, wrapped
    # in the necessary XDR structs to be included within a
    # transactions `operations` array.
    #
    # @param [Hash] attributes the attributes to create the operation with
    # @option attributes [VIXAL::KeyPair] :inflation_dest
    # @option attributes [Array<VIXAL::AccountFlags>] :set flags to set
    # @option attributes [Array<VIXAL::AccountFlags>] :clear flags to clear
    # @option attributes [String] :thresholds
    # @option attributes [VIXAL::Signer] :signer
    #
    # @return [VIXAL::Operation] the built operation, containing a
    #                              VIXAL::SetOptionsOp body
    def self.set_options(attributes={})
      op                = SetOptionsOp.new()
      op.set_flags      = VIXAL::AccountFlags.make_mask attributes[:set]
      op.clear_flags    = VIXAL::AccountFlags.make_mask attributes[:clear]
      op.master_weight  = attributes[:master_weight]
      op.low_threshold  = attributes[:low_threshold]
      op.med_threshold  = attributes[:med_threshold]
      op.high_threshold = attributes[:high_threshold]

      op.signer      = attributes[:signer]
      op.home_domain = attributes[:home_domain]


      inflation_dest = attributes[:inflation_dest]
      if inflation_dest
        raise ArgumentError, "Bad :inflation_dest" unless inflation_dest.is_a?(VIXAL::KeyPair)
        op.inflation_dest = inflation_dest.account_id
      end


      return make(attributes.merge({
        body:[:set_options, op]
      }))
    end

    #
    # Helper method to create a valid AllowTrustOp, wrapped
    # in the necessary XDR structs to be included within a
    # transactions `operations` array.
    #
    # @param [Hash] attributes the attributes to create the operation with
    # @option attributes [VIXAL::KeyPair]  :trustor
    # @option attributes [VIXAL::Asset] :asset
    #
    # @return [VIXAL::Operation] the built operation, containing a
    #                              VIXAL::AllowTrustOp body
    def self.allow_trust(attributes={})
      op = AllowTrustOp.new()

      trustor   = attributes[:trustor]
      authorize = attributes[:authorize]
      asset     = Asset.send(*attributes[:asset])

      raise ArgumentError, "Bad :trustor" unless trustor.is_a?(VIXAL::KeyPair)
      raise ArgumentError, "Bad :authorize" unless authorize == !!authorize # check boolean
      raise ArgumentError, "Bad :asset" unless asset.type == VIXAL::AssetType.asset_type_credit_alphanum4

      atc = AllowTrustOp::Asset.new(:asset_type_credit_alphanum4, asset.code)

      op.trustor   = trustor.account_id
      op.authorize = authorize
      op.asset     = atc

      return make(attributes.merge({
        body:[:allow_trust, op]
      }))
    end

    #
    # Helper method to create an account merge operation
    #
    # @param [Hash] attributes the attributes to create the operation with
    # @option attributes [VIXAL::KeyPair]  :destination
    #
    # @return [VIXAL::Operation] the built operation
    def self.account_merge(attributes={})
      destination = attributes[:destination]

      raise ArgumentError, "Bad :destination" unless destination.is_a?(KeyPair)

      # TODO: add source_account support
      return make(attributes.merge({
        body:[:account_merge, destination.account_id]
      }))
    end

    #
    # Helper method to create an inflation operation
    #
    # @param [Hash] attributes the attributes to create the operation with
    # @option attributes [Integer]  :sequence
    #
    # @return [VIXAL::Operation] the built operation
    def self.inflation(attributes={})
      sequence = attributes[:sequence]

      raise ArgumentError, "Bad :sequence #{sequence}" unless sequence.is_a?(Integer)

      # TODO: add source_account support
      return make(attributes.merge({
        body:[:inflation]
      }))
    end

    #
    # Helper method to create an manage data operation
    #
    # @param [Hash] attributes the attributes to create the operation with
    # @option attributes [Integer]  :sequence
    #
    # @return [VIXAL::Operation] the built operation
    def self.manage_data(attributes={})
      op = ManageDataOp.new()

      name  = attributes[:name]
      value = attributes[:value]

      raise ArgumentError, "Invalid :name" unless name.is_a?(String)
      raise ArgumentError, ":name too long" unless name.bytesize <= 64

      if value.present?
        raise ArgumentError, ":value too long" unless value.bytesize <= 64
      end

      op.data_name  = name
      op.data_value = value

      return make(attributes.merge({
        body:[:manage_data, op]
      }))
    end

    private
    def self.extract_amount(a)
      amount   = interpret_amount(a.last)
      asset    = VIXAL::Asset.send(*a[0...-1])

      return asset, amount
    end

    def self.interpret_amount(amount)
      case amount
      when String
        (BigDecimal.new(amount) * VIXAL::ONE).floor
      when Integer
        amount * VIXAL::ONE
      when Numeric
        (amount * VIXAL::ONE).floor
      else
        raise ArgumentError, "Invalid amount type: #{amount.class}. Must be String or Numeric"
      end
    end


    def self.interpret_price(price)
      case price
      when String
        bd = BigDecimal.new(price)
        Price.from_f(bd)
      when Numeric
        Price.from_f(price)
      when VIXAL::Price
        price
      else
        raise ArgumentError, "Invalid price type: #{price.class}. Must be String, Numeric, or VIXAL::Price"
      end
    end
  end
end
