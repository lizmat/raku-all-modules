use v6.c;
use Test;
use P5tie;

my int $tiescalared;
my int $fetched;
my int $stored;
my int $untied;
my int $tested;

# using sub interface, closer to Perl 5
class Foo {
    has Int $.tied is rw;
    our sub TIESCALAR($self)  is raw { ++$tiescalared; $self.new   }
    our sub FETCH($self)      is raw { ++$fetched; $self.tied      }
    our sub STORE($self,\val) is raw { ++$stored; $self.tied = val }
    our sub UNTIE($self)      is raw { ++$untied; $self.tied       } 
    our sub DESTROY($self)           {                             }
}

# using standard Perl 6 method interface
class Bar {
    has Int $.tied;
    method TIESCALAR() is raw { ++$tiescalared; self.new }
    method FETCH()     is raw { ++$fetched; $!tied       }
    method STORE(\val) is raw { ++$stored; $!tied = val  }
    method UNTIE()     is raw { ++$untied; $!tied        } 
    method DESTROY()          {                          }
}

# using standard Perl 6 subclassing
class Baz is Bar { }

my @interfaces = Foo, Bar, Baz;
plan 7 * @interfaces;

sub test-access(
  int :$tiescalar,
  int :$store,
  int :$untie,
) {

    subtest {
        plan 4;
        is $tiescalared, $tiescalar,
          "did we {"NOT " unless $tiescalar}see a TIESCALAR?";
        ok $fetched > 1,
          'did we see at least one FETCH?';
        is $stored, $store,
          "did we {"NOT " unless $store}see a STORE?";
        is $untied, $untie,
          "did we {"NOT " unless $untie}see an UNTIE?";
        $tiescalared = $fetched = $stored = $untied = 0;
    }, "test accesses #{++$tested} of tied variable";
}

for Foo, Bar, Baz -> $class {
    my $object = tie my $a, $class;
    isa-ok $object, $class, "is the object a {$class.^name}?";
    is $a, Int, 'did we get Int';
    test-access(:1tiescalar);

    $a = 666;
    is $a, 666, 'did we get 666';
    test-access(:1store);

    ++$a;
    is $a, 667, 'did we get 667';
    test-access(:1store);
}

# vim: ft=perl6 expandtab sw=4
