class Flower::TAL::Repeat;

## Represents a TAL Repeat object.

has $.index;
has $.length;

method number { $.index + 1           }
method start  { $.index == 0          }
method end    { $.index == $.length-1 }
method odd    { $.number % 2 != 0      }
method even   { $.number % 2 == 0      }

method inner  { $.index != 0 && $.index != $.length-1 }

## Flower exclusive methods below here, make lists and tables easier.
method every  ($num) { $.number % $num == 0 }
method skip   ($num) { $.number % $num != 0 }
method lt     ($num) { $.number < $num      }
method gt     ($num) { $.number > $num      }
method eq     ($num) { $.number == $num     }
method ne     ($num) { $.number != $num     }
method gte    ($num) { $.number >= $num     }
method lte    ($num) { $.number <= $num     }

## Versions of every and skip that also match on start.
method repeat-every ($num) { $.start || $.every($num) }
method repeat-skip  ($num) { $.start || $.skip($num)  }

