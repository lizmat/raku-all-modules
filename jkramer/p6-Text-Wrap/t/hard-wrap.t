
use Test;

use lib 'lib';

use Text::Wrap;

plan 2;

is(wrap-text('abcde', :width(1), :hard-wrap), "a\nb\nc\nd\ne", 'hard wrap works');

is(wrap-text('abcde', :width(1), :!hard-wrap), "abcde", 'soft wrap works');

done-testing;
