use v6;
use Test;
use WebService::FootballData::TeamSearchResult;

plan 8;

my $obj = WebService::FootballData::TeamSearchResult.new;
can-ok $obj, 'team_id';
isa-ok $obj.team_id, Int;
can-ok $obj, 'team_name';
isa-ok $obj.team_name, Str;
can-ok $obj, 'league_id';
isa-ok $obj.league_id, Int;
can-ok $obj, 'league_short_name';
isa-ok $obj.league_short_name, Str;