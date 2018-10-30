
use v6;

use Parse::Selenese::Actions;
use Parse::Selenese::Grammar;

unit class Parse::Selenese;

method parse(Str $source, $actions = Parse::Selenese::Actions.new) {
  return Parse::Selenese::Grammar.parse($source, :actions($actions));
}
