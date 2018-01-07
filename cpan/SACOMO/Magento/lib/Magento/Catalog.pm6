use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Catalog;

subset Id of Any where Int|Str;

proto sub products(|) is export {*}
#GET    /V1/products
our multi products(
    Hash $config,
    Hash :$search_criteria = %{}
) {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products?$query_string"
}
#POST   /V1/products
our multi products(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "products",
        content => to-json $data;
}
#PUT    /V1/products/:sku
our multi products(
    Hash $config,
    Str  :$sku!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "products/$sku",
        content => to-json $data;
}
#GET    /V1/products/:sku
our multi products(
    Hash $config,
    Str  :$sku!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/$sku"
}

#DELETE /V1/products/:sku
our sub products-delete(
    Hash $config,
    Str  :$sku!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "products/$sku";
}

#GET    /V1/products/attributes/types
our sub products-attributes-types(
    Hash $config,
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/attributes/types";
}

proto sub products-attributes(|) is export {*}
#GET    /V1/products/attributes/:attribute_code
our multi products-attributes(
    Hash $config,
    Str  :$attribute_code!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/attributes/$attribute_code";
}
#GET    /V1/products/attributes
our multi products-attributes(
    Hash $config,
    Hash :$search_criteria = %{}
) {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/attributes?$query_string";
}
#POST   /V1/products/attributes
our multi products-attributes(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "products/attributes",
        content => to-json $data;
}
#PUT    /V1/products/attributes/:attribute_code
our multi products-attributes(
    Hash $config,
    Str  :$attribute_code!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "products/attributes/$attribute_code",
        content => to-json $data;
}

#DELETE /V1/products/attributes/:attribute_code
our sub products-attributes-delete(
    Hash $config,
    Str  :$attribute_code!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "products/attributes/$attribute_code";
}

proto sub categories-attributes(|) is export {*}
#GET    /V1/categories/attributes
our multi categories-attributes(
    Hash $config,
    Hash :$search_criteria = %{}
) {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "categories/attributes?$query_string";
}
#GET    /V1/categories/attributes/:attribute_code
our multi categories-attributes(
    Hash $config,
    Str  :$attribute_code!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "categories/attributes/$attribute_code";
}

#GET    /V1/categories/attributes/:attribute_code/options
our sub categories-attributes-options(
    Hash $config,
    Str  :$attribute_code!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "categories/attributes/$attribute_code/options";
}

#GET    /V1/products/types
our sub products-types(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/types";
}

proto sub products-attribute-sets(|) is export {*}
#GET    /V1/products/attribute-sets/sets/list
our multi products-attribute-sets(
    Hash $config,
    Hash :$search_criteria = %{}
) {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/attribute-sets/sets/list?$query_string";
}
#GET    /V1/products/attribute-sets/:attribute_set_id
our multi products-attribute-sets(
    Hash $config,
    Int  :$attribute_set_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/attribute-sets/$attribute_set_id";
}
#POST   /V1/products/attribute-sets
our multi products-attribute-sets(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "products/attribute-sets",
        content => to-json $data;
}
#PUT    /V1/products/attribute-sets/:attribute_set_id
our multi products-attribute-sets(
    Hash $config,
    Int  :$attribute_set_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "products/attribute-sets/$attribute_set_id",
        content => to-json $data;
}

#DELETE /V1/products/attribute-sets/:attribute_set_id
our sub products-attribute-sets-delete(
    Hash $config,
    Int  :$attribute_set_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "products/attribute-sets/$attribute_set_id";
}

proto sub products-attribute-sets-attributes(|) is export {*}
#GET    /V1/products/attribute-sets/:attribute_set_id/attributes
our multi products-attribute-sets-attributes(
    Hash $config,
    Int  :$attribute_set_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/attribute-sets/$attribute_set_id/attributes";
}
#POST   /V1/products/attribute-sets/attributes
our multi products-attribute-sets-attributes(
    Hash $config,
    Hash :$data!
) {
    my $response = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "products/attribute-sets/attributes",
        content => to-json $data;
    return $response.Int||$response;
}

