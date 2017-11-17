use v6;
use Test;
use WebService::FootballData::Role::HasFixtures;

plan 7;

lives-ok {
    class A does WebService::FootballData::Role::HasFixtures {}
}, 'Class does WebService::FootballData::Role::HasFixtures';
my $obj = A.new;
can-ok $obj, 'timeframe_start';
isa-ok $obj.timeframe_start, Date;
can-ok $obj, 'timeframe_end';
isa-ok $obj.timeframe_end, Date;
can-ok $obj, 'fixtures';
isa-ok $obj.fixtures, Array[WebService::FootballData::Fixtures::Fixture];