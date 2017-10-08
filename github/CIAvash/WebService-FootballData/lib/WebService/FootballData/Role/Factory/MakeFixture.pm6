use WebService::FootballData::Fixtures::AllFixtures;
use WebService::FootballData::Fixtures::FixtureDetails;
use WebService::FootballData::Fixtures::Head2Head;
use WebService::FootballData::Fixtures::Fixture;
use WebService::FootballData::Fixtures::Fixture::Result;

unit role WebService::FootballData::Role::Factory::MakeFixture;

method !make_all_fixtures (%all_fixtures) returns WebService::FootballData::Fixtures::AllFixtures {
    given %all_fixtures {
        my %attributes = (
            timeframe_start => .<timeFrameStart>,
            timeframe_end => .<timeFrameEnd>,
            fixtures => .<fixtures>,
        ).grep(*.value.defined);

        for 'timeframe_start', 'timeframe_end' {
            %attributes{$_} = Date.new: %attributes{$_} if %attributes{$_}:exists;
        }

        %attributes<fixtures> := self!make_fixtures: %attributes<fixtures> if %attributes<fixtures>:exists;
        
        WebService::FootballData::Fixtures::AllFixtures.new: |%attributes;
    }
}

method !make_fixture_details (%fixture_details) returns WebService::FootballData::Fixtures::FixtureDetails {
    given %fixture_details {
        my %attributes = (
            fixture => .<fixture>,
            head2head => .<head2head>,
        ).grep(*.value.defined);

        %attributes<fixture> = self!make_fixture: %attributes<fixture> if %attributes<fixture>:exists;

        %attributes<head2head> = self!make_fixture_head2head: %attributes<head2head> if %attributes<head2head>:exists;

        WebService::FootballData::Fixtures::FixtureDetails.new: |%attributes;
    }
}

method !make_fixture_head2head (%head2head) returns WebService::FootballData::Fixtures::Head2Head {
    given %head2head {
        my %attributes = (
            timeframe_start => .<timeFrameStart>,
            timeframe_end => .<timeFrameEnd>,
            home_team_wins => .<homeTeamWins>,
            away_team_wins => .<awayTeamWins>,
            draws => .<draws>,
            'home_team_last_win_home' => .<lastHomeWinHomeTeam>,
            'home_team_last_win' => .<lastWinHomeTeam>,
            'away_team_last_win_away' => .<lastAwayWinAwayTeam>,
            'away_team_last_win' => .<lastWinAwayTeam>,
            fixtures => .<fixtures>,
        ).grep(*.value.defined);

        for 'timeframe_start', 'timeframe_end' {
            %attributes{$_} = Date.new: %attributes{$_} if %attributes{$_}:exists;
        }

        for 'home_team_last_win_home', 'home_team_last_win', 'away_team_last_win_away', 'away_team_last_win' {
            %attributes{$_} = self!make_fixture: %attributes{$_} if %attributes{$_}:exists;
        }

        %attributes<fixtures> := self!make_fixtures: %attributes<fixtures> if %attributes<fixtures>:exists;

        WebService::FootballData::Fixtures::Head2Head.new: |%attributes;
    }
}

method !make_fixture (%fixture) returns WebService::FootballData::Fixtures::Fixture {
    given %fixture {
        my %attributes = (
            links => .<_links>,
            date => .<date>,
            status => .<status>,
            matchday => .<matchday>,
            home_team_name => .<homeTeamName>,
            away_team_name => .<awayTeamName>,
            result => .<result>,
        ).grep(*.value.defined);

        %attributes<date> = DateTime.new: %attributes<date> if %attributes<date>:exists;
        %attributes<result> = self!make_fixture_result: %attributes<result> if %attributes<result>:exists;

        WebService::FootballData::Fixtures::Fixture.new: |%attributes;
    }
}

# TODO: uncomment `returns` when RT 127309 is fixed
method !make_fixtures (@fixtures) #`(returns Array of WebService::FootballData::Fixtures::Fixture) {
    Array[WebService::FootballData::Fixtures::Fixture].new: @fixtures.map: { self!make_fixture($_) };
}

method !make_fixture_result (%fixture_result) returns WebService::FootballData::Fixtures::Fixture::Result {
    given %fixture_result {
        my %attributes = (
            home_team_goals => .<goalsHomeTeam>,
            away_team_goals => .<goalsAwayTeam>,
        ).grep(*.value.defined);

        WebService::FootballData::Fixtures::Fixture::Result.new: |%attributes;
    }
}

=begin comment

Copyright © 2016 Siavash Askari Nasr

This file is part of WebService::FootballData.

WebService::FootballData is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

WebService::FootballData is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with WebService::FootballData.  If not, see <http://www.gnu.org/licenses/>.

=end comment