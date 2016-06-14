unit class FakeFootballData;

my @fixtures = [
    class {
        has $.matchday = 34;
        has $.home_team_name = 'Chelsea FC';
        has $.away_team_name = 'Manchester City FC';
        has $.result = class {
            has $.home_team_goals = 0;
            has $.away_team_goals = 3;
        }.new;
        has $.status = 'FINISHED';
        has $.date = DateTime.new: '2016-04-16T16:30:00Z';
    }.new
];

my @fixtures_home_venue = [
    class {
        has $.matchday = 8;
        has $.home_team_name = 'Manchester City FC';
        has $.away_team_name = 'Paris Saint-Germain';
        has $.result = class {
            has $.home_team_goals = 1;
            has $.away_team_goals = 0;
        }.new;
        has $.status = 'FINISHED';
        has $.date = DateTime.new: '2016-04-12T18:45:00Z';
    }.new
];

my @fixtures_n7_timeframe = [
    class {
        has $.matchday = 35;
        has $.home_team_name = 'Manchester City FC';
        has $.away_team_name = 'Stoke City FC';
        has $.result = class {
            has $.home_team_goals;
            has $.away_team_goals;
        }.new;
        has $.status = 'TIMED';
        has $.date = DateTime.new: '2016-04-24T11:00:00Z';
    }.new
];

my @fixtures_2014_season = [
    class {
        has $.matchday = 1;
        has $.home_team_name = 'Newcastle United FC';
        has $.away_team_name = 'Manchester City FC';
        has $.result = class {
            has $.home_team_goals = 0;
            has $.away_team_goals = 2;
        }.new;
        has $.status = 'FINISHED';
        has $.date = DateTime.new: '2014-08-17T19:30:00Z';
    }.new
];

my @fixtures_league_m5 = [
    class {
        has $.matchday = 5;
        has $.home_team_name = 'Crystal Palace FC';
        has $.away_team_name = 'Manchester City FC';
        has $.result = class {
            has $.home_team_goals = 0;
            has $.away_team_goals = 1;
        }.new;
        has $.status = 'FINISHED';
        has $.date = DateTime.new: '2015-09-12T18:30:00Z';
    }.new
];

my $league_table = class {
    has $.rows = [
        class {
            has $.position = 1;
            has $.name = 'Leicester City FC';
            has $.points = 56;
            has $.games_played = 27;
            has $.goals_for = 49;
            has $.goals_against = 29;
            has $.goal_difference = 20;
            has $.wins = 16;
            has $.draws = 8;
            has $.losses = 3;
            has $.home = class {
                has $.wins = 8;
                has $.draws = 4;
                has $.losses = 1;
            }.new;
            has $.away = class {
                has $.wins = 8;
                has $.draws = 4;
                has $.losses = 2;
            }.new;
        }.new
    ]
}.new;

my $league_table_m5 = class {
    has $.rows = [
        class {
            has $.position = 1;
            has $.name = 'Manchester City FC';
            has $.points = 15;
            has $.games_played = 5;
            has $.goals_for = 11;
            has $.goals_against = 0;
            has $.goal_difference = 11;
            has $.wins = 5;
            has $.draws = 0;
            has $.losses = 0;
            has $.home = class {
                has $.wins = 2;
                has $.draws = 0;
                has $.losses = 0;
            }.new;
            has $.away = class {
                has $.wins = 3;
                has $.draws = 0;
                has $.losses = 0;
            }.new;
        }.new
    ]
}.new;

my $league_table_2014 = class {
    has $.rows = [
        class {
            has $.position = 1;
            has $.name = 'Chelsea FC';
            has $.points = 87;
            has $.games_played = 38;
            has $.goals_for = 73;
            has $.goals_against = 32;
            has $.goal_difference = 41;
            has $.wins = 26;
            has $.draws = 9;
            has $.losses = 3;
            has $.home = class {
                has $.wins = 15;
                has $.draws = 4;
                has $.losses = 0;
            }.new;
            has $.away = class {
                has $.wins = 11;
                has $.draws = 5;
                has $.losses = 3;
            }.new;
        }.new
    ]
}.new;

my @pl_teams = [
    class {
        has $.name = 'Manchester City FC';
        has $.short_name = 'ManCity';
        has $.code = 'MCFC';
        has $.squad_market_value = '510,000,000 €';
        has $.players = [
            class {
                has $.number = 1;
                has $.name = 'Joe Hart';
                has $.position = 'Keeper';
                has $.age = 28;
                has $.birth_date = Date.new: '1987-04-19';
                has $.nationality = 'England';
                has $.contract_date = Date.new: '2019-01-01';
                has $.market_value = '16,000,000 €';
            }.new
        ];
        method fixtures (:$venue, :$timeframe, :$season) {
            with $venue {
                return @fixtures_home_venue if $_ eq 'home';
            }
            with $timeframe {
                return @fixtures_n7_timeframe if $_ eq 'n7';
            }
            with $season {
                return @fixtures_2014_season if $_ eq '2014';
            }
            @fixtures;
        }
    }.new;
];

my @leagues = [
    class {
        has $.name = 'Premier League 2015/16';
        has $.code = 'PL';
        has $.season = '2015';
        has $.current_matchday = 34;
        has $.number_of_matchdays = 38;
        has $.number_of_teams = 20;
        has $.number_of_games = 380;
        method teams {
            @pl_teams;
        }
        method table ($matchday?) {
            with $matchday {
                return $league_table_m5 if $_ == 5;
            }
            $league_table;
        }
        method fixtures (:$matchday, :$timeframe) {
            with $matchday {
                return @fixtures_league_m5 if $_ == 5;
            }
            with $timeframe {
                return @fixtures_n7_timeframe if $_ eq 'n7';
            }
            @fixtures;
        }
    }.new
];

my @leagues_2014 = [
    class {
        has $.name = 'Premier League 2014/15';
        has $.code = 'PL';
        has $.season = '2014';
        has $.current_matchday;
        has $.number_of_matchdays = 38;
        has $.number_of_teams = 20;
        has $.number_of_games = 380;
        method table (|) {
            $league_table_2014;
        }
        method fixtures (|) {
            @fixtures_2014_season;
        }
    }.new
];

method team ($team_name) {
    return unless $team_name eq 'mancity';

    @pl_teams[0];
}

method leagues (:$season) {
    with $season {
        return @leagues_2014 if $_ eq '2014';
    }
    @leagues;
}

method league ($league_name, :$season) {
    return unless $league_name eq 'pl';
    self.leagues(:$season)[0];
}

method all_fixtures (:$timeframe, :$league) {
    class {
        method fixtures {
            with $league {
                return [@fixtures_home_venue[0], @fixtures[0]] if $_ eq 'PL,CL';
            }
            with $timeframe {
                return @fixtures_n7_timeframe if $_ eq 'n7';
            }
            @fixtures;
        }
    }.new
}