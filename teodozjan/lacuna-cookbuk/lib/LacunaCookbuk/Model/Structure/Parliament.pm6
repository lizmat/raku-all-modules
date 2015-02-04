use v6;

use LacunaCookbuk::Model::Empire;
use LacunaCookbuk::Model::LacunaBuilding;

class Parliament is LacunaBuilding;

constant $URL = '/parliament';

method view_propositions {
    return rpc($URL).view_propositions(session_id, self.id)<propositions>;
}

method cast_vote($vote_id, $vote) {    
    rpc($URL).cast_vote(session_id, self.id, $vote_id, $vote)<proposition>;
}
