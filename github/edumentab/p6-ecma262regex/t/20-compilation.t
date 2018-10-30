use v6;
use ECMA262Regex;
use Test;

# `c` for `compile`
sub c($str) {
    ECMA262Regex::Parser.parse($str, actions => ECMA262Regex::ToPerl6Regex).made.Str;
}

is c('...'), '...', 'Any character';
is c('a'), 'a', 'The character a';
is c('ab'), 'ab', 'The string ab';
is c('a|b'), 'a || b', 'a or b';
is c('a*'), 'a*', '0 or more a\'s';
is c('\n'), '\n', '\ escapes a special character';

is c('a+'), 'a+', '1 or more';
is c('a?'), 'a?', '0 or 1';
is c('a{2}'), 'a ** 2', 'Exactly 2';
is c('a{2,5}'), 'a ** 2..5', 'Between 2 and 5';
is c('a{2,}'), 'a ** 2..* ', '2 or more';

is c('([ab]+)'), '(<[ab]>+)', 'Capturing group';
# todo '`(?` syntax is NYI in grammar', 1;
# is c('(?[ab]+)'), '<?before <[ab]>+>', 'Non-capturing group';
is c('(ha)\1'), '(ha)$0', 'Match the 1th captured group';

is c('[ab-d]'), '<[ab..d]>', 'One character of: a, b, c, d';
is c('[^ab-d]'), '<-[ab..d]>', 'One character except: a, b, c, d';
is c('[\b]'), '<[<|w>]>', 'Backspace character';
is c('\d'), '\d', 'One digit';
is c('\D'), '\D', 'One non-digit';
is c('\s'), '\s', 'One whitespace';
is c('\S'), '\S', 'One non-whitespace';
is c('\w'), '\w', 'One word character';
is c('\W'), '\W', 'One non-word character';

is c('^\b\B$'), '^<|w><!|w>$', 'Start of string, end of string, word boundary';
is c('^(?!0)\d+$'), '^<!before 0>\d+$', '?! compiles correctly';
is c('[A-Fa-f]+'), '<[A..Fa..f]>+', 'Class ranges are compiled correctly';
is c('[-]{2}'), '<[-]> ** 2', 'Dash class range';

is c('\n'), '\n';
is c('\r'), '\r';
todo 'NULL character is NYI', 1;
is c('\0'), '\0';
is c('\x50'), '\x50';
is c('\u0050'), '\x0050';
is c('\cY'), '"\c[END OF MEDIUM]"';


is c('^\d+$'), '^\d+$';
is c('\cA') , '"\c[START OF HEADING]"';

done-testing;
