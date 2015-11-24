use v6;

use LacunaCookbuk::Model::Body;
use LacunaCookbuk::Model::Structure::Parliament;

unit class LacunaCookbuk::Model::Body::SpaceStation does LacunaCookbuk::Model::Body;

submethod find_parliament(--> LacunaCookbuk::Model::Structure::Parliament) { 
    for self.buildings -> LacunaCookbuk::Model::LacunaBuilding $building {
	return LacunaCookbuk::Model::Structure::Parliament.new(id => $building.id, url => $LacunaCookbuk::Model::Structure::Parliament::URL) if $building.url ~~ $LacunaCookbuk::Model::Structure::Parliament::URL;
    }
    #warn "No LacunaCookbuk::Model::Structure::Parliament on " ~ self.name;
    fail();
}

