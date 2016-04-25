use v6.c;
use Test;

use lib 'lib';
use Rabble;

class Output is IO::Handle {
  has $.said;
  method say(*@args) { $!said = @args }
  method print($char) { $!said ~= $char }
}
my Output $out .= new;

$_ = Rabble.new(:$out);

plan 2;

.run: '72 emit 105 emit 33 emit 10 emit';
is $out.said, "Hi!\n", 'emit prints number as char';
.run: 'drop drop drop drop';

.run: '1 2 3 .S';
is $out.said, '⊣ 1 2 3 ⊢', 'dot-s prints the stack';
