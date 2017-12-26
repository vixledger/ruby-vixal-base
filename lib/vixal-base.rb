require 'xdr'
require 'rbnacl/libsodium'
require 'digest/sha2'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/kernel/reporting'

# See ../generated for code-gen'ed files
silence_warnings do
  require 'vixal-base-generated'
end
VIXAL.load_all!

VIXAL::ONE = 1_0000000


# extensions onto the generated files must be loaded manually, below

require_relative './vixal/account_flags'
require_relative './vixal/asset'
require_relative './vixal/key_pair'
require_relative './vixal/operation'
require_relative './vixal/path_payment_result'
require_relative './vixal/price'
require_relative './vixal/thresholds'
require_relative './vixal/transaction'
require_relative './vixal/transaction_envelope'
require_relative './vixal/util/strkey'
require_relative './vixal/util/continued_fraction'
require_relative './vixal/convert'
require_relative './vixal/networks'
require_relative './vixal/base/version'
