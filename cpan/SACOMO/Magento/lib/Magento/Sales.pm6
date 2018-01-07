use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Sales;

proto sub orders(|) is export {*}
# GET    /V1/orders/:id
our multi orders(
    Hash $config,
    Int  :$id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "orders/$id";
}

# GET    /V1/orders
our multi orders(
    Hash $config,
    Hash :$search_criteria = %{}
) {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "orders?$query_string";
}

# PUT    /V1/orders/:parent_id
our multi orders(
    Hash $config,
    Int  :$parent_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "orders/$parent_id",
        content => to-json $data;
}

# GET    /V1/orders/:id/statuses
our sub orders-statuses(
    Hash $config,
    Int  :$id!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "orders/$id/statuses";
}

# POST   /V1/orders/:id/cancel
our sub orders-cancel(
    Hash $config,
    Int  :$id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "orders/$id/cancel",
        content => to-json $data;
}

# POST   /V1/orders/:id/emails
our sub orders-emails(
    Hash $config,
    Int  :$id!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "orders/$id/emails",
        content => '';
}

# POST   /V1/orders/:id/hold
our sub orders-hold(
    Hash $config,
    Int  :$id!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "orders/$id/hold",
        content => to-json '';
}

# POST   /V1/orders/:id/unhold
our sub orders-unhold(
    Hash $config,
    Int  :$id!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "orders/$id/unhold",
        content => '';
}

proto sub orders-comments(|) is export {*}
# POST   /V1/orders/:id/comments
our multi orders-comments(
    Hash $config,
    Int  :$id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "orders/$id/comments",
        content => to-json $data;
}

# GET    /V1/orders/:id/comments
our multi orders-comments(
    Hash $config,
    Int  :$id!,
    Hash :$search_criteria = %{}
) {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "orders/$id/comments?$query_string";
}

# PUT    /V1/orders/create
our sub orders-create(
    Hash $config,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "orders/create",
        content => to-json $data;
}

proto sub orders-items(|) is export {*}
# GET    /V1/orders/items/:id
our multi orders-items(
    Hash $config,
    Int  :$id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "orders/items/$id";
}

# GET    /V1/orders/items
our multi orders-items(
    Hash $config,
    Hash :$search_criteria = %{}
) {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "orders/items?$query_string";
}

proto sub invoices(|) is export {*}
# GET    /V1/invoices/:id
our multi invoices(
    Hash $config,
    Int  :$id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "invoices/$id";
}

# GET    /V1/invoices
our multi invoices(
    Hash $config,
    Hash :$search_criteria = %{}
) {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "invoices?$query_string";
}

# POST   /V1/invoices/
our multi invoices(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "invoices/",
        content => to-json $data;
}

proto sub invoices-comments(|) is export {*}
# GET    /V1/invoices/:id/comments
our multi invoices-comments(
    Hash $config,
    Int  :$id!,
    Hash :$search_criteria = %{}
) {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "invoices/$id/comments?$query_string";
}

# POST   /V1/invoices/:id/emails
our sub invoices-emails(
    Hash $config,
    Int  :$id!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "invoices/$id/emails",
        content => '';
}

# POST   /V1/invoices/:id/void
our sub invoices-void(
    Hash $config,
    Int  :$id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "invoices/$id/void",
        content => to-json $data;
}

# POST   /V1/invoices/:id/capture
our sub invoices-capture(
    Hash $config,
    Int  :$id!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "invoices/$id/capture",
        content => '';
}

# POST   /V1/invoices/comments
our multi invoices-comments(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "invoices/comments",
        content => to-json $data;
}

proto sub creditmemo-comments(|) is export {*}
# GET    /V1/creditmemo/:id/comments
our multi creditmemo-comments(
    Hash $config,
    Int  :$id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "creditmemo/$id/comments";
}

# GET    /V1/creditmemos
our sub creditmemos(
    Hash $config,
    Hash :$search_criteria = %{}
) is export {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "creditmemos?$query_string";
}

proto sub creditmemo(|) is export {*}
# GET    /V1/creditmemo/:id
our multi creditmemo(
    Hash $config,
    Int  :$id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "creditmemo/$id";
}

# PUT    /V1/creditmemo/:id
our multi creditmemo(
    Hash $config,
    Int  :$id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "creditmemo/$id",
        content => to-json $data;
}

# POST   /V1/creditmemo/:id/emails
our sub creditmemo-emails(
    Hash $config,
    Int  :$id!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "creditmemo/$id/emails",
        content => '';
}

# POST   /V1/creditmemo/:id/comments
our multi creditmemo-comments(
    Hash $config,
    Int  :$id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "creditmemo/$id/comments",
        content => to-json $data;
}

# POST   /V1/creditmemo
our multi creditmemo(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "creditmemo",
        content => to-json $data;
}

proto sub shipment(|) is export {*}
# GET    /V1/shipment/:id
our multi shipment(
    Hash $config,
    Int  :$id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "shipment/$id";
}

# GET    /V1/shipments
our sub shipments(
    Hash $config,
    Hash :$search_criteria = %{}
) is export {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "shipments?$query_string";
}

proto sub shipment-comments(|) is export {*}
# GET    /V1/shipment/:id/comments
our multi shipment-comments(
    Hash $config,
    Int  :$id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "shipment/$id/comments";
}

# POST   /V1/shipment/:id/comments
our multi shipment-comments(
    Hash $config,
    Int  :$id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "shipment/$id/comments",
        content => to-json $data;
}

# POST   /V1/shipment/:id/emails
our sub shipment-emails(
    Hash $config,
    Int  :$id!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "shipment/$id/emails",
        content => '';
}

proto sub shipment-track(|) is export {*}
# POST   /V1/shipment/track
our multi shipment-track(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "shipment/track",
        content => to-json $data;
}

# DELETE /V1/shipment/track/:id
our sub shipment-track-delete(
    Hash $config,
    Int  :$id!
) is export {
    my $response = Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "shipment/track/$id";
    return $response.Int||$response;
}

# POST   /V1/shipment/
our multi shipment(
    Hash $config,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "shipment/",
        content => to-json $data;
}

# GET    /V1/shipment/:id/label
our sub shipment-label(
    Hash $config,
    Int  :$id!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "shipment/$id/label";
}

# POST   /V1/orders/
our multi orders(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "orders/",
        content => to-json $data;
}

proto sub transactions(|) is export {*}
# GET    /V1/transactions/:id
our multi transactions(
    Hash $config,
    Int  :$id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "transactions/$id";
}

# GET    /V1/transactions
our multi transactions(
    Hash $config,
    Hash :$search_criteria = %{}
) {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "transactions?$query_string";
}

# POST /V1/order/:orderId/invoice
our sub order-invoice(
    Hash $config,
    Int  :$order_id!,
    Hash :$data!
) is export {
    my $results = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "order/$order_id/invoice",
        content => to-json $data;
    return $results.Int||$results;
}

# POST /V1/order/:orderId/ship
our sub order-ship(
    Hash $config,
    Int  :$order_id!,
    Hash :$data!
) is export {
    my $results = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "order/$order_id/ship",
        content => to-json $data;
    return $results.Int||$results;
}

# POST /V1/invoice/:invoiceId/refund
our sub invoice-refund(
    Hash $config,
    Int  :$invoice_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "invoice/$invoice_id/refund",
        content => to-json $data;
}

# POST /V1/order/:orderId/refund
our sub order-refund(
    Hash $config,
    Int  :$order_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "order/$order_id/refund",
        content => to-json $data;
}

