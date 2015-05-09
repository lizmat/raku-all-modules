# Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

role Test::Builder::Test::Generic {
    has      $.passed;
    has Int  $.number     = 0;
    has Str  $.diagnostic = '???';
    has Str  $.description;

    method status() returns Hash {
        return {
            passed      => $.passed,
            description => $.description
        };
    }

    method report() returns Str {
        my $result = $.passed ?? 'ok ' !! 'not ok ';

        $result   ~= $.number;
        $result   ~= " - $.description" if $.description;

        return $result;
    }

    method verbose_report(%verbose) returns Str {
        my $got      = %verbose<got>;
        my $expected = %verbose<expected>;

        my Str $msg  =  '    got: ' ~ $got ~ "\n";
        $msg        ~= 'expected: ' ~ $expected;

        return $msg;
    }
}

role Test::Builder::Test::Reason does Test::Builder::Test::Generic {
    has Str $.reason;

    #submethod BUILD($.reason) { }

    # XXX Consider making status() generic, i.e. has no definition
    method status() returns Hash {
        my %status      = self.SUPER::status;
        %status<reason> = $.reason;

        return %status;
    }
}

class Test::Builder::Test::Pass does Test::Builder::Test::Generic { }
class Test::Builder::Test::Fail does Test::Builder::Test::Generic { }

class Test::Builder::Test::Todo does Test::Builder::Test::Reason {
    method report() returns Str {
        my $result = $.passed ?? 'ok' !! 'not ok';
        return join ' ', $result, $.number, "# TODO $.description";
    }

    method status() returns Hash {
        my %status = self.SUPER::status;

        %status<todo>          = Bool::True;
        %status<passed>        = Bool::True;
        %status<really_passed> = $.passed;

        return %status;
    }
}

class Test::Builder::Test::Skip does Test::Builder::Test::Reason {
    method report() returns Str {
        return "not ok $.number \#skip $.reason";
    }

    method status() returns Hash {
        my %status    = self.SUPER::status;
        %status<skip> = Bool::True;

        return %status;
    }
}

class Test::Builder::Test {
    has $!passed;
    has $!number;
    has $!diag;
    has $!description;

    method new(Int  :$number,
               Bool :$passed      = Bool::True,
               Bool :$skip        = Bool::False,
               Bool :$todo        = Bool::False,
               Str  :$reason      = '',
               Str  :$description = '') {

        return Test::Builder::Test::Todo.new(:description($description),
                                             :passed($passed),
                                             :reason($reason),
                                             :number($number)) if $todo;

        return Test::Builder::Test::Skip.new(:description($description),
                                             :passed(Bool::True),
                                             :reason($reason),
                                             :number($number)) if $skip;

        return Test::Builder::Test::Pass.new(:description($description),
                                             :passed(Bool::True),
                                             :number($number)) if $passed;

        return Test::Builder::Test::Fail.new(:description($description),
                                             :passed(Bool::False),
                                             :number($number));
    }

    method report() returns Str {
        my $result = $!passed ?? 'ok ' !! 'not ok ';

        $result   ~= $!number;
        $result   ~= " - $!description" if $!description;

        return $result;
    }
}

# vim: ft=perl6

