use Testo::Out;
unit class Testo::Out::TAP does Testo::Out;
use Testo::Test::Result;

has UInt:D $.group-level = 0;
has $!out = $*OUT;
has $!count = 0;

method !indents { "\c[SPACE]" x 4*$!group-level }

method plan (Int $n) { $!out.say: self!indents ~ "1..$n" }

multi method put ($) {}
multi method put (Testo::Test::Result:D $test) {
    $!count++;
    $!out.say: $test.so ?? self!indents ~ "ok $!count - $test.desc()"
                        !! self!indents ~ "not ok $!count - $test.desc()"
}
