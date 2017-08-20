use Test;
use Text::MiscUtils::Layout;


plan 80;


# text-width() -- XXXX: NEEDS TESTS


# text-wrap() -- 28 tests
is-deeply text-wrap( 0, ''), [''], 'text-wrap with empty string and zero width';
is-deeply text-wrap( 4, ''), [''], 'text-wrap with empty string and positive width';

is-deeply text-wrap( 0, '   '), [''], 'text-wrap with whitespace only and zero width';
is-deeply text-wrap( 2, '   '), [''], 'text-wrap with whitespace only and less width';
is-deeply text-wrap( 3, '   '), [''], 'text-wrap with whitespace only and equal width';
is-deeply text-wrap( 8, '   '), [''], 'text-wrap with whitespace only and greater width';

is-deeply text-wrap( 0, "\e[1m"), ["\e[1m"], 'text-wrap with one ANSI color command and zero width';
is-deeply text-wrap( 2, "\e[1m"), ["\e[1m"], 'text-wrap with one ANSI color command and small width';
is-deeply text-wrap(12, "\e[1m"), ["\e[1m"], 'text-wrap with one ANSI color command and large width';

is-deeply text-wrap( 0, "\e[1m   "), ["\e[1m"], 'text-wrap with one ANSI command, trailing whitespace, and zero width';
is-deeply text-wrap( 3, "\e[1m   "), ["\e[1m"], 'text-wrap with one ANSI command, trailing whitespace, and small width';
is-deeply text-wrap(15, "\e[1m   "), ["\e[1m"], 'text-wrap with one ANSI command, trailing whitespace, and large width';

is-deeply text-wrap( 0, "  \e[1m "), ["  \e[1m"], 'text-wrap with one ANSI command, surrounding whitespace, and zero width';
is-deeply text-wrap( 4, "  \e[1m "), ["  \e[1m"], 'text-wrap with one ANSI command, surrounding whitespace, and small width';
is-deeply text-wrap(20, "  \e[1m "), ["  \e[1m"], 'text-wrap with one ANSI command, surrounding whitespace, and large width';

is-deeply text-wrap( 0, "  \e[1m   \e[0m   "), ["  \e[1m", "  \e[0m"], 'text-wrap with two ANSI commands, surrounding whitespace, and zero width';
is-deeply text-wrap( 5, "  \e[1m   \e[0m   "), ["  \e[1m \e[0m"], 'text-wrap with two ANSI commands, surrounding whitespace, and small width';
is-deeply text-wrap(19, "  \e[1m   \e[0m   "), ["  \e[1m \e[0m"], 'text-wrap with two ANSI commands, surrounding whitespace, and large width';

is-deeply text-wrap( 0, "  \e[1mab   123\e[0m    \e[1m!#^*\e[0m     c\e[1mde\e[0mf   "),
    [                  "  \e[1mab", "  123\e[0m", "  \e[1m!#^*\e[0m", "  c\e[1mde\e[0mf"],
    'text-wrap with intermingled ANSI commands, whitespace, and text, and zero width';

is-deeply text-wrap( 7, "  \e[1mab   123\e[0m    \e[1m!#^*\e[0m     c\e[1mde\e[0mf   "),
    [                  "  \e[1mab", "  123\e[0m", "  \e[1m!#^*\e[0m", "  c\e[1mde\e[0mf"],
    'text-wrap with intermingled ANSI commands, whitespace, and text, and small width';

is-deeply text-wrap( 8, "  \e[1mab   123\e[0m    \e[1m!#^*\e[0m     c\e[1mde\e[0mf   "),
    [                  "  \e[1mab 123\e[0m", "  \e[1m!#^*\e[0m", "  c\e[1mde\e[0mf"],
    'text-wrap with intermingled ANSI commands, whitespace, and text, and medium width';

is-deeply text-wrap(12, "  \e[1mab   123\e[0m    \e[1m!#^*\e[0m     c\e[1mde\e[0mf   "),
    [                   "  \e[1mab 123\e[0m", "  \e[1m!#^*\e[0m c\e[1mde\e[0mf"],
    'text-wrap with intermingled ANSI commands, whitespace, and text, and large width';

is-deeply text-wrap(13, "  \e[1mab   123\e[0m    \e[1m!#^*\e[0m     c\e[1mde\e[0mf   "),
    [                   "  \e[1mab 123\e[0m \e[1m!#^*\e[0m", "  c\e[1mde\e[0mf"],
    'text-wrap with intermingled ANSI commands, whitespace, and text, and larger width';

is-deeply text-wrap( 0, " \t ab cd goldfish?\nfoo\n\nbar  \n  \n \t\tquux\tzazzle\n"),
    [" \t ab", " \t cd", " \t goldfish?", " \t foo", " \t bar", " \t quux", " \t zazzle"],
    'text-wrap with mixed indent, multiple lines, and zero width';

