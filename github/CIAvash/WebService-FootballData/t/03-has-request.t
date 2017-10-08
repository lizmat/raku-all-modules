use v6;
use Test;
use WebService::FootballData::Role::HasRequest;

plan 3;

lives-ok {
    class A does WebService::FootballData::Role::HasRequest {}
}, 'Class does WebService::FootballData::Role::HasRequest';
ok A.^get_attribute_for_usage('$!request').required, 'request attribute is required';
ok WebService::FootballData::Role::HasRequest.can('request'), 'Has request method';