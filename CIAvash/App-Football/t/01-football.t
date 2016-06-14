use v6;
use Test;
use Test::Output;
use lib 't/lib';
use FakeFootballData;
use App::Football;

plan 26;

ok App::Football.^ver.defined, 'App::Football has version';
can-ok App::Football, 'program_name';
is App::Football.program_name, 'football', 'App::Football has the correct program name';

my $obj = App::Football.new;
can-ok $obj, 'fd';
isa-ok $obj.fd, WebService::FootballData;

my $mancity = q:to/END/;
O--------------------O------------O------O---------------O
| Team               | Short Name | Code | Squad Value   |
O====================O============O======O===============O
| Manchester City FC | ManCity    | MCFC | 510,000,000 € |
----------------------------------------------------------
END

my $mancity_players = q:to/END/;
O---O----------O----------O-----O------------O-------------O----------O--------------O
| # | Player   | Position | Age | Birthdate  | Nationality | Contract | Value        |
O===O==========O==========O=====O============O=============O==========O==============O
| 1 | Joe Hart | Keeper   | 28  | 1987-04-19 | England     | 2019     | 16,000,000 € |
--------------------------------------------------------------------------------------
END

my $fixtures = q:to/END/;
O-----O------------O----O----O--------------------O----------O------------------O
| Day | Home Team  | HG | AG | Away Team          | Status   | Date & Time      |
O=====O============O====O====O====================O==========O==================O
| 34  | Chelsea FC | 0  | 3  | Manchester City FC | FINISHED | 2016-04-16 16:30 |
---------------------------------------------------------------------------------
END

my $fixtures_home_venue = q:to/END/;
O-----O--------------------O----O----O---------------------O----------O------------------O
| Day | Home Team          | HG | AG | Away Team           | Status   | Date & Time      |
O=====O====================O====O====O=====================O==========O==================O
| 8   | Manchester City FC | 1  | 0  | Paris Saint-Germain | FINISHED | 2016-04-12 18:45 |
------------------------------------------------------------------------------------------
END

my $fixtures_n7_timeframe = q:to/END/;
O-----O--------------------O----O----O---------------O--------O------------------O
| Day | Home Team          | HG | AG | Away Team     | Status | Date & Time      |
O=====O====================O====O====O===============O========O==================O
| 35  | Manchester City FC |    |    | Stoke City FC | TIMED  | 2016-04-24 11:00 |
----------------------------------------------------------------------------------
END

my $fixtures_2014_season = q:to/END/;
O-----O---------------------O----O----O--------------------O----------O------------------O
| Day | Home Team           | HG | AG | Away Team          | Status   | Date & Time      |
O=====O=====================O====O====O====================O==========O==================O
| 1   | Newcastle United FC | 0  | 2  | Manchester City FC | FINISHED | 2014-08-17 19:30 |
------------------------------------------------------------------------------------------
END

my $fixtures_league_m5 = q:to/END/;
O-----O-------------------O----O----O--------------------O----------O------------------O
| Day | Home Team         | HG | AG | Away Team          | Status   | Date & Time      |
O=====O===================O====O====O====================O==========O==================O
| 5   | Crystal Palace FC | 0  | 1  | Manchester City FC | FINISHED | 2015-09-12 18:30 |
----------------------------------------------------------------------------------------
END

my $leagues = q:to/END/;
O------------------------O------O--------O----------O-----------O-------O-------O
| League                 | Code | Season | Matchday | Matchdays | Teams | Games |
O========================O======O========O==========O===========O=======O=======O
| Premier League 2015/16 | PL   | 2015   | 34       | 38        | 20    | 380   |
---------------------------------------------------------------------------------
END

my $leagues_2014 = q:to/END/;
O------------------------O------O--------O----------O-----------O-------O-------O
| League                 | Code | Season | Matchday | Matchdays | Teams | Games |
O========================O======O========O==========O===========O=======O=======O
| Premier League 2014/15 | PL   | 2014   |          | 38        | 20    | 380   |
---------------------------------------------------------------------------------
END

my $league_table = q:to/END/;
O-----O-------------------O-----O-----O----O----O----O----O---O---O----O----O----O----O----O----O
| Pos | Team              | Pts | Pld | GF | GA | GD | W  | D | L | HW | HD | HL | AW | AD | AL |
O=====O===================O=====O=====O====O====O====O====O===O===O====O====O====O====O====O====O
| 1   | Leicester City FC | 56  | 27  | 49 | 29 | 20 | 16 | 8 | 3 | 8  | 4  | 1  | 8  | 4  | 2  |
-------------------------------------------------------------------------------------------------
END

