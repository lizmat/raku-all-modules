use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::CatalogInventory;

# PUT    /V1/products/:productSku/stockItems/:itemId
our sub products-stock-items(
    Hash $config,
    Str  :$product_sku!,
    Int  :$item_id!,
    Hash :$data!
) is export {
    my $results = Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "products/$product_sku/stockItems/$item_id",
        content => to-json $data;
    return $results.Int||$results;
}

# GET    /V1/stockItems/:productSku
our sub stock-items(
    Hash $config,
    Str  :$product_sku!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "stockItems/$product_sku";
}

# GET    /V1/stockItems/lowStock/
our sub stock-items-low-stock(
    Hash $config,
    Int  :$scope_id     = 0,
    Int  :$qty          = 1,
    Int  :$page_size    = 1,
    Int  :$current_page = 1
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "stockItems/lowStock/?scopeId=$scope_id&qty=$qty&pageSize=$page_size&currentPage=$current_page";
}

# GET    /V1/stockStatuses/:productSku
our sub stock-statuses(
    Hash $config,
    Str  :$product_sku!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "stockStatuses/$product_sku";
}

