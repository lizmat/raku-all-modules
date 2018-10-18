use v6;
use lib 'lib';
use Test;

[
    'WebService::SOP::V1_1',
    'WebService::SOP::V1_1::Util',
    'WebService::SOP::V1_1::Request::GET',
    'WebService::SOP::V1_1::Request::POST',
    'WebService::SOP::V1_1::Request::POST_JSON',
].map(-> $module { use-ok $module, $module });

done-testing;
