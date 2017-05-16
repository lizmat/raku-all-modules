unit package Testo::Test;

use RakudoPrereq v2016.10.177.g.9409.d.68, # TWEAK added
    'Testo::Test module requires Rakudo v2016.11 or newer';

use Testo::Test::Result;

sub desc-perl (Mu $v) {
    my $desc = try $v.perl;
    $! and $desc = $v.^name ~ (' (lazy)' if try $v.is-lazy);
    $desc = $desc.substr(0, 30) ~ '…' if $desc.chars > 30;
    $desc
}

role Testo::Test {
    has $.desc;
    has Testo::Test::Result $!result;

    submethod TWEAK { $!desc //= '' }
    method !test { … }
    method result {
        $!result //= Testo::Test::Result.new: so => self!test.so, :$!desc;
    }
}

class Is does Testo::Test {
    has Mu  $.got    is required;
    has Mu  $.exp    is required;
    submethod TWEAK { $!desc //= "&desc-perl($!got) is &desc-perl($!exp)" }
    method !test { $!got ~~ $!exp }
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
}

class IsRun does Testo::Test {
    has Str:D $.program is required;
    has Stringy $.in;
    has @.args where .all ~~ Cool;
    has $.out;
    has $.err;
    has $.status;

    submethod TWEAK {
        $!desc //= "NYI"
    }
    method !test {
        with run :in, :out, :err, $!program, |@!args {
            $!in ~~ Blob ?? .in.write: $!in !! .in.print: $!in if $!in;
            $ = .in.close;
            my $out    = .out.slurp-rest: :close;
            my $err    = .err.slurp-rest: :close;
            my $status = .exitcode;
        }
        note "***** is-run is NYI yet! *****";
        True
    }
}
