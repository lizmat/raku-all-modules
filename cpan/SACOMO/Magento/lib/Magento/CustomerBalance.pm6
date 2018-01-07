use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::CustomerBalance;

# POST   /V1/carts/mine/balance/apply
our sub carts-mine-balance-apply(
    Hash $config,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/mine/balance/apply",
        content => to-json $data;
}