#DELETE /V1/products/attribute-sets/:attribute_set_id/attributes/:attribute_code
our sub products-attribute-sets-attributes-delete(
    Hash $config,
    Int  :$attribute_set_id!,
    Str  :$attribute_code!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "products/attribute-sets/$attribute_set_id/attributes/$attribute_code";
}

#GET    /V1/products/attribute-sets/groups/list
proto sub products-attribute-groups(|) is export {*}
our multi products-attribute-groups(
    Hash $config,
    Hash :$search_criteria = %{}
) {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/attribute-sets/groups/list?$query_string";
}
#POST   /V1/products/attribute-sets/groups
our multi products-attribute-groups(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "products/attribute-sets/groups",
        content => to-json $data;
}
#PUT    /V1/products/attribute-sets/:attribute_set_id/groups
our multi products-attribute-groups(
    Hash $config,
    Int  :$attribute_set_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "products/attribute-sets/$attribute_set_id/groups",
        content => to-json $data;
}

#DELETE /V1/products/attribute-sets/groups/:group_id
our sub products-attribute-groups-delete(
    Hash $config,
    Id   :$group_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "products/attribute-sets/groups/$group_id";
}

#GET    /V1/products/attributes/:attribute_code/options
proto sub products-attributes-options(|) is export {*}
our multi products-attributes-options(
    Hash $config,
    Str  :$attribute_code!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/attributes/$attribute_code/options";
}
#POST   /V1/products/attributes/:attribute_code/options
our multi products-attributes-options(
    Hash $config,
    Str  :$attribute_code!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "products/attributes/$attribute_code/options",
        content => to-json $data;
}

#DELETE /V1/products/attributes/:attribute_code/options/:option_id
our sub products-attributes-options-delete(
    Hash $config,
    Str  :$attribute_code!,
    Int  :$option_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "products/attributes/$attribute_code/options/$option_id";
}

#GET    /V1/products/media/types/:attribute_set_name
our sub products-media-types(
    Hash $config,
    Str  :$attribute_set_name!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/media/types/$attribute_set_name";
}

proto sub products-media(|) is export {*}
#GET    /V1/products/:sku/media
our multi products-media(
    Hash $config,
    Str  :$sku!,
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/$sku/media";
}
#GET    /V1/products/:sku/media/:entry_id
our multi products-media(
    Hash $config,
    Str  :$sku!,
    Int  :$entry_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/$sku/media/$entry_id";
}
#POST   /V1/products/:sku/media
our multi products-media(
    Hash $config,
    Str  :$sku!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "products/$sku/media",
        content => to-json $data;
}
#PUT    /V1/products/:sku/media/:entry_id
our multi products-media(
    Hash $config,
    Str  :$sku!,
    Int  :$entry_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "products/$sku/media/$entry_id",
        content => to-json $data;
}

#DELETE /V1/products/:sku/media/:entry_id
our sub products-media-delete(
    Hash $config,
    Str  :$sku!,
    Int  :$entry_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "products/$sku/media/$entry_id";
}

proto sub products-tier-prices(|) is export {*}
#GET    /V1/products/:sku/group-prices/:customer_group_id/tiers
our multi products-tier-prices(
    Hash $config,
    Str  :$sku!,
    Int  :$customer_group_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/$sku/group-prices/$customer_group_id/tiers";
}
#POST   /V1/products/:sku/group-prices/:customer_group_id/tiers/:qty/price/:price
our multi products-tier-prices(
    Hash $config,
    Str  :$sku,
    Int  :$customer_group_id,
    Int  :$qty,
    Real :$price
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "products/$sku/group-prices/$customer_group_id/tiers/$qty/price/$price",
        content => '{}';
}

#DELETE /V1/products/:sku/group-prices/:customer_group_id/tiers/:qty
our sub products-tier-prices-delete(
    Hash $config,
    Str  :$sku,
    Int  :$customer_group_id,
    Int  :$qty
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "products/$sku/group-prices/$customer_group_id/tiers/$qty";
}

