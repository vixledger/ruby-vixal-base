# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct {
#          uint64 sequence;
#          VixalMessage message;
#          HmacSha256Mac mac;
#       }
#
# ===========================================================================
module Vixal
  class AuthenticatedMessage
    class V0 < XDR::Struct
      attribute :sequence, Uint64
      attribute :message,  VixalMessage
      attribute :mac,      HmacSha256Mac
    end
  end
end
