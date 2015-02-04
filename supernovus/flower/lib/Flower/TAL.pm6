use Flower;
class Flower::TAL is Flower; 

## Extend Flower into a TAL/METAL engine.

use Flower::TAL::TAL;
use Flower::TAL::METAL;

submethod BUILD () {
  self.add-plugin(Flower::TAL::METAL); ## We parse METAL first.
  self.add-plugin(Flower::TAL::TAL);   ## Then we parse TAL.
}

## Add a TALES plugin.
method add-tales ($tale) {
  for @.plugins -> $plugin {
    if $plugin ~~ Flower::TAL::TAL {
      $plugin.tales.add-plugin($tale);
      last;
    }
  }
}

