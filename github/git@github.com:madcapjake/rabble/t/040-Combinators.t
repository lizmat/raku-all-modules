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

.run: '5 [1 +] apply .';
is $out.said, '6', 'dot';

.run: '5 10 [2 +] dip * .';
is $out.said, '70', 'dip down and apply under last elem';

done-testing;
