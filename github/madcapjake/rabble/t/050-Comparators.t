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

plan 4;

.run: '2 2 = .';
is $out.said, 'True', 'eq';

.run: '2 1 <> .';
is $out.said, 'True', 'noteq';

.run: '5 1 > .';
is $out.said, 'True', 'gt';

.run: '1 5 < .';
is $out.said, 'True', 'lt';
