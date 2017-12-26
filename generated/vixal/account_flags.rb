# This code was automatically generated using xdrgen
# DO NOT EDIT or your changes may be overwritten

require 'xdr'

# === xdr source ============================================================
#
#   enum AccountFlags { // masks for each flag
#   
#       // Flags set on issuer accounts
#       // TrustLines are created with authorized set to "false" requiring
#       // the issuer to set it for each TrustLine
#       AUTH_REQUIRED_FLAG = 0x1,
#       // If set, the authorized flag in TrustLines can be cleared
#       // otherwise, authorization cannot be revoked
#       AUTH_REVOCABLE_FLAG = 0x2,
#       // Once set, causes all AUTH_* flags to be read-only
#       AUTH_IMMUTABLE_FLAG = 0x4
#   };
#
# ===========================================================================
module Vixal
  class AccountFlags < XDR::Enum
    member :auth_required_flag,  1
    member :auth_revocable_flag, 2
    member :auth_immutable_flag, 4

    seal
  end
end
