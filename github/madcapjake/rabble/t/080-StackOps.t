use v6.c;
use Test;

use lib 'lib';
use Rabble;

class Output is IO::Handle {
  has $.said;
  method say(*@args) { $!said = @args }
}
my Output $out .= new;

$_ = Rabble.new(:$out);

.run: '5 .';
is $out.said, '5', 'dot';

.run: '1 1 + .';
is $out.said, '2', 'dot says/pops last value only';

done-testing;
