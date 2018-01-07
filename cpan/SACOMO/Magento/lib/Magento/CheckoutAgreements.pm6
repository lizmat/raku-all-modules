use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::CheckoutAgreements;

# GET    /V1/carts/licence
our sub carts-licence(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/licence";
}

