use v6;

use LacunaCookbuk::Model::Body::Planet;
use LacunaCookbuk::Logic::BodyBuilder;
use Form;
use Term::ANSIColor;

#= This class has evil design. REFACTOR me
unit class LacunaCookbuk::Logic::IntelCritic;

constant $TERM_SIZE = 128;
constant @summary_header = <planet num limit details>;
constant $limited_format= '{<<<<<<<<<<<<<<<<<<<<<<<<<<<} {>>>>}/{<<<<} {>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>}';
constant $ruler = '-' x $TERM_SIZE;

constant @spy_header = <name level politics mayhem theft intel defense offense mission_off mission_def assignment>; 
constant $spy_format = '{<<<<<<<<<<<<<<<<<<<<} {|||} {|||||} {|||||} {|||||} {|||||} {>>>>>}/{<<<<<} {>>>>}/{<<<<<} {<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<}';

BEGIN {
    my $f1 = form($limited_format, @summary_header).chars;
    die "$f1 summary" unless $f1 == $TERM_SIZE;
    my $f2 = form($spy_format, @spy_header).chars;
    die "$f2 spy format" unless $f2 == $TERM_SIZE;
}

sub elaborate_intelligence(Planet $planet) {
    my Intelligence $imini = $planet.find_intelligence_ministry;
    my Str $numspies = ~$imini.current;
    my Str $max = ~$imini.maximum;   
    my Str $spies = $numspies == 0 ?? "NONE!!!" !! ~$numspies;
    my @list = $imini.get_view_spies;
    my Str $spiesl = format_spies(@list);
    
    print form( 
	$limited_format,
	$planet.name, $spies, $max, $spiesl);

}

sub rename_intelligence(Planet $planet) {
    say "Looking for Agent null on {$planet.name}";
    my Intelligence $imini = $planet.find_intelligence_ministry;
    my @list = $imini.get_view_spies;
    my Str $spiesl = format_spies(@list);
    rename_spies($planet, @list);	
    
}

sub elaborate_staff(Planet $planet) {
    say "Planet {$planet.name}";
    my Intelligence $imini = $planet.find_intelligence_ministry;
    my @list = $imini.get_view_spies;
    my Str $spiesl = format_spies(@list);
    show_spies($planet, @list);
    
}

sub show_spies($planet, @spies){
    my Intelligence $imini = $planet.find_intelligence_ministry;
    print form($spy_format, @spy_header);
    say $ruler;

    for @spies -> Spy $spy {
        my $delegated;
        if ($spy.assigned_to<body_id> != $spy.based_from<body_id>) {
            $delegated = $spy.assigned_to<name>;
        } else {
            $delegated = 'h';
        }

        print form($spy_format,
                   $spy.name,
                   $spy.level,
                   $spy.mayhem,
                   $spy.politics,
                   $spy.theft,
                   $spy.intel,
                   $spy.defense_rating,
                   $spy.offense_rating,
                   $spy.mission_count<offensive>,
                   $spy.mission_count<defensive>,
                   $spy.assignment ~ '@' ~ $delegated);        
    }
}

sub rename_spies($planet, @spies){
    my Intelligence $imini = $planet.find_intelligence_ministry;
    for @spies -> Spy $spy {
	if $spy.name ~~ "Agent Null"  {
	    $imini.name_spy($spy.id, $planet.name);
	    say "Renamed spy {$spy.name}";
	}
    }
}

submethod elaborate_spies{
    say "\nIntellignece -- Spies";

    print form ($limited_format, @summary_header);
    say $ruler;
    my @planets = planets.grep({.find_intelligence_ministry.repaired});
    for @planets -> Planet $planet {
	elaborate_intelligence($planet);
    }
    say $ruler;    
    for @planets -> Planet $planet {
	rename_intelligence($planet);
    }
    say $ruler;
    for @planets -> Planet $planet {
	elaborate_staff($planet);
    }


}

 sub format_spies(@spies --> Str) {
    my %assignments;
    for @spies -> Spy $spy {
	%assignments{$spy.assignment}++;
    }

    my Str $ret;
    for %assignments.keys -> Str $key {
	my $val = $key ~ ':' ~%assignments{$key} ~ '   ';	
	$val = colored($val, 'yellow') if $key ~~ 'Idle';
	$ret ~=	$val;
    }
    $ret;
}