is-deeply text-wrap( 7, " \t ab cd goldfish?\nfoo\n\nbar  \n  \n \t\tquux\tzazzle\n"),
    [" \t ab", " \t cd", " \t goldfish?", " \t foo", " \t bar", " \t quux", " \t zazzle"],
    'text-wrap with mixed indent, multiple lines, and extra small width';

is-deeply text-wrap(10, " \t ab cd goldfish?\nfoo\n\nbar  \n  \n \t\tquux\tzazzle\n"),
    [" \t ab cd", " \t goldfish?", " \t foo bar", " \t quux", " \t zazzle"],
    'text-wrap with mixed indent, multiple lines, and small width';

is-deeply text-wrap(18, " \t ab cd goldfish?\nfoo\n\nbar  \n  \n \t\tquux\tzazzle\n"),
    [" \t ab cd goldfish?", " \t foo bar quux", " \t zazzle"],
    'text-wrap with mixed indent, multiple lines, and medium width';

is-deeply text-wrap(40, " \t ab cd goldfish?\nfoo\n\nbar  \n  \n \t\tquux\tzazzle\n"),
    [" \t ab cd goldfish? foo bar quux zazzle"],
    'text-wrap with mixed indent, multiple lines, and large width';

# XXXX: Whitespace contains \r


# text-columns() -- 24 tests
is text-columns( 0), '', 'text-columns with no blocks and zero width';
is text-columns(12), '', 'text-columns with no blocks and positive width';

is text-columns( 0, :sep<+>), '', 'text-columns with no blocks, custom sep, and zero width';
is text-columns(11, :sep<+>), '', 'text-columns with no blocks, custom sep, and positive width';

is text-columns( 0, ''), '', 'text-columns with one empty block and zero width';
is text-columns( 4, ''), '    ', 'text-columns with one empty block and positive width';

is text-columns( 0, '', :sep<+>), '', 'text-columns with one empty block, custom sep, and zero width';
is text-columns( 4, '', :sep<+>), '    ', 'text-columns with one empty block, custom sep, and positive width';

is text-columns( 0, '', ''), '  ', 'text-columns with two empty blocks and zero width';
is text-columns( 3, '', ''), '        ', 'text-columns with two empty blocks and positive width';

is text-columns( 0, '', '', :sep<+>), '+', 'text-columns with two empty blocks, custom sep, and zero width';
is text-columns( 3, '', '', :sep<+>), '   +   ', 'text-columns with two empty blocks, custom sep, and positive width';

is text-columns( 0, "12\n34\n", "abc\ndefg\nhi"), "12  abc\n34  defg\n  hi",
    'text-columns with ragged multi-line blocks and zero width';

is text-columns( 1, "12\n34\n", "abc\ndefg\nhi"), "12  abc\n34  defg\n   hi",
    'text-columns with ragged multi-line blocks and insufficient width';

is text-columns( 4, "12\n34\n", "abc\ndefg\nhi"), "12    abc \n34    defg\n      hi  ",
    'text-columns with ragged multi-line blocks and exactly enough width';

is text-columns( 5, "12\n34\n", "abc\ndefg\nhi"), "12     abc  \n34     defg \n       hi   ",
    'text-columns with ragged multi-line blocks and more than enough width';

is text-columns( 0, "12\n34\n", "abc\ndefg\nhi", :sep<|>), "12|abc\n34|defg\n|hi",
    'text-columns with ragged multi-line blocks, custom sep, and zero width';

is text-columns( 2, "12\n34\n", "abc\ndefg\nhi", :sep<|>), "12|abc\n34|defg\n  |hi",
    'text-columns with ragged multi-line blocks, custom sep, and insufficient width';

is text-columns( 4, "12\n34\n", "abc\ndefg\nhi", :sep<|>), "12  |abc \n34  |defg\n    |hi  ",
    'text-columns with ragged multi-line blocks, custom sep, and exactly enough width';

is text-columns( 5, "12\n34\n", "abc\ndefg\nhi", :sep<|>), "12   |abc  \n34   |defg \n     |hi   ",
    'text-columns with ragged multi-line blocks, custom sep, and more than enough width';

is text-columns( 0, "12\n34\n", "\e[1ma\e[0m b\ndefg\nhi"), "12  \e[1ma\e[0m\n34  b\n  defg\n  hi",
    'text-columns with ragged multi-line blocks, embedded ANSI color codes, and zero width';

is text-columns( 2, "12\n34\n", "\e[1ma\e[0m b\ndefg\nhi"), "12  \e[1ma\e[0m \n34  b \n    defg\n    hi",
    'text-columns with ragged multi-line blocks, embedded ANSI color codes, and not enough width';

