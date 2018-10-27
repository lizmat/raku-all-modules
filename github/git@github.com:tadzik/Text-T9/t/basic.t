use Text::T9;
use Test;

my @words = <this is just a simple kiss test lips here how>;

is t9_find_words(5477, @words).join('|'), 'kiss|lips', 'basic case';

is t9_find_words(5296, ['jaźń'], { ź => 9, ń => 6 })[0], 'jaźń',
   'with optional keys';

done-testing;
