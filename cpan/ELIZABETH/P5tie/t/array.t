use v6.c;
use Test;
use P5tie;

my int $tiearrayed;
my int $fetched;
my int $stored;
my int $fetchsized;
my int $storesized;
my int $extended;
my int $existed;
my int $deleted;
my int $cleared;
my int $pushed;
my int $popped;
my int $shifted;
my int $unshifted;
my int $spliced;
my int $untied;
my int $tested;

class Foo {
    has Int @.tied;
    our sub TIEARRAY($self)      is raw { ++$tiearrayed; $self.new              }
    our sub FETCH($self,$i)      is raw { ++$fetched; $self.tied.AT-POS($i)     }
    our sub STORE($self,$i,\val) is raw {++$stored; $self.tied.ASSIGN-POS($i,val)}
    our sub FETCHSIZE($self)            { ++$fetchsized; $self.tied.elems       }
    our sub STORESIZE($self,\val)       { ++$storesized; die                    }
    our sub EXTEND($self,\val)          { ++$extended; die                      }
    our sub EXISTS($self,$i)            { ++$existed; $self.tied.EXISTS-POS($i) }
    our sub DELETE($self,$i)            { ++$deleted; $self.tied.DELETE-POS($i) }
    our sub CLEAR($self)                { ++$cleared; $self.tied = ()           }
    our sub PUSH($self,\val)     is raw { ++$pushed; $self.tied.push(val)       }
    our sub POP($self)           is raw { ++$popped; $self.tied.pop             }
    our sub SHIFT($self)         is raw { ++$shifted; $self.tied.shift          }
    our sub UNSHIFT($self,\val)  is raw { ++$unshifted; $self.tied.unshift(val) }
    our sub SPLICE($self,*@args)        { ++$spliced; $self.tied.splice(|@args) }
    our sub UNTIE($self) is raw         { ++$untied; $self.tied                 } 
    our sub DESTROY($self)              {                                       }
}

class Bar {
    has Int @.tied;
    method TIEARRAY()     is raw { ++$tiearrayed; self.new              }
    method FETCH($i)      is raw { ++$fetched; @!tied.AT-POS($i)        }
    method STORE($i,\val) is raw { ++$stored; @!tied.ASSIGN-POS($i,val) }
    method FETCHSIZE()           { ++$fetchsized; @!tied.elems          }
    method STORESIZE(\val)       { ++$storesized; die                   }
    method EXTEND(\val)          { ++$extended; die                     }    
    method EXISTS($i)            { ++$existed; @!tied.EXISTS-POS($i)    }
    method DELETE($i)            { ++$deleted; @!tied.DELETE-POS($i)    }
    method CLEAR()               { ++$cleared; @!tied = ()              }
    method PUSH(\val)     is raw { ++$pushed; @!tied.push(val)          }
    method POP()          is raw { ++$popped; @!tied.pop                }
    method SHIFT()        is raw { ++$shifted; @!tied.shift             }
    method UNSHIFT(\val)  is raw { ++$unshifted; @!tied.unshift(val)    }
    method SPLICE(*@args)        { ++$spliced; @!tied.splice(|@args)    }
    method UNTIE() is raw        { ++$untied; @!tied                    } 
    method DESTROY()             {                                      }
}

class Baz is Bar { }

my @interfaces = Foo, Bar, Baz;
plan 7 * @interfaces;

sub test-access(
  int :$tiearray,
  int :$fetch = 1,
  int :$store,
  int :$fetchsize,
  int :$storesize,
  int :$extend,
  int :$exists,
  int :$delete,
  int :$clear,
  int :$push,
  int :$pop,
  int :$shift,
  int :$unshift,
  int :$splice,
  int :$untie,
) {
    subtest {
        plan 4;
        is $tiearrayed, $tiearray, 
          "did we {"NOT " unless $tiearray}see a TIEARRAY?";
        ok $fetched >= $fetch, 
          "did we see at least $fetch FETCH(es)?";
        is $stored, $store,
          "did we {"NOT " unless $store}see a STORE?";
        is $untied, $untie,
          "did we {"NOT " unless $untie}see an UNTIE?";
        $tiearrayed = $fetched = $stored    = $fetchsized = $storesized =
          $extended = $existed = $deleted   = $cleared    = $pushed     =
          $popped   = $shifted = $unshifted = $spliced    = $untied     = 0;
    }, "test accesses #{++$tested} of tied array";
}

for @interfaces -> $class {
    my $object = tie my @a, $class;
    isa-ok $object, $class, "is the object a {$class.^name}?";
    is @a[0], Int, 'did we get Int';
    test-access(:1tiearray);

    @a[0] = 666;
    is @a[0], 666, 'did we get 666';
    test-access(:1store);

    ++@a[0];
    is @a[0], 667, 'did we get 667';
    test-access(:1store);
}

# vim: ft=perl6 expandtab sw=4
