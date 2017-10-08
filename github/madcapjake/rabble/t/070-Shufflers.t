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

plan 7;

.run: '1 2 drop drop .S';
is $out.said, '⊣  ⊢', 'drop removes elems on the stack';

.run: '1 5 nip .S';
is $out.said, '⊣ 5 ⊢', 'nip removes element below topmost element';
.run: 'drop';

.run: '1 dup .S';
is $out.said, '⊣ 1 1 ⊢', 'dup creates a copy of the last element';
.run: 'drop drop';

.run: '1 2 swap .S';
is $out.said, '⊣ 2 1 ⊢', 'swap flips the last two elements';
.run: 'drop drop';

.run: '1 2 3 rot .S';
is $out.said, '⊣ 2 3 1 ⊢', 'rot swaps the first to be last of three';
.run: 'drop drop drop';

.run: '1 2 und .S';
is $out.said, '⊣ 1 2 1 ⊢', 'und takes one under and dups it on top';
.run: 'drop drop drop';

.run: '1 2 tuck .S';
is $out.said, '⊣ 2 1 2 ⊢', 'tuck takes top of stack and places under second-to-last';
