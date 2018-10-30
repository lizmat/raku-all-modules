use Test;
use Hydrate;

{
  class Inner {
    has $.a;
    has Int $.b;
  }
  class Outer {
    has Inner $.inner;
  }

  my %data = inner => {a => 'hey', b => 3};
  is 'hey', hydrate(Outer, %data).inner.a,
    "Basic hydratation works";
  is 3, %data<inner><b>,
    "Input hash is not destroyed";
}

{
  my class Ex {
    has $.a;
  }

  my %data;
  is Any, hydrate(Ex, %data).a,
    "It allows empty non-required attributes";
}

{
  my class Ex {
    has $.a is required;
  }

  my %data;
  dies-ok { hydrate(Ex, %data) },
    "It should fail if a required attribute is missing";
}

{
  my class Ex {
  }

  my %data = foo => 'bar';
  dies-ok { hydrate(Ex, %data, :error-on-extra) },
    "You can forbid extra attributes";
}

{
  my class Inner {
    has $.val;
  }

  my class Outer {
    has Inner @.inners;
  }

  my %data = inners => [{val => 1}, {val => 2}, {val => 3}];
  is 1, hydrate(Outer, %data).inners[0].val,
    "Can hydrate arrays as well";
}
