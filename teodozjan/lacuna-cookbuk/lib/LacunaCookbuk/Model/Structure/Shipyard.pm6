use v6;

use LacunaCookbuk::Model::Empire;
use LacunaCookbuk::Model::LacunaBuilding;

class Shipyard is LacunaBuilding;

constant $URL = '/shipyard';

method get_buildable {
    rpc($URL).get_buildable(session_id,self.id)<buildable>
}
