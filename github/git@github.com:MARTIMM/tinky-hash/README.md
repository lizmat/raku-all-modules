# Configuration refinements
[![Build Status](https://travis-ci.org/MARTIMM/config-datalang-refine.svg?branch=master)](https://travis-ci.org/MARTIMM/tinky-hash)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/MARTIMM/tinky-hash?branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending&svg=true)](https://ci.appveyor.com/project/MARTIMM/tinky-hash/branch/master)
[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

# Synopsis
```
use Tinky::Hash;

class MyStateEngine is Tinky::Hash {

  submethod BUILD ( ) {

    self.from-hash(
      :config( {
          :states([< a z q>]),
          :transitions( {
              :az( { :from<a>, :to<z>}),
              :za( { :from<z>, :to<a>}),
              :zq( { :from<z>, :to<q>}),
              :qa( { :from<q>, :to<a>}),
            }
          ),
          :workflow( { :name<wf4>, :initial-state<a>}),
          :taps( {
              :states( { :q( { :enter<enter-q>})})
              :transitions( { :zq<tr-zq>}),
            }
          ),
        }
      )
    );
  }

  method tr-zq ( $object, Tinky::Transition $trans, Str :$transit ) {
    say "specific transition $transit '", $object.^name,
        "' '$trans.from.name()' ===>> '$trans.to.name()'";
    is $trans.from.name, 'z', "Comes from 'z'";
    is $trans.to.name, 'q', "Goes to 'q'";
  }

  method enter-q ( $object, Str :$state, EventType :$event) {
    say "state enter event: enter q in ", $object.^name;
    is $state, 'q', 'state is q';
    is $event, Enter, 'event is Enter';
  }
}

my MyStateEngine $th .= new;

$th.workflow('wf4');
say $th.state.name;             # 'a'
say $th.next-states>>.name;     # ('z',)

$th.go-state('z');
say $th.state.name;             # 'z'
say $th.next-states>>.name;     # (<a q>)

# specific transition zq 'MyStateEngine' 'z' ===>> 'q'
# state enter event: enter q in MyStateEngine

$th.go-state('q');


```

# Documentation

Please look also at the Tinky documentation of Jonathon Stowe and his story at
the perl6 advent calendar 18th december 2016 to understand the purpose of Tinky.
After that it will be easy to grasp the use of this module.

* [Tinky](https://github.com/jonathanstowe/Tinky)
* [Perl6 advent calendar](https://perl6advent.wordpress.com/2016/12/18/)

Documentation about this class and other information at
* [Tinky::Hash](https://github.com/MARTIMM/tinky-hash/blob/master/doc/Hash.pdf)
* [Release notes](https://github.com/MARTIMM/tinky-hash/blob/master/doc/CHANGES.md)
* [Todo and Bugs](https://github.com/MARTIMM/tinky-hash/blob/master/doc/TODO.md)


# Author

```Marcel Timmerman: MARTIMM on github```
