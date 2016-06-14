use WebService::FootballData::League;

unit role WebService::FootballData::Role::Factory::MakeLeague;

method !make_league (%league) returns WebService::FootballData::League {
    given %league {
        my %attributes = (
            links => .<_links>,
            name => .<caption>,
            code => .<league>,
            season => .<year>,
            current_matchday => .<currentMatchday>,
            number_of_matchdays => .<numberOfMatchdays>,
            number_of_teams => .<numberOfTeams>,
            number_of_games => .<numberOfGames>,
            last_updated => .<lastUpdated>,
        ).grep(*.value.defined);

        %attributes<last_updated> = DateTime.new: %attributes<last_updated> if %attributes<last_updated>:exists;

        WebService::FootballData::League.new: :$.request, |%attributes;
    }
}

method !make_leagues (@leagues) returns Array of WebService::FootballData::League {
    Array[WebService::FootballData::League].new: @leagues.map: { self!make_league($_) };
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