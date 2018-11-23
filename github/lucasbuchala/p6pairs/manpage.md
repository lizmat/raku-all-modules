
# NAME

Duo - An alternative pair object for Perl 6

# SYNOPSIS

```perl6
use Duo;

dd Duo.new;        #=> duo(Any, Any)
dd Duo.new(1, 2);  #=> duo(1, 2)
```

```perl6
use Duo::Util;

dd duo;                    #=> duo(Any, Any)
dd duo(1, 2);              #=> duo(1, 2)
dd duo(key=>1, value=>2);  #=> duo(1, 2)

dd duo(duo(1, 2));  #=> duo(1, 2)
dd duo([1, 2]);     #=> duo(1, 2)
dd duo((1, 2));     #=> duo(1, 2)
dd duo(1..2);       #=> duo(1, 2)
dd duo(1=>2);       #=> duo(1, 2)

# Coercions
dd duo(1, 2).Pair;     #=> 1 => 2
dd duo(1, 2).List;     #=> (1, 2)
dd duo(1, 2).Array;    #=> Array element = [1, 2]
dd duo(1, 2).Hash;     #=> Hash % = {"1" => 2}
dd duo(1, 2).Slip;     #=> slip(1, 2)
dd duo(1, 2).Range;    #=> 1..2
dd duo(1, 2).Rat;      #=> 0.5
dd duo(1, 2).Complex;  #=> <1+2i>

dd duo.set(1, 2);   #=> duo(1, 2)
dd duo(1, 2).flip;  #=> duo(2, 1)

# .gist vs .Str
dd duo([1, 2], [3, 4]).Str;   #=> "1 2 => 3 4"
dd duo([1, 2], [3, 4]).gist;  #=> "[1 2] => [3 4]"
```

# SEE ALSO

* https://docs.perl6.org/type/Pair
* https://github.com/rakudo/rakudo/blob/master/src/core/Pair.pm6
