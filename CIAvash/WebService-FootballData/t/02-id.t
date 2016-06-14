use v6;
use Test;
use WebService::FootballData::Role::ID;

plan 7;

lives-ok {
    class A does WebService::FootballData::Role::ID {}
}, 'Class does WebService::FootballData::Role::ID';
ok A.^get_attribute_for_usage('%!links').required, 'links attribute is required';
my $a = A.new: links => { self => href => 'some/url/123' };
can-ok $a, 'links';
can-ok $a, 'id';
is $a.id, 123, 'Has the correct id';

lives-ok {
    class B does WebService::FootballData::Role::ID['resource'] {}
}, 'Class does WebService::FootballData::Role::ID with "resource" parameter';
my $b = B.new: links => { resource => href => 'some/url/456' };
is $b.id, 456, 'Has the correct id';