module Vixal
  class Transaction

    #
    # @see  Vixal::Operation.payment
    def self.payment(attributes={})
      make :payment, attributes
    end

    #
    # @see  Vixal::Operation.path_payment
    def self.path_payment(attributes={})
      make :path_payment, attributes
    end

    #
    # @see  Vixal::Operation.create_account
    def self.create_account(attributes={})
      make :create_account, attributes
    end

    #
    # @see  Vixal::Operation.change_trust
    def self.change_trust(attributes={})
      make :change_trust, attributes
    end

    #
    # @see  Vixal::Operation.create_offer
    def self.manage_offer(attributes={})
      make :manage_offer, attributes
    end

    #
    # @see  Vixal::Operation.create_passive_offer
    def self.create_passive_offer(attributes={})
      make :create_passive_offer, attributes
    end

    #
    # @see  Vixal::Operation.set_options
    def self.set_options(attributes={})
      make :set_options, attributes
    end

    #
    # @see  Vixal::Operation.allow_trust
    def self.allow_trust(attributes={})
      make :allow_trust, attributes
    end

    #
    # @see  Vixal::Operation.account_merge
    def self.account_merge(attributes={})
      make :account_merge, attributes
    end

    #
    # @see  Vixal::Operation.inflation
    def self.inflation(attributes={})
      make :inflation, attributes
    end

    #
    # @see  Vixal::Operation.manage_data
    def self.manage_data(attributes={})
      make :manage_data, attributes
    end

    #
    # Helper method to create a transaction with a single
    # operation of the provided type.  See class methods
    # on Vixal::Operation for available values for
    # operation_type.
    #
    # @see  Vixal::Operation
    #
    # @param operation_type [Symbol] the operation to use
    # @param attributes={} [Hash] attributes to use for both the transaction and the operation
    #
    # @return [Vixal::Transaction] the resulting transaction
    def self.make(operation_type, attributes={})
      for_account(attributes).tap do |result|
        result.operations << Operation.send(operation_type, attributes)
      end
    end


    #
    # Helper method to create the skeleton of a transaction.
    # The resulting transaction will have its source account,
    # sequence, fee, min ledger and max ledger set.
    #
    #
    # @param attributes={} [type] [description]
    #
    # @return [Vixal::Transaction] the resulting skeleton
    def self.for_account(attributes={})
      account  = attributes[:account]
      sequence = attributes[:sequence]
      fee      = attributes[:fee]

      raise ArgumentError, "Bad :account" unless account.is_a?(KeyPair)
      raise ArgumentError, "Bad :sequence #{sequence}" unless sequence.is_a?(Integer)
      raise ArgumentError, "Bad :fee #{sequence}" if fee.present? && !fee.is_a?(Integer)

      new.tap do |result|
        result.seq_num        = sequence
        result.fee            = fee
        result.memo           = make_memo(attributes[:memo])
        result.source_account = account.account_id
        result.apply_defaults
      end
    end

    def sign(key_pair)
      key_pair.sign(hash)
    end

    def sign_decorated(key_pair)
      key_pair.sign_decorated(hash)
    end

    def hash
      Digest::SHA256.digest(signature_base)
    end

    # Returns the string of bytes that, when hashed, provide the value which
    # should be signed to create a valid vixal transaciton signature
    def signature_base
      signature_base_prefix + to_xdr
    end

    def signature_base_prefix
      val = Vixal::EnvelopeType.envelope_type_tx

      Vixal.current_network_id + Vixal::EnvelopeType.to_xdr(val)
    end

    def to_envelope(*key_pairs)
      signatures = (key_pairs || []).map(&method(:sign_decorated))

      TransactionEnvelope.new({
        :signatures => signatures,
        :tx => self
      })
    end

    def merge(other)
      cloned = Marshal.load Marshal.dump(self)
      cloned.operations += other.to_operations
      cloned
    end


    #
    # Extracts the operations from this single transaction,
    # setting the source account on the extracted operations.
    #
    # Useful for merging transactions.
    #
    # @return [Array<Operation>] the operations
    def to_operations
      cloned = Marshal.load Marshal.dump(operations)
      operations.each do |op|
        op.source_account = self.source_account
      end
    end

    def apply_defaults
      self.operations ||= []
      self.fee        ||= 100
      self.memo       ||= Memo.new(:memo_none)
      self.ext        ||= Vixal::Transaction::Ext.new 0
    end

    private
    def self.make_memo(memo)
      case memo
      when Vixal::Memo ;
        memo
      when nil ;
        nil
      when Integer ;
        Memo.new(:memo_id, memo)
      when String ;
        Memo.new(:memo_text, memo)
      when Array ;
        t, val = *memo
        Memo.new(:"memo_#{t}", val)
      else
        raise ArgumentError, "Bad :memo"
      end
    end
  end
end
