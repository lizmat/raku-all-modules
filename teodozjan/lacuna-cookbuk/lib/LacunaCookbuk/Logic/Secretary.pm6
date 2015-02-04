use v6;

use LacunaCookbuk::Model::Inbox;

class LacunaCookbuk::Logic::Secretary;

method clean(@tags){
    my Inbox $box .= new;
    my @to_del;
    while (@to_del = $box.view_inbox(@tags).map({.<id>})) {
    say "Delete:" ~ $box.trash_messages(@to_del);
    }
}
