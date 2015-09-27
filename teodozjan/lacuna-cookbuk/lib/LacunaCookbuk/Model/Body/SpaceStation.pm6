use v6;

use LacunaCookbuk::Model::Body;
use LacunaCookbuk::Model::Structure::Parliament;

unit class SpaceStation does Body;

submethod find_parliament(--> Parliament) { 
    for self.buildings -> LacunaBuilding $building {
	return Parliament.new(id => $building.id, url => $Parliament::URL) if $building.url ~~ $Parliament::URL;
    }
    #warn "No Parliament on " ~ self.name;
    Parliament;
}

