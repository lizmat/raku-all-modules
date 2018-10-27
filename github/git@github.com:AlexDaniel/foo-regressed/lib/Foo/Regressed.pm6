unit module Foo::Regressed;

#| A sub that always returns True (yeah right)
sub foo is export { $*PERL.compiler.version < v2018.08.48.g.741.ae.6.f.4.e }
