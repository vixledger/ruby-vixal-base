# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct {
#           ClaimOfferAtom offers<>;
#           SimplePaymentResult last;
#       }
#
# ===========================================================================
module Vixal
  class PathPaymentResult
    class Success < XDR::Struct
      attribute :offers, XDR::VarArray[ClaimOfferAtom]
      attribute :last,   SimplePaymentResult
    end
  end
end
