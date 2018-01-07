use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Eav;

proto sub eav-attribute-sets(|) is export {*}
# GET    /V1/eav/attribute-sets/:attributeSetId
our multi eav-attribute-sets(
    Hash $config,
    Int  :$attribute_set_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "eav/attribute-sets/$attribute_set_id";
}

# DELETE /V1/eav/attribute-sets/:attributeSetId
our sub eav-attribute-sets-delete(
    Hash $config,
    Int  :$attribute_set_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "eav/attribute-sets/$attribute_set_id";
}

# POST   /V1/eav/attribute-sets
our multi eav-attribute-sets(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "eav/attribute-sets",
        content => to-json $data;
}

# PUT    /V1/eav/attribute-sets/:attributeSetId
our multi eav-attribute-sets(
    Hash $config,
    Int  :$attribute_set_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "eav/attribute-sets/$attribute_set_id",
        content => to-json $data;
}

# GET    /V1/eav/attribute-sets/list
our sub eav-attribute-sets-list(
    Hash $config,
    Hash :$search_criteria = %{}
) is export {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "eav/attribute-sets/list?$query_string";
}

