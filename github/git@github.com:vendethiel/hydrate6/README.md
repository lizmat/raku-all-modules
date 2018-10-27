Hydrate
=======

Hydrate is a small module to "hydrate" (ORM speak) your object hierarchy, from a bunch of hashes.

Example:

```perl6
use Hydrate;

my class Mes {
  has Int $.height;
  has Int $.width;
}

my class Cont {
  has Str $.name is required;
  has Mes @.mesures;
  has %.data; # optional 
}

say hydrate(Cont, {
  name => "Some mesures",
  mesures => [
    {height => 50,  width => 50},
    {height => 150, width => 75},
    {height => 200, width => 200},
  ]
})
```

Result:

```perl6
Cont.new(
  name => "Some mesures",
  mesures => Array[Mes].new(
    Mes.new(height => 50, width => 50),
    Mes.new(height => 150, width => 75),
    Mes.new(height => 200, width => 200)
  ),
  data => {},
)
```
