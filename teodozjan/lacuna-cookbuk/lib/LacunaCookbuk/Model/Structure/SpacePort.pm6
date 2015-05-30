use v6;

use LacunaCookbuk::Model::Empire;
use LacunaCookbuk::Model::LacunaBuilding;

unit class SpacePort is LacunaBuilding;

constant $URL = '/spaceport';

has $.max_ships;
has $.docks_available;
has %.docked_ships;

method view_all_ships {
    rpc($URL).view_all_ships(session_id,self.id)<ships>;
}

method scuttle_ship($id) {
rpc($URL).scuttle_ship(session_id, self.id, $id)

}
