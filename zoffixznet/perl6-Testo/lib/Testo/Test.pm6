unit package Testo::Test;

use RakudoPrereq v2016.10.177.g.9409.d.68, # TWEAK added
    'Testo::Test module requires Rakudo v2016.11 or newer';

use Testo::Test::Result;

sub desc-perl (Mu $v) {
    $v.cache if $v ~~ Seq:D;
    my $desc = try $v.perl;
    $! and $desc = $v.^name ~ (' (lazy)' if try $v.is-lazy);
    $desc = $desc.substr(0, 30) ~ '…' if $desc.chars > 30;
    $desc ~~ tr/\n/␤/;
    $desc
}

role Testo::Test {
    has $.desc;
    has Testo::Test::Result $!result;

    submethod TWEAK { $!desc //= '' }
    method !test { !!! ::?CLASS.^name ~ ' must implement !test' }
    method !fail { Nil }
    method result {
        $!result //= do {
            my $so = self!test.so;
            Testo::Test::Result.new: :$so, :$!desc,
                |(:fail(self!fail) unless $so);

        }
    }
}

class Group does Testo::Test {
    has &.group  is required;
    has $.tester is required;
    has UInt $.plan where .DEFINITE.not || .so;
    method !test {
        $!tester.plan: $!plan if $!plan.DEFINITE;
        &!group();
        $!tester.tests».result».so.all.so
    }
}

class Is does Testo::Test {
    has Mu  $.got    is required;
    has Mu  $.exp    is required;
    submethod TWEAK { $!desc //= "&desc-perl($!got) is &desc-perl($!exp)" }
    method !test { $!got ~~ $!exp }
    method !fail {
          "                     Got: {(try $.got.perl) or $.got.^name}\n"
        ~ "Does not smartmatch with: {(try $.exp.perl) or $.exp.^name}"
    }
}

class IsEqv does Testo::Test {
    has Mu  $.got    is required;
    has Mu  $.exp    is required;
    submethod TWEAK {
        $!desc //= "&desc-perl($!got) is equivalent to &desc-perl($!exp)"
    }
    method !test {
        (try so $!got eqv $!exp) // Failure
    }
    method !fail {
          "            Got: $.got.perl()\n"
        ~ "Does not eqv to: $.exp.perl()"
    }
}

class IsRun does Testo::Test {
    has Str:D $.program is required;
    has Stringy $.in;
    has @.args where .all ~~ Cool;
    has $.out;
    has $.err;
    has $.status;
    has $.tester;

    submethod TWEAK {
        $!desc //= "running $!program"
    }
    method !test {
        with run :in, :out, :err, $!program, |@!args {
            $!in ~~ Blob ?? .in.write: $!in !! .in.print: $!in if $!in;
            $ = .in.close;
            my $out    = .out.slurp-rest: :close;
            my $err    = .err.slurp-rest: :close;
            my $status = .status;

            my $wanted-status = $!status // 0;
            my $wanted-out    = $!out    // '';
            my $wanted-err    = $!err    // '';
            my $*Tester = $!tester.new: group-level => 1+$!tester.group-level;
            $!result = $!tester.group: $*Tester, $!desc => 3 => {
                $*Tester.is: $out,    $wanted-out,    'STDOUT';
                $*Tester.is: $err,    $wanted-err,    'STDERR';
                $*Tester.is: $status, $wanted-status, 'Status';
            }
        }
    }
}
