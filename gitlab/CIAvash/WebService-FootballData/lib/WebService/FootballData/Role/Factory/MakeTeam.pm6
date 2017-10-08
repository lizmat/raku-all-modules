use WebService::FootballData::Team;

unit role WebService::FootballData::Role::Factory::MakeTeam;

method !make_team (%team) returns WebService::FootballData::Team {
    given %team {
        my %attributes = (
            links => .<_links>,
            name => .<name>,
            short_name => .<shortName>,
            code => .<code>,
            squad_market_value => .<squadMarketValue>,
            crest_url => .<crestUrl>,
        ).grep(*.value.defined);

        WebService::FootballData::Team.new: :$.request, |%attributes;
    }
}

method !make_teams (@teams) returns Array of WebService::FootballData::Team {
    Array[WebService::FootballData::Team].new: @teams.map: { self!make_team($_) };
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