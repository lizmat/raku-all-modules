use WebService::FootballData::Team::Player;

unit role WebService::FootballData::Role::Factory::MakePlayer;

method !make_player (%player) returns WebService::FootballData::Team::Player {
    given %player {
        my %attributes = (
            id => .<id>,
            name => .<name>,
            position => .<position>,
            number => .<jerseyNumber>,
            nationality => .<nationality>,
            birth_date => .<dateOfBirth>,
            contract_date => .<contractUntil>,
            market_value => .<marketValue>,
        ).grep(*.value.defined);

        for 'birth_date', 'contract_date' {
            %attributes{$_} = Date.new: %attributes{$_} if %attributes{$_}:exists;
        }

        WebService::FootballData::Team::Player.new: |%attributes;
    }
}

method !make_players (@players) returns Array of WebService::FootballData::Team::Player {
    Array[WebService::FootballData::Team::Player].new: @players.map: { self!make_player($_) };
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