proto sub categories(|) is export {*}
#GET    /V1/categories
our multi categories(
    Hash $config,
    Int  :$root_category_id = 1,
    Int  :$depth = 1;
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "categories?rootCategoryId=$root_category_id&depth=$depth";
}
#GET    /V1/categories/:category_id
our multi categories(
    Hash $config,
    Int  :$category_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "categories/$category_id";
}
#POST   /V1/categories
our multi categories(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "categories",
        content => to-json $data;
}
#PUT    /V1/categories/:id
our multi categories(
    Hash $config,
    Int  :$category_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "categories/$category_id",
        content => to-json $data;
}

#DELETE /V1/categories/:category_id
our sub categories-delete(
    Hash $config,
    Int  :$category_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "categories/$category_id";
}

#PUT    /V1/categories/:category_id/move
our sub categories-move(
    Hash $config,
    Int  :$category_id,
    Hash :$data
) is export {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "categories/$category_id/move",
        content => to-json $data;
}

#GET    /V1/products/options/types
our sub products-options-types(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/options/types";
}

proto sub products-custom-options(|) is export {*}
#GET    /V1/products/:sku/options
our multi products-custom-options(
    Hash $config,
    Str  :$sku!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/$sku/options";
}
#GET    /V1/products/:sku/options/:option_id
our multi products-custom-options(
    Hash $config,
    Str  :$sku!,
    Int  :$option_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/$sku/options/$option_id";
}
#POST   /V1/products/options
our multi products-custom-options(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "products/options",
        content => to-json $data;
}
#PUT    /V1/products/options/:option_id
our multi products-custom-options(
    Hash $config,
    Int  :$option_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "products/options/$option_id",
        content => to-json $data;
}

#DELETE /V1/products/:sku/options/:option_id
our sub products-custom-options-delete(
    Hash $config,
    Str  :$sku!,
    Int  :$option_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "products/$sku/options/$option_id";
}

#GET    /V1/products/links/types
our sub products-links-types(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/links/types";
}

#GET    /V1/products/links/:type/attributes
our sub products-links-attributes(
    Hash $config,
    Str  :$type
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/links/$type/attributes";
}

proto sub products-links(|) is export {*}
#GET    /V1/products/:sku/links/:type
our multi products-links(
    Hash $config,
    Str  :$sku!,
    Str  :$type!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/$sku/links/$type";
}
#POST   /V1/products/:sku/links
our multi products-links(
    Hash $config,
    Str  :$sku!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "products/$sku/links",
        content => to-json $data;
}

#PUT    /V1/products/:sku/links
our sub products-links-update(
    Hash $config,
    Str  :$sku!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "products/$sku/links",
        content => to-json $data;
}

#DELETE /V1/products/:sku/links/:type/:linkedProductSku
our sub products-links-delete(
    Hash $config,
    Str  :$sku!,
    Str  :$type!,
    Str  :$linked_product_sku!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "products/$sku/links/$type/$linked_product_sku";
}

proto sub categories-products(|) is export {*}
#GET    /V1/categories/:category_id/products
our multi categories-products(
    Hash $config,
    Int  :$category_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "categories/$category_id/products";
}
#POST   /V1/categories/:category_id/products
our multi categories-products(
    Hash $config,
    Int  :$category_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "categories/$category_id/products",
        content => to-json $data;
}
#PUT    /V1/categories/:category_id/products
our sub categories-products-update(
    Hash $config,
    Int  :$category_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "categories/$category_id/products",
        content => to-json $data;
}

#DELETE /V1/categories/:category_id/products/:sku
our sub categories-products-delete(
    Hash $config,
    Int  :$category_id!,
    Str  :$sku!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "categories/$category_id/products/$sku";
}

#* POST   /V1/products/:sku/websites
our sub products-websites(
    Hash $config,
    Str  :$sku!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "products/$sku/websites",
        content => to-json $data;
}

#* PUT   /V1/products/:sku/websites
our sub products-websites-update(
    Hash $config,
    Str  :$sku!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "products/$sku/websites",
        content => to-json $data;
}

#* DELETE /V1/products/:sku/websites/:website_id
our sub products-websites-delete(
    Hash $config,
    Str  :$sku!,
    Int  :$website_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "products/$sku/websites/$website_id";
}
