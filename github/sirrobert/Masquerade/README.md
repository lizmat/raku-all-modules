Masquerade
================

Let Perl 6 constructs masquerade as other things.

Overview
--------

Sometimes you want to be able to use Perl 6 objects as if they were
something else, such as JSON.  Masquerade allows for quick, painless (but
simple) re-renderings.

**AsIf::***
Masquerade provides a set of roles.  Each role allows objects to masquerade as if other objects.  The roles do 'not' have the `Masquerade` prefix.  For example, if you
```
use Masquerade;
```
you will get a role called `AsIf::JSON` (rather than ~~`Masquerade::AsIf::JSON`~~).

Examples
--------
Sometimes you have objects you want to render differently.

### "Primitives" (hashes, arrays, strings, etc.)

Let's look at how we could use Masquerade to emit a json rendering of a hash containing an array.

```perl6
use Masquerade;

my %agenda = {
  parties => 2,
  meetings => 3,
  color-choices => <red blue green>,
};

say %agenda but AsIf::JSON;
# output:
# { "parties" : 2, "meetings" : 3, "color-choices" : [ "red", "blue", "green" ] }
```

### Class-based objects
That's well and good, but what about more complex stuff?  The following example shows how to render a class instance as if it were JSON.

```perl6
use Masquerade;

##
# Try a more complex perl object.
class Weather::Phenomenon {
  has $!id;
  has $.name;
  has $.description;
  has %.properties;
  has @.affects;
};

my $tornado = Weather::Phenomenon.new(
  id          => 123,
  name        => 'tornado',
  description => 'a twister!',
  properties  => {
    twistiness  => 100,
    windiness   => 88, 
    size        => 40, 
  },  
  affects     => <Houses Barns Couches Chickens>
);

say $tornado but AsIf::JSON;

# output (note that it won't actually be pretty-printed; that's just for illustrative purposes here).
# { 
#   "name" : "tornado",
#   "description" : "a twister!",
#   "properties" : { 
#     "twistiness" : 100, 
#     "windiness" : 88,
#     "size" : 40 
#   }, 
#   "affects" : [ "Houses", "Barns", "Couches", "Chickens" ]
# }
```
Notice that the private property $!id is not rendered in the JSON.  The JSON is considered to be a JSON rendering of the public interface to the object.


On the other hand, sometimes you want to go the other way.  You can also
extract useful bits out of things (only JSON is supported right now) as if
they were Perl.

The following examples let you access JSON strings as if it were Perl:

```perl6
use Masquerade;

my $json = '{"foo": "bar"}';
say ($json but AsIf::Perl)<foo>;  # bar
```

```perl6
use Masquerade;

my $json = '[12.4, "pickle"]';
say ($json but AsIf::Perl)[1];  # pickle
```

These are read-only operations right now.


===AsIf::YAML

Let's say you have some objects and want to render them as YAML.  No
problem-- just `say` them, `but AsIf::YAML`.

```perl6
use Masquerade;

my %tornado = { 
  size        => "medium",
  damage      => "high",
  affects     => [<Houses Barns Cars Chickens Cows>],
  attributes  => {
    twistiness  => 100,
    color       => 'brown/grey',
    scariness   => 6,
    speed       => {
      velocity  => '92mph',
      direction => 'at YOU!',
    }   
  },  
};

say %tornado but AsIf::YAML;
```

This produces the following output:

```
size:       medium
damage:     high
affects:    
  - Houses
  - Barns
  - Cars
  - Chickens
  - Cows
attributes: 
  twistiness: 100
  color:      brown/grey
  scariness:  6
  speed:      
    velocity:  92mph
    direction: at YOU!
```

In addition to perl's built-in data structures, you can also do a rendering of custom objects.

```perl6
use Masquerade;

class TestClass {
  has $.animal = "monkey";
  has $.money  = "dollar";
  has @.veggies;
  has %.cities;
};

my $test = TestClass.new(
  veggies => <zucchini squash broccoli>,
  cities  => {
    London => 'England',
    Durham => 'The United States of America',
  }   
);  

say $test but AsIf::YAML;
```

This produces the following output:

```
animal:  monkey
money:   dollar
veggies: 
  - zucchini
  - squash
  - broccoli
cities:  
  London: England
  Durham: The United States of America
```










