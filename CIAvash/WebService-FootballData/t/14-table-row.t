use v6;
use Test;
use WebService::FootballData::League::Table::Row;
use WebService::FootballData::Role::ID;

plan 20;

my $obj = WebService::FootballData::League::Table::Row.new: links => {};
does-ok $obj, WebService::FootballData::Role::ID['team'];
does-ok $obj, WebService::FootballData::Role::CommonTableStats;
can-ok $obj, 'name';
isa-ok $obj.name, Str;
can-ok $obj, 'crest_url';
isa-ok $obj.crest_url, Str;
can-ok $obj, 'position';
isa-ok $obj.position, Int;
can-ok $obj, 'games_played';
isa-ok $obj.games_played, Int;
can-ok $obj, 'goal_difference';
isa-ok $obj.goal_difference, Int;
can-ok $obj, 'points';
isa-ok $obj.points, Int;
can-ok $obj, 'home';
isa-ok $obj.home, WebService::FootballData::League::Table::Row::Home;
does-ok $obj.home, WebService::FootballData::Role::CommonTableStats;
can-ok $obj, 'away';
isa-ok $obj.away, WebService::FootballData::League::Table::Row::Away;
does-ok $obj.away, WebService::FootballData::Role::CommonTableStats;