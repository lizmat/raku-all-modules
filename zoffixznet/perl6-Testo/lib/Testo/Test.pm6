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
  # Str() $program, $desc,
  # Stringy :$in, :@args, :$out, :$err, :$status
    # @!tests.push: my $test := Testo::Test::IsRun.new:
    #     :$program, :$desc, :$in, :@args, :$out, :$err, :$status;
    # $!out.put: $test.result
    submethod TWEAK {
        $!desc //= "NYI"
    }
    method !test {
        False
    }
}
