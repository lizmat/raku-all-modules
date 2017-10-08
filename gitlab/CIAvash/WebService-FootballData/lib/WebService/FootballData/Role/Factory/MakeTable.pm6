use WebService::FootballData::League::Table;
use WebService::FootballData::League::Table::Row;

unit role WebService::FootballData::Role::Factory::MakeTable;

method !make_table (%table) returns WebService::FootballData::League::Table {
    given %table {
        my %attributes = (
            links => .<_links>,
            name => .<leagueCaption>,
            matchday => .<matchday>,
            rows => .<standing>,
        ).grep(*.value.defined);

        %attributes<rows> := self!make_table_rows: %attributes<rows> if %attributes<rows>:exists;

        WebService::FootballData::League::Table.new: |%attributes;
    }
}

method !make_table_row (%table_row) returns WebService::FootballData::League::Table::Row {
    given %table_row {
        my %attributes = (
            links => .<_links>,
            name => .<teamName>,
            crest_url => .<crestURI>,
            position => .<position>,
            games_played => .<playedGames>,
            goals_for => .<goals>,
            goals_against => .<goalsAgainst>,
            goal_difference => .<goalDifference>,
            wins => .<wins>,
            draws => .<draws>,
            losses => .<losses>,
            home => .<home>,
            away => .<away>,
            points => .<points>,
        ).grep(*.value.defined);

        %attributes<home> = self!make_table_row_home: %attributes<home> if %attributes<home>:exists; 
        %attributes<away> = self!make_table_row_away: %attributes<away> if %attributes<away>:exists; 

        WebService::FootballData::League::Table::Row.new: |%attributes;
    }
}

method !make_table_row_home (%home_stats) returns WebService::FootballData::League::Table::Row::Home {
    given %home_stats {
        my %attributes = (
            goals_for => .<goals>,
            goals_against => .<goalsAgainst>,
            wins => .<wins>,
            draws => .<draws>,
            losses => .<losses>,
        ).grep(*.value.defined);

        WebService::FootballData::League::Table::Row::Home.new: |%attributes;
    }
}

method !make_table_row_away (%away_stats) returns WebService::FootballData::League::Table::Row::Away {
    given %away_stats {
        my %attributes = (
            goals_for => .<goals>,
            goals_against => .<goalsAgainst>,
            wins => .<wins>,
            draws => .<draws>,
            losses => .<losses>,
        ).grep(*.value.defined);

        WebService::FootballData::League::Table::Row::Away.new: |%attributes;
    }
}

# TODO: uncomment `returns` when RT 127309 is fixed
method !make_table_rows (@table_rows) #`(returns Array of WebService::FootballData::League::Table::Row) {
    Array[WebService::FootballData::League::Table::Row].new: @table_rows.map: { self!make_table_row($_) };
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