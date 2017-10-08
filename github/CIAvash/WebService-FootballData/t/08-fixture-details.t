use v6;
use Test;
use WebService::FootballData::Fixtures::FixtureDetails;

plan 4;

my $obj = WebService::FootballData::Fixtures::FixtureDetails.new;
can-ok $obj, 'fixture';
isa-ok $obj.fixture, WebService::FootballData::Fixtures::Fixture;
can-ok $obj, 'head2head';
isa-ok $obj.head2head, WebService::FootballData::Fixtures::Head2Head;
