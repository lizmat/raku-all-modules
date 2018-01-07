use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Customer;

proto sub customer-groups(|) is export {*}
#GET    /V1/customerGroups/:id
our multi customer-groups(
    Hash $config,
    Int  :$id
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customerGroups/$id"
}

#POST    /V1/customerGroups
our multi customer-groups(
    Hash $config,
    Hash :$data
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "customerGroups",
        content => to-json $data;
}

#PUT    /V1/customerGroups/:id
our multi customer-groups(
    Hash $config,
    Int  :$id,
    Hash :$data
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "customerGroups/$id",
        content => to-json $data;
}


proto sub customer-groups-default(|) is export {*}
#GET    /V1/customerGroups/default/:storeId
our multi customer-groups-default(
    Hash $config,
    Int  :$store_id
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customerGroups/default/$store_id"
}

#GET    /V1/customerGroups/default
our multi customer-groups-default(
    Hash $config
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customerGroups/default"
}

#GET    /V1/customerGroups/:id/permissions
our sub customer-groups-permissions(
    Hash $config,
    Int  :$id
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customerGroups/$id/permissions"
}

#GET    /V1/customerGroups/search
our sub customer-groups-search(
    Hash $config,
    Hash :$search_criteria
) is export {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customerGroups/search?$query_string"
}

#DELETE /V1/customerGroups/:id
our sub customer-groups-delete(
    Hash $config,
    Int  :$id
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "customerGroups/$id"
}

#GET    /V1/attributeMetadata/customer/attribute/:attributeCode
our sub customer-metadata-attribute(
    Hash $config,
    Str :$attribute_code
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "attributeMetadata/customer/attribute/$attribute_code"
}

#GET    /V1/attributeMetadata/customer/form/:formCode
our sub customer-metadata-form(
    Hash $config,
    Str :$form_code
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "attributeMetadata/customer/form/$form_code"
}

#GET    /V1/attributeMetadata/customer
our sub customer-metadata(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "attributeMetadata/customer"
}

#GET    /V1/attributeMetadata/customer/custom
our sub customer-metadata-custom(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "attributeMetadata/customer/custom"
}

#GET    /V1/attributeMetadata/customerAddress/attribute/:attributeCode
our sub customer-address-attribute(
    Hash $config,
    Str :$attribute_code
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "attributeMetadata/customerAddress/attribute/$attribute_code"
}

#GET    /V1/attributeMetadata/customerAddress/form/:formCode
our sub customer-address-form(
    Hash $config,
    Str :$form_code
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "attributeMetadata/customerAddress/form/$form_code"
}

#GET    /V1/attributeMetadata/customerAddress
our sub customer-address(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "attributeMetadata/customerAddress"
}

#GET    /V1/attributeMetadata/customerAddress/custom
our sub customer-address-custom(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "attributeMetadata/customerAddress/custom"
}

#DELETE /V1/customers/:customerId
our sub customers-delete(
    Hash $config,
    Int  :$id
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "customers/$id"
}

#POST   /V1/customers
proto sub customers(|) is export {*}
our multi customers(
    Hash $config,
    Hash :$data
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "customers",
        content => to-json $data;
}
#PUT    /V1/customers/:id
our multi customers(
    Hash $config,
    Int  :$id,
    Hash :$data
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "customers/$id",
        content => to-json $data;
}
#GET    /V1/customers
our multi customers(
    Hash $config
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customers"
}
#GET    /V1/customers/:customerId
our multi customers(
    Hash $config,
    Int  :$id
) {
    Magento::HTTP::request
        method  => 'GET',
        host    => $config<host>,
        uri=> "customers/$id"
}

#PUT    /V1/customers/me/activate
our sub customers-me-activate(
    Hash $config,
    Hash :$data
) is export {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "customers/me/activate",
        content => to-json $data;
}

proto sub customers-me(|) is export {*}
#GET    /V1/customers/me
our multi customers-me(
    Hash $config
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customers/me";
}
#PUT    /V1/customers/me
our multi customers-me(
    Hash $config,
    Hash :$data
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "customers/me",
        content => to-json $data;
}

#PUT    /V1/customers/me/password
our sub customers-me-password(
    Hash $config,
    Hash :$data
) is export {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "customers/me/password",
        content => to-json $data;
}

#GET    /V1/customers/me/billingAddress
our sub customers-me-billing-address(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customers/me/billingAddress";
}

#GET    /V1/customers/me/shippingAddress
our sub customers-me-shipping-address(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customers/me/shippingAddress";
}

#GET    /V1/customers/search
our sub customers-search(
    Hash $config,
    Hash :$search_criteria
) is export {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customers/search?$query_string"
}

#PUT    /V1/customers/:email/activate
our sub customers-email-activate(
    Hash $config,
    Str  :$email,
    Hash :$data
) is export {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "customers/$email/activate",
        content => to-json $data;
}

#GET    /V1/customers/:customerId/password/resetLinkToken/:resetPasswordLinkToken
our sub customers-reset-link-token(
    Hash $config,
    Int  :$id,
    Str  :$link_token
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customers/$id/password/resetLinkToken/$link_token"
}

#PUT    /V1/customers/password
our sub customers-password(
    Hash $config,
    Hash :$data
) is export {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "customers/password",
        content => to-json $data;
}

proto sub customers-confirm(|) is export {*}
#GET    /V1/customers/:customerId/confirm
our multi customers-confirm(
    Hash $config,
    Int  :$id
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customers/$id/confirm"
}
#POST   /V1/customers/confirm
our multi customers-confirm(
    Hash $config,
    Hash :$data
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "customers/confirm",
        content => to-json $data;
}

#PUT    /V1/customers/validate
our sub customers-validate(
    Hash $config,
    Hash :$data
) is export {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "customers/validate",
        content => to-json $data;
}

#GET    /V1/customers/:customerId/permissions/readonly
our sub customers-permissions(
    Hash $config,
    Int  :$id
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customers/$id/permissions/readonly"
}

#POST   /V1/customers/isEmailAvailable
our sub customers-email-available(
    Hash $config,
    Hash :$data
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "customers/isEmailAvailable",
        content => to-json $data;
}

#GET    /V1/customers/addresses/:addressId
our sub customers-addresses(
    Hash $config,
    Int  :$address_id
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customers/addresses/$address_id"
}

#GET    /V1/customers/:customerId/billingAddress
our sub customers-addresses-billing(
    Hash $config,
    Int  :$id
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customers/$id/billingAddress"
}

#GET    /V1/customers/:customerId/shippingAddress
our sub customers-addresses-shipping(
    Hash $config,
    Int  :$id
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "customers/$id/shippingAddress"
}

#DELETE /V1/addresses/:addressId
our sub customers-addresses-delete(
    Hash $config,
    Int  :$address_id
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "addresses/$address_id"
}
