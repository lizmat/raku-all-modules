use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Tax;

proto sub tax-classes(|) is export {*}
# POST   /V1/taxClasses
our multi tax-classes(
    Hash $config,
    Hash :$data!
) {
    my $results = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "taxClasses",
        content => to-json $data;
    return $results.Int||$results;
}

# GET    /V1/taxClasses/:taxClassId
our multi tax-classes(
    Hash $config,
    Int  :$tax_class_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "taxClasses/$tax_class_id";
}

# PUT    /V1/taxClasses/:classId
our multi tax-classes(
    Hash $config,
    Int  :$class_id!,
    Hash :$data!
) {
    my $results = Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "taxClasses/$class_id",
        content => to-json $data;
    return $results.Int||$results;
}

# DELETE /V1/taxClasses/:taxClassId
our sub tax-classes-delete(
    Hash $config,
    Int  :$tax_class_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "taxClasses/$tax_class_id";
}

# GET    /V1/taxClasses/search
our sub tax-classes-search(
    Hash $config,
    Hash :$search_criteria = %{}
) is export {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "taxClasses/search?$query_string";
}

proto sub tax-rates(|) is export {*}
# POST   /V1/taxRates
our multi tax-rates(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "taxRates",
        content => to-json $data;
}

# GET    /V1/taxRates/:rateId
our multi tax-rates(
    Hash $config,
    Int  :$rate_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "taxRates/$rate_id";
}

# PUT    /V1/taxRates
our multi tax-rates(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "taxRates",
        content => to-json $data;
}

# DELETE /V1/taxRates/:rateId
our sub tax-rates-delete(
    Hash $config,
    Int  :$rate_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "taxRates/$rate_id";
}

# GET    /V1/taxRates/search
our sub tax-rates-search(
    Hash $config,
    Hash :$search_criteria = %{}
) is export {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "taxRates/search?$query_string";
}

proto sub tax-rules(|) is export {*}
# POST   /V1/taxRules
our multi tax-rules(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "taxRules",
        content => to-json $data;
}

# PUT    /V1/taxRules
our multi tax-rules(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "taxRules",
        content => to-json $data;
}

# DELETE /V1/taxRules/:ruleId
our sub tax-rules-delete(
    Hash $config,
    Int  :$rule_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "taxRules/$rule_id";
}

# GET    /V1/taxRules/:ruleId
our multi tax-rules(
    Hash $config,
    Int  :$rule_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "taxRules/$rule_id";
}

# GET    /V1/taxRules/search
our sub tax-rules-search(
    Hash $config,
    Hash :$search_criteria = %{}
) is export {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "taxRules/search?$query_string";
}

