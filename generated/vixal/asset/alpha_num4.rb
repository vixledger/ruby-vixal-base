# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   struct {
#           opaque assetCode[4]; // 1 to 4 characters
#           AccountID issuer;
#       }
#
# ===========================================================================
module Vixal
  class Asset
    class AlphaNum4 < XDR::Struct
      attribute :asset_code, XDR::Opaque[4]
      attribute :issuer,     AccountID
    end
  end
end
