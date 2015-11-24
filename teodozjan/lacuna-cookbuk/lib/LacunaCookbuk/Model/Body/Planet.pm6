use v6;

use LacunaCookbuk::Model::Empire;
use LacunaCookbuk::Model::Body;

use LacunaCookbuk::Model::Structure::Archaeology;
use LacunaCookbuk::Model::Structure::Trade;
use LacunaCookbuk::Model::Structure::SpacePort;
use LacunaCookbuk::Model::Structure::Intelligence;
use LacunaCookbuk::Model::Structure::Development;
use LacunaCookbuk::Model::Structure::Shipyard;


unit class LacunaCookbuk::Model::Body::Planet does LacunaCookbuk::Model::Body;

submethod find_archaeology_ministry(--> LacunaCookbuk::Model::Structure::Archaeology) {
    for self.buildings -> LacunaCookbuk::Model::LacunaBuilding $building {
	return LacunaCookbuk::Model::Structure::Archaeology.new(id => $building.id, url => $LacunaCookbuk::Model::Structure::Archaeology::URL) if $building.url ~~ $LacunaCookbuk::Model::Structure::Archaeology::URL;
    }
    say "No archaeology ministry on " ~ self.name;
    fail();
}   

submethod find_trade_ministry(--> LacunaCookbuk::Model::Structure::Trade) { 
    for self.buildings -> LacunaCookbuk::Model::LacunaBuilding $building {
	return LacunaCookbuk::Model::Structure::Trade.new(
            id => $building.id,
            url => $LacunaCookbuk::Model::Structure::Trade::URL
            ) if $building.url ~~ $LacunaCookbuk::Model::Structure::Trade::URL;
    }
    say "No trade ministry on " ~ self.name;
    fail();
}   

submethod find_shipyard(--> LacunaCookbuk::Model::Structure::Shipyard) { 
    for self.buildings -> LacunaCookbuk::Model::LacunaBuilding $building {
	return LacunaCookbuk::Model::Structure::Shipyard.new(id => $building.id, url => $Shipyard::URL) if $building.url ~~ $LacunaCookbuk::Model::Structure::Shipyard::URL;
    }
    say "No shipyard on " ~ self.name;
    fail();
} 

submethod find_space_port(--> LacunaCookbuk::Model::Structure::SpacePort) {
    for self.buildings -> LacunaCookbuk::Model::LacunaBuilding $building {
	
	if $building.url ~~ $LacunaCookbuk::Model::Structure::SpacePort::URL {
	    my %attr = %(rpc($LacunaCookbuk::Model::Structure::SpacePort::URL).view(session_id,$building.id));
	    %attr<id> = $building.id;
	    %attr<url> = $LacunaCookbuk::Model::Structure::SpacePort::URL;
	    return LacunaCookbuk::Model::Structure::SpacePort.new(|%attr)
	}
    }
    say "No space port on " ~ self.name;
    fail();
}


submethod find_intelligence_ministry(--> LacunaCookbuk::Model::Structure::Intelligence) {
    
    for self.buildings -> LacunaCookbuk::Model::LacunaBuilding $building {
	
	if $building.url ~~ $LacunaCookbuk::Model::Structure::Intelligence::URL {
	    my $id = $building.id;
	    
	    my %attr = %(rpc($LacunaCookbuk::Model::Structure::Intelligence::URL).view(session_id, $id)<spies>);	  
	    %attr<id> = $id;
	    %attr<url> = $LacunaCookbuk::Model::Structure::Intelligence::URL;
	    return LacunaCookbuk::Model::Structure::Intelligence.new(|%attr);
	}
    }
    say "No intelligence on " ~ self.name;
    fail();
}

submethod find_development_ministry(--> LacunaCookbuk::Model::Structure::Development) {
    
    for self.buildings -> LacunaCookbuk::Model::LacunaBuilding $building {
	
	if $building.url ~~ $LacunaCookbuk::Model::Structure::Development::URL {
	    my $id = $building.id;
	    my %resp = %(rpc($LacunaCookbuk::Model::Structure::Development::URL).view(session_id, $id));
	    my %attr = %resp;
	    %attr<url> = $LacunaCookbuk::Model::Structure::Development::URL;
	    %attr<id> = $id;
	    return LacunaCookbuk::Model::Structure::Development.new(|%attr);
	}
    }
    say "No intelligence on " ~ self.name;
    fail();
}

#todo -> compare with body hour production - supply chains
submethod calculate_sustainablity (--> Hash) {
    my %balance;
    for self.get_buildings_view -> %building {
	for (keys %building).grep(/_hour/) -> $key {
	    %balance{$key} += %building{$key};
	}
   }
    %balance;
}  

method is_home(--> Bool) {
    +self.id == +LacunaCookbuk::Model::Empire.home_planet_id;
}


