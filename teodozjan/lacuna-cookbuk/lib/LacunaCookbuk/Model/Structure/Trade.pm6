use v6;

use LacunaCookbuk::Model::Empire;
use LacunaCookbuk::Model::LacunaBuilding;
use LacunaCookbuk::Model::Ship;

unit class LacunaCookbuk::Model::Structure::Trade is LacunaCookbuk::Model::LacunaBuilding;

constant $URL = '/trade';

submethod get_glyphs { #( --> Array[Hash]) {
##	my @array =
##	gather 
    my Hash @array;
    for rpc($URL).get_glyph_summary(session_id, self.id)<glyphs> -> @glyph
    {
	for @glyph -> %sth { 
	    my Hash $hash = %(:type("glyph"), :name(%sth<name>), :quantity(%sth<quantity>));
	    @array.push($hash);
	    
	}
	
    }
    @array;
} 

#todo move to achaeology
submethod get_glyphs_hash { #(--> Hash) {
    my Int %hash;

    for rpc($URL).get_glyph_summary(session_id, self.id)<glyphs> -> @glyph
    {
	for @glyph -> %sth { 
	    %hash{%sth<name>} = +(%sth<quantity>);
	}
	
    }
    %hash;
} 

submethod get_plans_hash { #(--> Hash) {
    rpc($URL).get_plan_summary(session_id, self.id)<plans>;
} 

method get_resources {
    rpc($URL).get_stored_resources(session_id, $.id)<resources>;
}


method get_plans {
    my Hash @array=();
    for rpc($URL).get_plan_summary(session_id, $.id)<plans> -> @plans
    {
	for @plans -> %sth { 
	    my Hash $hash = %(:type("plan"), :plan_type(%sth<plan_type>), :level(%sth<level>), :extra_build_level(%sth<extra_build_level>), :quantity(%sth<quantity>));
	    @array.push($hash);
	    
	}
	
    }
    @array;
    
} 

method get_push_ships($targetId = LacunaCookbuk::Model::Empire.home_planet_id) {
    rpc($URL).get_trade_ships(session_id, $.id, $targetId)<ships>
}

method push_cargo($cargo, $dst_planet_id = LacunaCookbuk::Model::Empire.home_planet_id) {   
    
    my %ship = %(rpc($URL).push_items(session_id, self.id, $dst_planet_id, $cargo, %(:ship_id(self.find_fastest_ship<id>), :stay(0)))<ship>);
    
    LacunaCookbuk::Model::Ship.new(attr => %ship)
}

method find_fastest_ship {
    my $fastest_ship;
    for self.get_push_ships -> @ships {
	for @ships -> $ship {
	    if $fastest_ship {
		$fastest_ship = $ship if $ship<estimated_travel_time> < $fastest_ship<estimated_travel_time>; 
	    } else {
		$fastest_ship = $ship;
	    }
	}
    }

    $fastest_ship;
}
