use WebService::FootballData::TeamSearchResult;

unit role WebService::FootballData::Role::Factory::MakeTeamSearchResult;

method !make_team_search_result (%team) returns WebService::FootballData::TeamSearchResult {
    given %team {
        my %attributes = (
            team_id => .<id>,
            team_name => .<name>,
            league_id => .<currentSoccerseason>,
            league_short_name => .<currentLeague>,
        ).grep(*.value.defined);

        WebService::FootballData::TeamSearchResult.new: |%attributes;
    }
}

method !make_team_search_results (@teams) returns Array of WebService::FootballData::TeamSearchResult {
    Array[WebService::FootballData::TeamSearchResult].new: @teams.map: { self!make_team_search_result($_) };
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