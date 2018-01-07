use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Store;

# GET    /V1/store/storeViews
our sub store-store-views(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "store/storeViews";
}

# GET    /V1/store/storeGroups
our sub store-store-groups(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "store/storeGroups";
}

# GET    /V1/store/websites
our sub store-websites(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "store/websites";
}

# GET    /V1/store/storeConfigs
our sub store-store-configs(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "store/storeConfigs";
}

