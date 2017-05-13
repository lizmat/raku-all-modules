use Testo::Out;
unit class Testo::Out::TAP does Testo::Out;
use Testo::Test::Result;

has $!out = $*OUT;
has $!count = 0;

method plan (Int $n) { $!out.say: "1..$n" }

method put (Testo::Test::Result:D $test) {
    $!count++;
    $!out.say: $test.so ?? "ok $!count - $test.desc()"
                        !! "not ok $!count - $test.desc()"
}
