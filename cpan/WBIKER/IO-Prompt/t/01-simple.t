use IO::Prompt;
use Test;

my @tests = (
##  Basic y/n questions
##  method  quest   default         output         answer expected
[ q{ask_yn( 'da1?', Bool::True  )}, 'da1? [Y/n] ', 'yai', Bool::True  ],
[ q{ask_yn( 'da2?', Bool::False )}, 'da2? [y/N] ', 'yai', Bool::True  ],
[ q{ask_yn( 'da3?', Nil         )}, 'da3? [y/n] ', 'yai', Bool::True  ],
[ q{ask_yn( 'da4?'              )}, 'da4? [y/n] ', 'yai', Bool::True  ],
[ q{ask_yn( 'db1?', Bool::True  )}, 'db1? [Y/n] ', 'Y',   Bool::True  ],
[ q{ask_yn( 'db2?', Bool::False )}, 'db2? [y/N] ', 'Y',   Bool::True  ],
[ q{ask_yn( 'db3?', Nil         )}, 'db3? [y/n] ', 'Y',   Bool::True  ],
[ q{ask_yn( 'db4?'              )}, 'db4? [y/n] ', 'Y',   Bool::True  ],

[ q{ask_yn( 'da5?', Bool::True  )}, 'da5? [Y/n] ', 'nai', Bool::False ],
[ q{ask_yn( 'da6?', Bool::False )}, 'da6? [y/N] ', 'nai', Bool::False ],
[ q{ask_yn( 'da7?', Nil         )}, 'da7? [y/n] ', 'nai', Bool::False ],
[ q{ask_yn( 'da8?'              )}, 'da8? [y/n] ', 'nai', Bool::False ],
[ q{ask_yn( 'db5?', Bool::True  )}, 'db5? [Y/n] ', 'N',   Bool::False ],
[ q{ask_yn( 'db6?', Bool::False )}, 'db6? [y/N] ', 'N',   Bool::False ],
[ q{ask_yn( 'db7?', Nil         )}, 'db7? [y/n] ', 'N',   Bool::False ],
[ q{ask_yn( 'db8?'              )}, 'db8? [y/n] ', 'N',   Bool::False ],

[ q{ask_yn( 'da9?', Bool::True  )}, 'da9? [Y/n] ', '',    Bool::True  ],
[ q{ask_yn( 'd10?', Bool::False )}, 'd10? [y/N] ', '',    Bool::False ],

[ q{ask_yn( 'qa9?', Nil         )}, 'Please enter yes or no', '',    Bool ],
[ q{ask_yn( 'q10?'              )}, 'Please enter yes or no', '',    Bool ],
[ q{ask_yn( 'wa9?', Bool::True  )}, 'Please enter yes or no', 'Daa', Bool ],
[ q{ask_yn( 'w10?', Bool::False )}, 'Please enter yes or no', 'Daa', Bool ],
[ q{ask_yn( 'wa9?', Nil         )}, 'Please enter yes or no', 'Daa', Bool ],
[ q{ask_yn( 'w10?'              )}, 'Please enter yes or no', 'Daa', Bool ],

##  rational number tests
##  method   quest  default   output          answer   expected
[ q{ask_num( 'r1?', 10.01 )}, 'r1? [10.01] ', '10.01', 10.01  ],
[ q{ask_num( 'r2?', 20.02 )}, 'r2? [20.02] ', '24.24', 24.24  ],
[ q{ask_num( 'r3?'        )}, 'r3? [Num] ',   '11.11', 11.11  ],
[ q{ask_num( 'r4?',  3e2   )}, 'r4? [300] ',   '3e2'  , 300    ],

[ q{ask_int( 'i1?', 10 )},    'i1? [10] ',    '42',    42 ],
[ q{ask_int( 'i2?', 20 )},    'i2? [20] ',    '24',    24 ],
[ q{ask_int( 'i3?'     )},    'i3? [Int] ',   '11',    11 ],

[ q{ask_num( 'rA?', 10.01 )}, 'Please enter a valid number',  'aaa', Numeric ],
[ q{ask_num( 'rB?'        )}, 'Please enter a valid number',  '',    Numeric ],
[ q{ask_int( 'iA?', 10    )}, 'Please enter a valid integer', 'aaa', Int ],
[ q{ask_int( 'iB?'        )}, 'Please enter a valid integer', '',    Int ],

);

## One test for loading the package, two tests for each row above:
## 1) expected result value, 2) expected console output
plan 1 + @tests * 2;

## Subclass a testable version
class IO::Prompt::Testable is IO::Prompt {
    has $.do_input_buffer  is rw = '';
    has $.do_prompt_answer is rw = '';
    method _do_say( Str $question ) returns Bool {
        $.do_input_buffer = $question;
        return Bool::False; # do not continue
    }
    method _do_prompt( Str $question ) returns Str {
        $.do_input_buffer = $question;
        return $.do_prompt_answer;
    }
}

my $prompt = IO::Prompt::Testable.new();

isa-ok( $prompt, IO::Prompt, 'create object' );

for @tests -> @row {
    my ($call, $output, $answer, $expected) = @row;

    ## Setup the answer "the user" will give
    ## see ::Testable class specs above.
    $prompt.do_prompt_answer = $answer;

    ## Setup the call. Cannot use symbolic
    ## coderef see Radudo RT #64848
    my $strtoeval = '$prompt.' ~ $call;
    my $result = EVAL( $strtoeval );

    ## Test for the expected return value
    is(
        $result,
        $expected,
        "call {$call.perl} answer {$answer.perl}" ~
        " => {$result.perl} expected {$expected.perl}"
    );

    ## Test for the expected console output
    is(
        $prompt.do_input_buffer,
        $output,
        "call {$call.perl} => {$prompt.do_input_buffer.perl}" ~
        " expected {$output.perl}"
    );
}
# vim: ft=perl6
