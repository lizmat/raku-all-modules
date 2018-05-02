use v6;
use Test;
use WebService::FootballData::Team::Player;

plan 20;

my $obj = WebService::FootballData::Team::Player.new;
can-ok $obj, 'name';
isa-ok $obj.name, Str;
can-ok $obj, 'position';
isa-ok $obj.position, Str;
can-ok $obj, 'number';
isa-ok $obj.number, Int;
can-ok $obj, 'nationality';
isa-ok $obj.nationality, Str;
can-ok $obj, 'birth_date';
isa-ok $obj.birth_date, Date;
can-ok $obj, 'contract_date';
isa-ok $obj.contract_date, Date;
can-ok $obj, 'market_value';
isa-ok $obj.market_value, Str;
can-ok $obj, 'age';

# .age method
my Date $today .= today;
# Create a date for 20 years ago
my Date $twenty_years_ago = $today.earlier: :20years;
is $obj.clone(:birth_date($twenty_years_ago)).age, 20, 'Age on birthday is correct';
is $obj.clone(:birth_date($twenty_years_ago.later(:1month))).age, 19, 'Age a month before birthday is correct';
is $obj.clone(:birth_date($twenty_years_ago.later(:1day))).age, 19, 'Age on the day before birthday is correct';
is $obj.clone(:birth_date($twenty_years_ago.earlier(:1month))).age, 20, 'Age a month after birthday is correct';
is $obj.clone(:birth_date($twenty_years_ago.earlier(:1day))).age, 20, 'Age on the day after birthday is correct';
