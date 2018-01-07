use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Integration;

# integration-token handles both admin
# and customer token. Pass user_type to
# specify.

# POST   /V1/integration/admin/token
our sub integration-token(
    Hash $config,
    Str  :$user_type!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "integration/$user_type/token",
        content => to-json $data;
}
