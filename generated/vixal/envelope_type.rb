# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum EnvelopeType {
#       ENVELOPE_TYPE_SCP = 1,
#       ENVELOPE_TYPE_TX = 2,
#       ENVELOPE_TYPE_AUTH = 3
#   };
#
# ===========================================================================
module Vixal
  class EnvelopeType < XDR::Enum
    member :envelope_type_scp,  1
    member :envelope_type_tx,   2
    member :envelope_type_auth, 3

    seal
  end
end
