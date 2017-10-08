unit class Testo::Tester;
use Testo::Test;
use Testo::Out;

has Testo::Out $.out;
has UInt:D $.group-level = 0;
has @.tests where .all ~~ Testo::Test;
has $!plan;

method new (Str:D :$format = 'TAP', UInt:D :$group-level = 0) {
    my $out = "Testo::Out::$format";
    (try require ::($out)) === Nil and die "Failed to load formatter $out: $!";
    self.bless: :$format, :$group-level, out => ::($out).new: :$group-level
}

multi method group (
    Testo::Tester $tester,
    Pair (Str:D :key($desc), :value(&group)),
    :$silent,
) {
    @!tests.push: my $test := Testo::Test::Group.new: :$tester, :$desc, :&group;
    given $test.result {
        $!out.put: $_ unless $silent;
        $_
    }
}

multi method group (
    Testo::Tester $tester,
    Pair (
        Str  :key($desc),
        Pair :value((
            UInt :key($plan) where .so,
                 :value(&group))))
) {
    @!tests.push: my $test := Testo::Test::Group.new:
        :$tester, :$desc, :&group, :$plan;
    $!out.put: $test.result
}

method plan ($!plan) { $!out.plan: $!plan }

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
  --> Testo::Test::Result:D
) {
    my $test := Testo::Test::IsRun.new:
        :$program, :$desc, :$in, :@args, :$out, :$err, :$status, :tester(self);
    $test.result;
}

method done-testing {
    # dd [ +@!tests, $!plan, @!tests == $!plan ];
    exit 255 unless @!tests and @!tests == $!plan;
    my $failed = +@!tests.grep: *.result.so.not
        and exit $failed min 254;
    exit;
}
