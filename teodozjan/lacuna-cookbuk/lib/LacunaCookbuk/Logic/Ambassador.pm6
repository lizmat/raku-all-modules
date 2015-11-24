use v6;


use LacunaCookbuk::Model::Body::SpaceStation;
use LacunaCookbuk::Model::Structure::Parliament;
use LacunaCookbuk::Logic::BodyBuilder;
use LacunaCookbuk::Model::Empire;

unit class LacunaCookbuk::Logic::Ambassador;

constant $ALLIANCE = "/alliance"; 

submethod vote_all(Bool $vote) {
    for (stations) -> LacunaCookbuk::Model::Body::SpaceStation $station {
	my LacunaCookbuk::Model::Structure::Parliament $par = $station.find_parliament;
	next unless $par;
	my @prop = $par.view_propositions;
	for @prop -> @weirdo {
	    for @weirdo -> $to_vote {
		next unless $to_vote;
		
		my $number = $vote ?? "1" !! "0";		
		say $par.cast_vote($to_vote<id>, $number) unless $to_vote<my_vote>:exists;#FIXME
	    }
	}
    }
}

submethod show_alliance(Str $name){
    my $all = rpc($ALLIANCE);
    say "Looking for $name";
    my $id = $all.find(session_id,$name)<alliances>;
    say "Found" ~ $id.perl;
        say $all.view_profile(session_id, $id<id>)
}
