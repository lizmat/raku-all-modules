unit class Testo::Tester;
use Testo::Test;
use Testo::Out;

has Testo::Out $.out;
has @.tests where .all ~~ Testo::Test;

method !SET-SELF (:$!out) {self}
method new (Str:D :$format = 'TAP') {
    my $out = "Testo::Out::$format";
    (try require ::($out)) === Nil and die "Failed to load formatter $out: $!";
    self.bless!SET-SELF: out => ::($out).new
}

method plan ($n) { $!out.plan: $n }

method is (Mu $got, Mu $exp, $desc?) {
    @!tests.push: my $test := Testo::Test::Is.new: :$got, :$exp, :$desc;
    $!out.put: $test.result
}

method is-eqv (Mu $got, Mu $exp, $desc?) {
    @!tests.push: my $test := Testo::Test::IsEqv.new: :$got, :$exp, :$desc;
    $!out.put: $test.result
}

method is-run (
  Str() $program, $desc?,
  Stringy :$in, :@args, :$out, :$err, :$status
) {
    @!tests.push: my $test := Testo::Test::IsRun.new:
        :$program, :$desc, :$in, :@args, :$out, :$err, :$status;
    $!out.put: $test.result
}
