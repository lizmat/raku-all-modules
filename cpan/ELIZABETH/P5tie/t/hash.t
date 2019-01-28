use v6.c;
use Test;
use P5tie;

my int $tiehashed;
my int $fetched;
my int $stored;
my int $existed;
my int $deleted;
my int $cleared;
my int $firstkeyed;
my int $nextkeyed;
my int $scalared;
my int $untied;
my int $tested;

class Foo {
    has Int %.tied;
    has @.keys;
    has int $.index is rw;
    our sub TIEHASH($self)       is raw { ++$tiehashed; $self.new               }
    our sub FETCH($self,$k)      is raw { ++$fetched; $self.tied.AT-KEY($k)     }
    our sub STORE($self,$k,\val) is raw {++$stored; $self.tied.ASSIGN-KEY($k,val)}
    our sub EXISTS($self,$k)            { ++$existed; $self.tied.EXISTS-KEY($k) }
    our sub DELETE($self,$k)            { ++$deleted; $self.tied.DELETE-KEY($k) }
    our sub CLEAR($self)                { ++$cleared; $self.tied = ()           }
    our sub FIRSTKEY($self) is raw {
        ++$firstkeyed;
        ($self.keys = $self.tied.keys)[$self.index = 0]
    }
    our sub NEXTKEY($self,$k)    is raw {++$nextkeyed; $self.keys[++$self.index]}
    our sub SCALAR($self)        is raw { ++$scalared; ?$self.tied              }
    our sub UNTIE($self) is raw         { ++$untied; $self.tied                 } 
    our sub DESTROY($self)              {                                       }
}

class Bar {
    has Int %.tied;
    has @!keys;
    has int $!index;
    method TIEHASH()      is raw { ++$tiehashed; self.new               }
    method FETCH($k)      is raw { ++$fetched; %!tied.AT-KEY($k)        }
    method STORE($k,\val) is raw { ++$stored; %!tied.ASSIGN-KEY($k,val) }
    method EXISTS($k)            { ++$existed; %!tied.EXISTS-KEY($k)    }
    method DELETE($k)            { ++$deleted; %!tied.DELETE-KEY($k)    }
    method CLEAR()               { ++$cleared; %!tied = ()              }
    method FIRSTKEY() is raw {
        ++$firstkeyed;
        (@!keys = %!tied.keys)[$!index = 0]
    }
    method NEXTKEY($k)    is raw { ++$nextkeyed; @!keys[++$!index]      }
    method SCALAR()       is raw { ++$scalared; ?%!tied                 }
    method UNTIE()        is raw { ++$untied; %!tied                    } 
    method DESTROY()             {                                      }
}

class Baz is Bar { }

my @interfaces = Foo, Bar, Baz;
plan 7 * @interfaces;

sub test-access(
  int :$tiehash,
  int :$fetch = 1,
  int :$store,
  int :$exists,
  int :$delete,
  int :$clear,
  int :$firstkey,
  int :$nextkey,
  int :$scalar,
  int :$untie,
) {
    subtest {
        plan 4;
        is $tiehashed, $tiehash, 
          "did we {"NOT " unless $tiehash}see a TIEHASH?";
        ok $fetched >= $fetch, 
          "did we see at least $fetch FETCH(es)?";
        is $stored, $store,
          "did we {"NOT " unless $store}see a STORE?";
        is $untied, $untie,
          "did we {"NOT " unless $untie}see an UNTIE?";
        $tiehashed = $fetched    = $stored    = $existed  = $deleted =
          $cleared = $firstkeyed = $nextkeyed = $scalared = $untied  = 0;
    }, "test accesses #{++$tested} of tied array";
}

for @interfaces -> $class {
    my $object = tie my %a, $class;
    isa-ok $object, $class, "is the object a {$class.^name}?";
    is %a<a>, Int, 'did we get Int';
    test-access(:1tiehash);

    %a<a> = 666;
    is %a<a>, 666, 'did we get 666';
    test-access(:1store);

    ++%a<a>;;
    is %a<a>, 667, 'did we get 667';
    test-access(:1store);
}

# vim: ft=perl6 expandtab sw=4
