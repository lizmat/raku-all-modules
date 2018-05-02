use v6;
use Test;
use WebService::FootballData::League::Table;
use WebService::FootballData::League::Table::Row;

plan 8;

my $obj = WebService::FootballData::League::Table.new;
can-ok $obj, 'links';
isa-ok $obj.links, Hash;
can-ok $obj, 'name';
isa-ok $obj.name, Str;
can-ok $obj, 'matchday';
isa-ok $obj.matchday, Int;
can-ok $obj, 'rows';
isa-ok $obj.rows, Array[WebService::FootballData::League::Table::Row];