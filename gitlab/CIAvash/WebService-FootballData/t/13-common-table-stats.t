use v6;
use Test;
use WebService::FootballData::Role::CommonTableStats;

plan 11;

lives-ok {
    class A does WebService::FootballData::Role::CommonTableStats {}
}, 'Class does WebService::FootballData::Role::CommonTableStats';
my $obj = A.new;
can-ok $obj, 'goals_for';
isa-ok $obj.goals_for, Int;
can-ok $obj, 'goals_against';
isa-ok $obj.goals_against, Int;
can-ok $obj, 'wins';
isa-ok $obj.wins, Int;
can-ok $obj, 'draws';
isa-ok $obj.draws, Int;
can-ok $obj, 'losses';
isa-ok $obj.losses, Int;