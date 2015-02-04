use v6;

use LacunaCookbuk::Model::LacunaBuilding;

class Development is LacunaBuilding;

constant $URL = '/development';

has Hash @.build_queue;

method full returns Bool {
    self.view.level < self.build_queue.elems
}
