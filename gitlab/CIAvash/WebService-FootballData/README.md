NAME
====

WebService::FootballData - Interface to football-data.org API

SYNOPSIS
========

```perl6
use WebService::FootballData;

my $fd = WebService::FootballData.new;
say .name for $fd.leagues;

my $league = $fd.league: 'premier league';
say "#{.position} in $league.name() is {.name} with {.points} points" given $league.table.rows[0];

my $team = $fd.team: 'manchester city';
say $team.name ~ ' players:';
say .name for $team.players;

my @fixtures = $team.fixtures;
given @fixtures[0] {
       say .home_team_name ~ ': ' ~ .result.home_team_goals;
       say .away_team_name ~ ': ' ~ .result.away_team_goals;
}
```

DESCRIPTION
===========

`WebService::FootballData` provides a Perl 6 interface to football-data.org API.

ATTRIBUTES
==========

api_key
-------

    my $fd = WebService::FootballData.new: :api_key<YOUR_API_KEY>;

A `Str` value. The API key provided by football-data.org.

request
-------

An object that does the `WebService::FootballData::Role::Request` role. Defaults to an instance of `WebService::FootballData::Request`.

METHODS
=======

leagues
-------

    $fd.leagues;
    $fd.leagues: :season(2014);

Takes named argument `season` of type `Int`.

Returns Array of `WebService::FootballData::League` instances.

league
------

Multi method.

    $fd.league: 351;

Takes league ID of type `Int`.

    $fd.league: 'pl';
    $fd.league: 'pl', :season(2014);

Takes:

  * League name of type `Str`

  * Named argument `season` of type `Int`

Returns instance of `WebService::FootballData::League`.

team
----

Multi method.

    $fd.team: 5;

Takes team ID of type `Int`.

    $fd.team: 'manchester city';

Takes team name of type `Str`.

Returns instance of `WebService::FootballData::Team`.

search_team
-----------

    $fd.search_team: 'manchester';

Takes team name of type `Str`.

Returns Array of `WebService::FootballData::TeamSearchResult` instances.

find_team
---------

    $fd.find_team: 'manchester';

Takes team name of type `Str`.

Returns the first team search result found: instance of `WebService::FootballData::TeamSearchResult`.

all_fixtures
------------

    $fd.all_fixtures: :timeframe<n7>, :league<PL,CL>;

Takes:

  * Named argument `timeframe` of type `Str`. A timeframe as defined by football-data.org.

  * Named argument `league` of type `Str`. A league code as defined by football-data.org.

Returns instance of `WebService::FootballData::Fixtures::AllFixtures`.

fixture_details
---------------

    $fd.fixture_details: 136111;
    $fd.fixture_details: 136111, :head2head(3);

Takes:

  * Fixture ID of type `Int`.

  * Named argument `head2head` of type `Int`. Number of former games to be analyzed.

Returns instance of `WebService::FootballData::Fixtures::FixtureDetails`.

players\_of\_team
---------------

Multi method.

    $fd.players_of_team: 5;

Takes team ID of type `Int`.

    $fd.players_of_team: 'manchester city';

Takes team name of type `Str`.

Returns Array of `WebService::FootballData::Team::Player` instances.

fixtures\_of\_team
----------------

Multi method.

    $fd.fixtures_of_team: 5, :timeframe<p20>;
    $fd.fixtures_of_team: 5, :season(2014), :venue<home>;

Takes:

  * Team ID of type `Int`.

  * Named argument `season` of type `Int`.

  * Named argument `timeframe` of type `Str`. A timeframe as defined by football-data.org.

  * Named argument `venue` of type `Str`. A venue as defined by football-data.org.

    $fd.fixtures_of_team: 'mancity', :timeframe<p20>;
    $fd.fixtures_of_team: 'mancity', :season(2014), :venue<home>;

Takes:

  * Team name of type `Str`.

  * Named argument `season` of type `Int`.

  * Named argument `timeframe` of type `Str`. A timeframe as defined by football-data.org.

  * Named argument `venue` of type `Str`. A venue as defined by football-data.org.

Returns Array of `WebService::FootballData::Fixtures::Fixture` instances.

fixtures\_of\_league
------------------

Multi method.

    $fd.fixtures_of_league: 351, :timeframe<p20>;
    $fd.fixtures_of_league: 351, :matchday(5);

Takes:

  * League ID of type `Int`.

  * Named argument `matchday` of type `Int`.

  * Named argument `timeframe` of type `Str`. A timeframe as defined by football-data.org.

    $fd.fixtures_of_league: 'pl', :timeframe<p20>;
    $fd.fixtures_of_league: 'pl', :matchday(5);

Takes:

  * League name of type `Str`.

  * Named argument `matchday` of type `Int`.

  * Named argument `timeframe` of type `Str`. A timeframe as defined by football-data.org.

Returns Array of `WebService::FootballData::Fixtures::Fixture` instances.

teams\_of\_league
---------------

Multi method.

    $fd.teams_of_league: 351;

Takes league ID of type `Int`.

Returns Array of `WebService::FootballData::Team` instances.

table\_of\_league
---------------

Multi method.

    $fd.table_of_league: 351;
    $fd.table_of_league: 351, :matchday(5);

Takes:

  * League ID of type `Int`.

  * Named argument `matchday` of type `Int`.

Returns instance of `WebService::FootballData::League::Table`.

ERRORS
======

`HTTP::UserAgent` module is used with exception throwing enabled. So exceptions will be thrown in case of non-existent resources, out of range values, etc. See [http://modules.perl6.org/dist/HTTP::UserAgent](http://modules.perl6.org/dist/HTTP::UserAgent) and `WebService::FootballData::Facade::UserAgent`

ENVIRONMENT
===========

Some live tests will run when `NETWORK_TESTING` environment variable is set.

REPOSITORY
==========

[https://gitlab.com/CIAvash/WebService-FootballData](https://gitlab.com/CIAvash/WebService-FootballData)

BUGS
====

[https://gitlab.com/CIAvash/WebService-FootballData/issues](https://gitlab.com/CIAvash/WebService-FootballData/issues)

AUTHOR
======

Siavash Askari Nasr - [http://ciavash.name/](http://ciavash.name/)

COPYRIGHT AND LICENSE
=====================

Copyright © 2016 Siavash Askari Nasr

WebService::FootballData is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

WebService::FootballData is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with WebService::FootballData. If not, see <http://www.gnu.org/licenses/>.
