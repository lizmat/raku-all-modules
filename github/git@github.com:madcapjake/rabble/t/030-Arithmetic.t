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

plan 11;

.run: '5 2 + .';
is $out.said, "7", 'addition';

.run: '5 2 * .';
is $out.said, '10', 'multiplication';

.run: '5 2 - .';
is $out.said, '3', 'subtraction';

.run: '10 2 / .';
is $out.said, '5', 'division';

.run: '10 2 % .';
is $out.said, '0', 'modulo';

.run: '10 3 % .';
is $out.said, '1', 'modulo w/ remainder';

.run: '14 6 /% .';
is $out.said, '3', 'ratdiv: quotient';
.run: '.';
is $out.said, '7', 'ratdiv: remainder';

.run: '-10 abs .';
is $out.said, '10', 'absolute';

.run: '1 inc .';
is $out.said, '2', 'inc';

.run: '1 dec .';
is $out.said, '0', 'dec';
