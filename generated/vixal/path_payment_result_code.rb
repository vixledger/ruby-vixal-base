# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum PathPaymentResultCode {
#       // codes considered as "success" for the operation
#       PATH_PAYMENT_SUCCESS = 0, // success
#   
#       // codes considered as "failure" for the operation
#       PATH_PAYMENT_MALFORMED = -1,          // bad input
#       PATH_PAYMENT_UNDERFUNDED = -2,        // not enough funds in source account
#       PATH_PAYMENT_SRC_NO_TRUST = -3,       // no trust line on source account
#       PATH_PAYMENT_SRC_NOT_AUTHORIZED = -4, // source not authorized to transfer
#       PATH_PAYMENT_NO_DESTINATION = -5,     // destination account does not exist
#       PATH_PAYMENT_NO_TRUST = -6,           // dest missing a trust line for asset
#       PATH_PAYMENT_NOT_AUTHORIZED = -7,     // dest not authorized to hold asset
#       PATH_PAYMENT_LINE_FULL = -8,          // dest would go above their limit
#       PATH_PAYMENT_NO_ISSUER = -9,          // missing issuer on one asset
#       PATH_PAYMENT_TOO_FEW_OFFERS = -10,    // not enough offers to satisfy path
#       PATH_PAYMENT_OFFER_CROSS_SELF = -11,  // would cross one of its own offers
#       PATH_PAYMENT_OVER_SENDMAX = -12       // could not satisfy sendmax
#   };
#
# ===========================================================================
module Vixal
  class PathPaymentResultCode < XDR::Enum
    member :path_payment_success,            0
    member :path_payment_malformed,          -1
    member :path_payment_underfunded,        -2
    member :path_payment_src_no_trust,       -3
    member :path_payment_src_not_authorized, -4
    member :path_payment_no_destination,     -5
    member :path_payment_no_trust,           -6
    member :path_payment_not_authorized,     -7
    member :path_payment_line_full,          -8
    member :path_payment_no_issuer,          -9
    member :path_payment_too_few_offers,     -10
    member :path_payment_offer_cross_self,   -11
    member :path_payment_over_sendmax,       -12

    seal
  end
end
