use v6;

use LacunaCookbuk::Model::Body::SpaceStation;
use LacunaCookbuk::Model::Body::Planet;
use PerlStore::FileStore;
use LacunaCookbuk::Model::LacunaBuilding;
use LacunaCookbuk::Model::Empire;
use Terminal::ANSIColor;

#| Class is responsible for reading bodies and storing them
unit class LacunaCookbuk::Logic::BodyBuilder;

my LacunaCookbuk::Model::Body::Planet @planets;
my LacunaCookbuk::Model::Body::SpaceStation @stations;


submethod read {
    my $path_planets = make_path('planets.pl');
    my $path_stations = make_path('stations.pl');

    @planets = from_file($path_planets);
    @stations = from_file($path_stations);
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
    for LacunaCookbuk::Model::Empire.planets_hash.keys -> $planet_id {
	#TODO report rakudobug for .=
	my LacunaCookbuk::Model::Body $body = LacunaCookbuk::Model::Body.new(id => $planet_id);
	$body.get_buildings;	
       
	if $body.is_station {
	    my LacunaCookbuk::Model::Body::SpaceStation $station .= new(id => $planet_id, buildings => $body.buildings,  x => $body.x, y => $body.y);
	    say $station.name ~ " is a Space Station";
	    @stations.push($station)
	} elsif $body.is_planet {
	    my LacunaCookbuk::Model::Body::Planet $planet .= new(id => $planet_id, buildings => $body.buildings, ore => $body.ore, x => $body.x, y => $body.y);
	    say $planet.name ~ " is a LacunaCookbuk::Model::Body::Planet";
	    @planets.push($planet)
	}else {
	    warn $body.name ~ " Cannot be used -- neither planet nor station";
	}
    } 
    LacunaCookbuk::Logic::BodyBuilder.write;
}

sub home_planet(--> LacunaCookbuk::Model::Body::Planet) is export {
    for @planets -> LacunaCookbuk::Model::Body::Planet $planet {
	return $planet if $planet.is_home;
    }
    fail();
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


submethod report_waste {
    for @planets -> $body {
        my $waste = $body.get_waste_stored;
        my $wasteh = $body.get_waste_hour;
        my $wastec = $body.get_waste_capacity;
        my $wasteload;
        if $wastec == 0 {$wasteload = -100}else{$wasteload = $waste*100/$wastec}
        
        my $color = "default";
	$color = "blue" if $wasteload == 0;
	$color = "yellow" if $wasteload < 0;
        $color = "green" if $wasteh == 0;
        $color = "red" if $wasteload > 99;
	
	say colored("{$body.name} {$waste}({$wasteload}%) at {$wasteh}",$color);
    }
}

constant $ZONE_SIZE = 250;
submethod report_zones {
    for (@planets, @stations).flat -> $body {
	my Int $zone_x = (+$body.x / $ZONE_SIZE).Int;	
	my Int $zone_y = (+$body.y / $ZONE_SIZE).Int;

	my $color = "default";
	$color = "blue" if all($zone_x, $zone_y) == 0;
	$color = "yellow" if all($zone_x.abs, $zone_y.abs) == 1;
	$color = "green" if $zone_x == -3 and $zone_y == 0;
	say colored("{$body.name} is in zone $zone_x|$zone_y", $color);
    }
}