is text-columns( 5, "12\n34\n", "\e[1ma\e[0m b\ndefg\nhi"), "12     \e[1ma\e[0m b  \n34     defg \n       hi   ",
    'text-columns with ragged multi-line blocks, embedded ANSI color codes, and more than enough width';

# XXXX: force-wrap on and off


# NOTE: THIS TEST CONTAINS INTENTIONAL TRAILING WHITESPACE!
is text-columns(10, :sep<+>,
                "12\n34\n",
                "a b\nde fg hi\njklmnopq",
                '',
                "  1 23 456 7890\n a bc def ghij klmno pqrstu\nThe quick brown fox jumped over the insufficiently motivated dog."),
 q:to/COMPLEX/.chomp, 'text-columns with ragged multi-line blocks, indents, wrapped lines, empty blocks, custom sep, and not quite enough width';  # :
12        +a b       +          +  1 23 456
34        +de fg hi  +          +  7890    
          +jklmnopq  +          + a bc def 
          +          +          + ghij     
          +          +          + klmno    
          +          +          + pqrstu   
          +          +          +The quick 
          +          +          +brown fox 
          +          +          +jumped    
          +          +          +over the  
          +          +          +insufficiently
          +          +          +motivated 
          +          +          +dog.      
COMPLEX


# evenly-spaced() -- 28 tests
is evenly-spaced(  0), '', 'evenly-spaced with no cells and zero width';
is evenly-spaced(  5), '', 'evenly-spaced with no cells and positive width';

is evenly-spaced(  0, ''), '', 'evenly-spaced with one empty cell and zero width';
is evenly-spaced( 12, ''), '', 'evenly-spaced with one empty cell and positive width';

is evenly-spaced(  0, '', '', ''), '', 'evenly-spaced with several empty cells and zero width';
is evenly-spaced(  4, '', '', ''), '', 'evenly-spaced with several empty cells and positive width';

is evenly-spaced(  0, '', 'b', ''), 'b', 'evenly-spaced with one non-empty cell and zero width';
is evenly-spaced(  6, '', '', 'c'), 'c', 'evenly-spaced with one non-empty cell and positive width';

is evenly-spaced(  0, 'a', '', 'b'), 'a b', 'evenly-spaced with two non-empty cells and zero width';
is evenly-spaced(  2, '', 'a', 'b'), 'a b', 'evenly-spaced with two non-empty cells and insufficient width';
is evenly-spaced(  3, 'a', '', 'b'), 'a b', 'evenly-spaced with two non-empty cells and just enough width';
is evenly-spaced(  4, 'a', 'b', ''), 'a  b', 'evenly-spaced with two non-empty cells and a little extra width';
is evenly-spaced(  5, '', 'a', 'b'), 'a   b', 'evenly-spaced with two non-empty cells and more extra width';
is evenly-spaced(  8, 'a', '', 'b'), 'a      b', 'evenly-spaced with two non-empty cells and lots of extra width';

is evenly-spaced(  0, 'a', 'b', 'c'), 'a b c', 'evenly-spaced with three non-empty cells and zero width';
is evenly-spaced(  2, 'a', 'b', 'c'), 'a b c', 'evenly-spaced with three non-empty cells and insufficient width';
is evenly-spaced(  5, 'a', 'b', 'c'), 'a b c', 'evenly-spaced with three non-empty cells and just enough width';
is evenly-spaced(  6, 'a', 'b', 'c'), 'a  b c', 'evenly-spaced with three non-empty cells and a little extra width';
is evenly-spaced(  7, 'a', 'b', 'c'), 'a  b  c', 'evenly-spaced with three non-empty cells and more extra width';
is evenly-spaced(  8, 'a', 'b', 'c'), 'a   b  c', 'evenly-spaced with three non-empty cells and even more extra width';
is evenly-spaced( 11, 'a', 'b', 'c'), 'a    b    c', 'evenly-spaced with three non-empty cells and lots of extra width';

is evenly-spaced( 12, '1', '22', '55555'), '1  22  55555', 'evenly-spaced with three different length cells 1-2-5';
is evenly-spaced( 12, '1', '55555', '22'), '1  55555  22', 'evenly-spaced with three different length cells 1-5-2';
is evenly-spaced( 12, '22', '1', '55555'), '22  1  55555', 'evenly-spaced with three different length cells 2-1-5';
is evenly-spaced( 12, '22', '55555', '1'), '22  55555  1', 'evenly-spaced with three different length cells 2-5-1';
is evenly-spaced( 12, '55555', '1', '22'), '55555  1  22', 'evenly-spaced with three different length cells 5-1-2';
is evenly-spaced( 12, '55555', '22', '1'), '55555  22  1', 'evenly-spaced with three different length cells 5-2-1';

is evenly-spaced( 11, "\e[1mabc\e[0m", '', '1234'), "\e[1mabc\e[0m    1234", 'evenly-spaced with an ANSI-colored cell and a plain cell';


done-testing;
