use v6.c;
use Test;

use lib 'lib';
use Rabble;

class Output is IO::Handle {
  has $.said;
  method say(*@args) { $!said = @args }
}
my Output $out .= new;

my Rabble $rabble .= new;
isa-ok $rabble, Rabble;

done-testing;
