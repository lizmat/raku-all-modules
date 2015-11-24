use v6;


use LacunaCookbuk::Model::LacunaBuilding;
use LacunaCookbuk::Model::Empire;
constant $URL = '/body';

unit role LacunaCookbuk::Model::Body does LacunaCookbuk::Id;

has LacunaCookbuk::Model::LacunaBuilding @.buildings;
has %.ore; 
has $.x;
has $.y;

method get_status { 
    rpc($URL).get_status(session_id, self.id);
}

method get_buildings { 
  my %buildings = %(rpc($URL).get_buildings(session_id, self.id));
    %!ore = %(%buildings<status><body><ore>);
    
    $!x =  %buildings<status><body><x>;
    $!y =  %buildings<status><body><y>;

    my LacunaCookbuk::Model::LacunaBuilding @result = gather for keys %buildings<buildings> -> $building_id {
	my LacunaCookbuk::Model::LacunaBuilding $building = LacunaCookbuk::Model::LacunaBuilding.new(id => $building_id, url => %buildings<buildings>{$building_id}<url>);
	take $building;
    }   

    self.buildings = @result;  
}

method get_buildings_view {#( --> BuildingsView) {
    gather for self.buildings -> %building {	
	my %building_view =  rpc(%building<url>).view(session_id, %building<id>);
	%building_view<building><id> = %building<id>;	 
	take %building_view<building>;
    }     
}


method get_happiness(--> Int:D){
    my %res = self.status();
    %res<body><happiness>;

}

method get_waste_stored(--> Int:D){
    my %res = self.status();
    +%res<body><waste_stored>;
}

method get_waste_hour(--> Int:D){
    my %res = self.status();
    +%res<body><waste_hour>;
}

method get_waste_capacity(--> Int:D){
    my %res = self.status();
    +%res<body><waste_capacity>;
}


method status(){
   %(rpc($URL).get_status(session_id, self.id));
}


method find_buildings(Str $url) {
    my LacunaCookbuk::Model::LacunaBuilding @buildings = gather for self.buildings -> LacunaCookbuk::Model::LacunaBuilding $building {
	take $building if $building.url ~~ $url;
    };    
    @buildings;
  
}

method name(--> Str) {
    LacunaCookbuk::Model::Empire.planet_name(self.id);
}


submethod is_planet returns Bool {
    for self.buildings -> LacunaCookbuk::Model::LacunaBuilding $building {
	return True if $building.url ~~ '/planetarycommand';
    }
    False;
}   


submethod is_station returns Bool {
    for self.buildings -> LacunaCookbuk::Model::LacunaBuilding $building {
	return True if $building.url ~~ '/stationcommand';
    }
    False;
}   


