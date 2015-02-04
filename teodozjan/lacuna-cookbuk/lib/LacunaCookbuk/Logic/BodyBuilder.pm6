use v6;

use LacunaCookbuk::Model::Body::SpaceStation;
use LacunaCookbuk::Model::Body::Planet;
use PerlStore::FileStore;
use LacunaCookbuk::Model::LacunaBuilding;
use LacunaCookbuk::Model::Empire;
use Term::ANSIColor;

#| Class is responsible for reading bodies and storing them
class LacunaCookbuk::Logic::BodyBuilder;

my Planet @planets;
my SpaceStation @stations;


submethod read {
    my $path_planets = make_path('planets.pl');
    my $path_stations = make_path('stations.pl');

=begin pod
I want this code back

    @planets = from_file($path_planets);
    @stations = from_file($path_stations);



=end pod

    #moar hack
    say 'Readin $path_planets';
    my $plan = slurp $path_planets;
    @planets = EVAL $plan;

    #moar hack
    say 'Readin $path_stations';
    my $stat =  slurp $path_stations;
    @stations = EVAL $stat; 


}

submethod write {
    my $path_planets = make_path('planets.pl');
    my $path_stations = make_path('stations.pl');

    to_file($path_planets, @planets);
    to_file($path_stations, @stations);
}

#this not something I'm proud of
submethod process_all_bodies {
    @planets = ();
    @stations = ();
    for Empire.planets_hash.keys -> $planet_id {
	#TODO report rakudobug for .=
	my Body $body = Body.new(id => $planet_id);
	$body.get_buildings;	
       
	if $body.is_station {
	    my SpaceStation $station .= new(id => $planet_id, buildings => $body.buildings,  x => $body.x, y => $body.y);
	    say $station.name ~ " is a Space Station";
	    @stations.push($station)
	} elsif $body.is_planet {
	    my Planet $planet .= new(id => $planet_id, buildings => $body.buildings, ore => $body.ore, x => $body.x, y => $body.y);
	    say $planet.name ~ " is a Planet";
	    @planets.push($planet)
	}else {
	    warn $body.name ~ " Cannot be used -- neither planet nor station";
	}
    } 
    LacunaCookbuk::Logic::BodyBuilder.write;
}

sub home_planet(--> Planet) is export {
    for @planets -> Planet $planet {
	return $planet if $planet.is_home;
    }
    Planet;
}

sub planets is export {
    @planets
}

sub find_planet(Str $s) is export {
    for @planets -> $p {
        return $p if $p.name ~~ $s;
    }

}

sub stations is export {
    @stations
}

constant $ZONE_SIZE = 250;


=begin pod

=head2 EXAMPLE report_zones

   [33mGlitch Agina is in zone -1|-1[0m
   [39mCircle Desert is in zone -1|0[0m
   [39mPixel Aqua is in zone -1|0[0m
   [39mGlitch Wasteland is in zone -1|-1[0m
   [39mCircle Forest is in zone -1|0[0m
   [39mCircle Square is in zone -1|0[0m
   [39mPixel Electric is in zone -1|0[0m
   [33mGlitch Hamburger is in zone -1|-1[0m
   [33mGlitch Tungsten is in zone -1|-1[0m
   [39mPixel Glow is in zone -1|0[0m
   [39mCircle Monazite is in zone -1|0[0m
   [39mPixel Bauxite is in zone -1|0[0m
   [39mSS Mercury Deep Space 1 is in zone -5|-5[0m
   [39mSS Mercury Sea Wasp is in zone -4|2[0m
   [39mSS Mercury Vis Vires is in zone -1|2[0m
   [39mSS Mercury Escalion V is in zone 3|2[0m
   [39mSS Mercury Gensaki VII is in zone 4|1[0m
   [39mSS Mercury Rising is in zone -4|2[0m
   [39mSS Mercury Geronya HQ is in zone 3|1[0m
   [39mSS Mercury Outer Rim is in zone -1|0[0m
   [39mSS Mercury Phoenix Station is in zone 2|-3[0m

=end pod

submethod report_zones {
    for @planets, @stations -> $body {
	my Int $zone_x = (+$body.x / $ZONE_SIZE).Int;	
	my Int $zone_y = (+$body.y / $ZONE_SIZE).Int;

	my $color = "default";
	$color = "blue" if all($zone_x, $zone_y) == 0;
	$color = "yellow" if all($zone_x.abs, $zone_y.abs) == 1;
	$color = "green" if $zone_x == -3 and $zone_y == 0;
	say colored("{$body.name} is in zone $zone_x|$zone_y", $color);
    }
}