my $league_table_m5 = q:to/END/;
O-----O--------------------O-----O-----O----O----O----O---O---O---O----O----O----O----O----O----O
| Pos | Team               | Pts | Pld | GF | GA | GD | W | D | L | HW | HD | HL | AW | AD | AL |
O=====O====================O=====O=====O====O====O====O===O===O===O====O====O====O====O====O====O
| 1   | Manchester City FC | 15  | 5   | 11 | 0  | 11 | 5 | 0 | 0 | 2  | 0  | 0  | 3  | 0  | 0  |
-------------------------------------------------------------------------------------------------
END

my $league_table_2014 = q:to/END/;
O-----O------------O-----O-----O----O----O----O----O---O---O----O----O----O----O----O----O
| Pos | Team       | Pts | Pld | GF | GA | GD | W  | D | L | HW | HD | HL | AW | AD | AL |
O=====O============O=====O=====O====O====O====O====O===O===O====O====O====O====O====O====O
| 1   | Chelsea FC | 87  | 38  | 73 | 32 | 41 | 26 | 9 | 3 | 15 | 4  | 0  | 11 | 5  | 3  |
------------------------------------------------------------------------------------------
END

my $all_fixtures_pl_cl = q:to/END/;
O-----O--------------------O----O----O---------------------O----------O------------------O
| Day | Home Team          | HG | AG | Away Team           | Status   | Date & Time      |
O=====O====================O====O====O=====================O==========O==================O
| 8   | Manchester City FC | 1  | 0  | Paris Saint-Germain | FINISHED | 2016-04-12 18:45 |
| 34  | Chelsea FC         | 0  | 3  | Manchester City FC  | FINISHED | 2016-04-16 16:30 |
------------------------------------------------------------------------------------------
END

# Set local timezone to zero for testing Date & Time
my $*TZ = 0;

my $f = App::Football.new: :fd(FakeFootballData.new);

stdout-is { $f.team: 'mancity' }, $mancity, 'Team output is correct';

stdout-is { $f.team_players: 'mancity' }, $mancity ~ $mancity_players, 'Team Players output is correct';

stdout-is { $f.team_fixtures: 'mancity' }, $mancity ~ $fixtures, 'Team Fixtures output is correct';

stdout-is {
    $f.team_fixtures: 'mancity', :venue<home>
}, $mancity ~ $fixtures_home_venue, 'Output of Team Fixtures with home venue is correct';

stdout-is {
    $f.team_fixtures: 'mancity', :timeframe<n7>
}, $mancity ~ $fixtures_n7_timeframe, 'Output of Team Fixtures with timeframe is correct';

stdout-is {
    $f.team_fixtures: 'mancity', :season<2014>
}, $mancity ~ $fixtures_2014_season, 'Team Fixtures output for season 2014 is correct';

stdout-is { $f.leagues }, $leagues, 'Leagues output is correct';

stdout-is { $f.leagues: :season<2014> }, $leagues_2014, 'Leagues output for season 2014 is correct';

stdout-is { $f.league: 'pl' }, $leagues, 'League output is correct';

stdout-is { $f.league: 'pl', :season<2014> }, $leagues_2014, 'League output for season 2014 is correct';

stdout-is { $f.league_teams: 'pl' }, $leagues ~ $mancity, 'League teams output is correct';

stdout-is { $f.league_table: 'pl' }, $leagues ~ $league_table, 'League table output is correct';

stdout-is {
    $f.league_table: 'pl', :matchday(5)
}, $leagues ~ "Matchday 5\n" ~ $league_table_m5, 'League table output for matchday 5 is correct';

stdout-is {
    $f.league_table: 'pl', :season<2014>
}, $leagues_2014 ~ $league_table_2014, 'League table output for season 2014 is correct';

stdout-is { $f.league_fixtures: 'pl' }, $leagues ~ $fixtures, 'League Fixtures output is correct';

stdout-is {
    $f.league_fixtures: 'pl', :matchday(5)
}, $leagues ~ "Matchday 5\n" ~ $fixtures_league_m5, 'League Fixtures output for matchday 5 is correct';

stdout-is {
    $f.league_fixtures: 'pl', :timeframe<n7>
}, $leagues ~ $fixtures_n7_timeframe, 'Output of League Fixtures with timeframe is correct';

stdout-is {
    $f.league_fixtures: 'pl', :season<2014>
}, $leagues_2014 ~ $fixtures_2014_season, 'League Fixtures output for season 2014 is correct';

stdout-is { $f.all_fixtures }, $fixtures, 'All Fixtures output is correct';

stdout-is {
    $f.all_fixtures: :timeframe<n7>
}, $fixtures_n7_timeframe, 'Output of All Fixtures with timeframe is correct';

stdout-is {
    $f.all_fixtures: :league-code<pl,cl>
}, $all_fixtures_pl_cl, 'Output of All Fixtures with pl & cl league codes is correct';