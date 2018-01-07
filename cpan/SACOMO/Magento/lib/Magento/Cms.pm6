use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Cms;

proto sub cms-block(|) is export {*}
# GET    /V1/cmsBlock/:blockId
our multi cms-block(
    Hash $config,
    Int  :$block_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "cmsBlock/$block_id";
}

# POST   /V1/cmsBlock
our multi cms-block(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "cmsBlock",
        content => to-json $data;
}

# PUT    /V1/cmsBlock/:id
our multi cms-block(
    Hash $config,
    Int  :$block_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "cmsBlock/$block_id",
        content => to-json $data;
}

# DELETE /V1/cmsBlock/:blockId
our sub cms-block-delete(
    Hash $config,
    Int  :$block_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "cmsBlock/$block_id";
}

# GET    /V1/cmsBlock/search
our sub cms-block-search(
    Hash $config,
    Hash :$search_criteria = %{}
) is export {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "cmsBlock/search?$query_string";
}

proto sub cms-page(|) is export {*}
# GET    /V1/cmsPage/:pageId
our multi cms-page(
    Hash $config,
    Int  :$page_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "cmsPage/$page_id";
}

# POST   /V1/cmsPage
our multi cms-page(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "cmsPage",
        content => to-json $data;
}

# PUT    /V1/cmsPage/:id
our multi cms-page(
    Hash $config,
    Int  :$page_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "cmsPage/$page_id",
        content => to-json $data;
}

# DELETE /V1/cmsPage/:pageId
our sub cms-page-delete(
    Hash $config,
    Int  :$page_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "cmsPage/$page_id";
}

# GET    /V1/cmsPage/search
our sub cms-page-search(
    Hash $config,
    Hash :$search_criteria = %{}
) is export {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "cmsPage/search?$query_string";
}

