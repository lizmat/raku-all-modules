use lib 'lib';
use Test;

plan 9;

my $code = ｢
    my $*PERL := class FakePerl {
        method compiler {
            class FakeCompiler {
                has $.id   = '2357471601F275BAC6F2A55E972FEECEA97BC47'
                  ~ '8.1492376576.44754';
                has $.name = 'rakudo';
                has $.version = v2017.03.290.gf.6387.a.845;
            }.new
        }
    }.new;
    use lib 'lib';
    EVAL 'use RakudoPrereq $ARGS';
    say "alive";
｣;

subtest 'die when given version' => {
    plan 2;
    with run :out, :err, $*EXECUTABLE, '-e', $code.subst('$ARGS', 'v420000') {
        cmp-ok .out.slurp-rest(:close), '~~', *.contains('alive').not, 'died';
        cmp-ok .err.slurp-rest(:close), '~~',
            {.contains('requires Rakudo compiler version v420000')
              and .contains(' v2017.03.290')
              and .contains('EVAL')},
          'error message tells us which Rakudo version needed and where it was';
    }
}

subtest 'die when given version and custom message' => {
    plan 2;
    with run :out, :err, $*EXECUTABLE, '-e', $code.subst(
      '$ARGS', 'v420000, "custom message"'
    ) {
        cmp-ok .out.slurp-rest(:close), '~~', *.contains('alive').not, 'died';
        cmp-ok .err.slurp-rest(:close), '~~',
          {.contains('custom message') and .contains('EVAL')},
          'error message has custom message and location';
    }
}

subtest 'die when given version and rakudo-only' => {
    plan 3;
    with run :out, :err, $*EXECUTABLE, '-e', $code.subst(
      '$ARGS', 'v420000, "", "rakudo-only"'
    ).subst(｢'rakudo'｣, ｢'something else'｣) {
        cmp-ok .out.slurp-rest(:close), '~~', *.contains('alive').not, 'died';
        with .err.slurp-rest(:close) {
            cmp-ok $_, '~~',
                {.contains('requires Rakudo compiler') and .contains('EVAL')},
                'error message tells us we need Rakudo and where it was';
            cmp-ok $_, '~~', *.contains('v420000').not,
                'error does not mention version';
        }
    }
}

subtest 'die when given version and rakudo-only' => {
    plan 3;
    with run :out, :err, $*EXECUTABLE, '-e', $code.subst(
      '$ARGS', 'v420000, "custom message", "rakudo-only"'
    ).subst(｢'rakudo'｣, ｢'something else'｣) {
        cmp-ok .out.slurp-rest(:close), '~~', *.contains('alive').not, 'died';
        with .err.slurp-rest(:close) {
            cmp-ok $_, '~~',
                {.contains('custom message') and .contains('EVAL')},
                'error message has custom message and where it was';
            cmp-ok $_, '~~', *.contains('v420000').not,
                'error does not mention version';
        }
    }
}

subtest 'die when given version and no-where' => {
    plan 2;
    with run :out, :err, $*EXECUTABLE, '-e', $code.subst(
      '$ARGS', 'v420000, "", "no-where"'
    ) {
        cmp-ok .out.slurp-rest(:close), '~~', *.contains('alive').not, 'died';
        cmp-ok .err.slurp-rest(:close), '~~',
            {.contains('requires Rakudo compiler version v420000')
              and .contains(' v2017.03.290')
              and .contains('EVAL').not},
          'error message tells us which Rakudo version needed and no where';
    }
}

subtest 'die when given version and custom message and no-where' => {
    plan 2;
    with run :out, :err, $*EXECUTABLE, '-e', $code.subst(
      '$ARGS', 'v420000, "custom message", "no-where"'
    ) {
        cmp-ok .out.slurp-rest(:close), '~~', *.contains('alive').not, 'died';
        cmp-ok .err.slurp-rest(:close), '~~',
          {.contains('custom message') and .contains('EVAL').not},
          'error message has custom message and no where';
    }
}

subtest 'die when given version and rakudo-only and no-where' => {
    plan 3;
    with run :out, :err, $*EXECUTABLE, '-e', $code.subst(
      '$ARGS', 'v420000, "", "no-where rakudo-only"'
    ).subst(｢'rakudo'｣, ｢'something else'｣) {
        cmp-ok .out.slurp-rest(:close), '~~', *.contains('alive').not, 'died';
        with .err.slurp-rest(:close) {
            cmp-ok $_, '~~',
                {.contains('requires Rakudo compiler')
                  and .contains('EVAL').not},
                'error message tells us we need Rakudo and where it was';
            cmp-ok $_, '~~', *.contains('v420000').not,
                'error does not mention version';
        }
    }
}

subtest 'die when given version and rakudo-only and no-where' => {
    plan 3;
    with run :out, :err, $*EXECUTABLE, '-e', $code.subst(
      '$ARGS', 'v420000, "custom message", "rakUdo-oNly nO-wHeRe"'
    ).subst(｢'rakudo'｣, ｢'something else'｣) {
        cmp-ok .out.slurp-rest(:close), '~~', *.contains('alive').not, 'died';
        with .err.slurp-rest(:close) {
            cmp-ok $_, '~~',
                {.contains('custom message') and .contains('EVAL').not},
                'error message has custom message and where it was';
            cmp-ok $_, '~~', *.contains('v420000').not,
                'error does not mention version';
        }
    }
}

subtest 'die when given invalid options' => {
    plan 2;
    with run :out, :err, $*EXECUTABLE, '-e', $code.subst(
      '$ARGS', 'v420000, "custom message", "rakudo-only no-where blah-blah"'
    ).subst(｢'rakudo'｣, ｢'something else'｣) {
        cmp-ok .out.slurp-rest(:close), '~~', *.contains('alive').not, 'died';
        cmp-ok .err.slurp-rest(:close), '~~',
            { not .contains('custom message')
              and .contains('EVAL')
              and .contains('blah-blah')},
            'error message has custom message and where it was';
    }
}
