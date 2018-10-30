use lib 'lib';
use Test;
use Trait::IO;

plan 19;

class Foo {
    method close {
        pass "called method close ($(++$))";
    }
}

for ^10     { my $fh does auto-close = Foo.new; }
if 42       { my $fh does auto-close = Foo.new; }
unless 0    { my $fh does auto-close = Foo.new; }
with 42     { my $fh does auto-close = Foo.new; }
without Int { my $fh does auto-close = Foo.new; }

my $fh1 does auto-close = Foo.new if 42;
my $fh2 does auto-close = Foo.new unless 0;
my $fh3 does auto-close = Foo.new given 42;
my $fh4 does auto-close = Foo.new with 42;
my $fh5 does auto-close = Foo.new without Int;
