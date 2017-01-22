use v6;
use Test;
use Test::Output;
use lib 'lib';
use JS::Minify;
 
plan 20;

sub min-test($filename) {
  my $infile = open("t/scripts/$filename.js", :r) or die("couldn't open file");
  my $minified = js-minify(input => $infile);
  my $expected_output = slurp("t/scripts/{$filename}-expected.js", :r) or die("couldn't open file");
  is $minified, $expected_output, "testing $filename";
}

min-test('s2');  # missing semi-colons
min-test('s3');  # //@
min-test('s4');  # /*@*/
min-test('s5');  # //
min-test('s6');  # /**/
min-test('s7');  # blocks of comments
min-test('s8');  # + + - -
min-test('s9');  # alphanum
min-test('s10'); # }])
min-test('s11'); # string and regexp literals
min-test('s12'); # other characters
min-test('s13'); # comment at start
min-test('s14'); # slash following square bracket
                 # ... is division not RegExp
min-test('s15'); # newline-at-end-of-file
                 # -> not there so don't add
min-test('s16'); # newline-at-end-of-file
                 # -> it's there so leave it alone
 
is js-minify(input => 'var x = 2;'), "var x=2;", 'string literal input and ouput';
is js-minify(input => "var x = 2;\n;;;alert('hi');\nvar x = 2;", strip_debug => 1), 'var x=2;var x=2;', 'script_debug option';
is js-minify(input => 'var x = 2;', copyright => "BSD"), '/* BSD */var x=2;', 'copyright option';
is js-minify(input => 'function test(s) { return /\d{1,2}/.test(s); }'), 'function test(s){return/\d{1,2}/.test(s);}', 'non-parened regex1 ';
is js-minify(input => 'function(s) { return /\d{1,2}[\/-]\d{1,2}[\/-]\d{2,4}/.test(s); }'), 'function(s){return/\d{1,2}[\/-]\d{1,2}[\/-]\d{2,4}/.test(s);}', 'non-parened regex2 ';
