use v6;

use Test;
use Form;

plan 21;

ok(form('a') eq "a\n", "Literal");
ok(form('{<<}', 'a') eq "a   \n", "Single left-line field");
ok(form('{<<}a', 'a') eq "a   a\n", "Single left-line field with literal after");
ok(form('{>>}a', 'a') eq "   aa\n", "Single right-line field with literal after");
ok(form('{>>><<}{<<<}', 'a', 'b') eq "   a   b    \n", "Single centred-line field with single left-line field after");
ok(form('{<<}', 'a', '{>>}', 'b') eq "a   \n   b\n", "Two fields");
ok(form(
    '+----+',
    '|{<<}|', 'aa',
    '+----+'
) eq "+----+\n|aa  |\n+----+\n", "Two literals, one field");
dies_ok(-> { form('{<<}{>>}', 'a') }, "Insufficient arguments");
ok(form('{<<<<<}', "The quick brown fox jumps over the lazy dog") eq "The    \n", "Line field overflow");
# TODO: reformat these as here-documents for neatness - when Rakudo supports them
ok(form('{[[[[[}', "The quick brown fox jumps over the lazy dog") eq "The    \nquick  \nbrown  \nfox    \njumps  \nover   \nthe    \nlazy   \ndog    \n", "Block field overflow");
ok(
    form(
        '{[[[[[[[[} {]]]]]]]]}',
        "The quick brown fox", "jumps over the lazy dog"
    )
    eq
    "The quick  jumps over\nbrown fox    the lazy\n                  dog\n",
    "Multiple block overflow"
);
ok(form('{""}', "Boo\nYah") eq "Boo \nYah \n", "Literal block field");

dies_ok({form('{<<<<}')}, 'Too few arguments');

# time for some numbers

ok(form('{>>.<}', 456.78) eq "456.78\n", "Simple numeric field");
ok(form('{>>.<}', 56.7) eq " 56.7 \n", "Non-full simple numeric field");
ok(form('{>>.<}', 4567.89) eq "567.89\n", "Left-side overflow numeric field");
ok(form('{>>.<}', 56.789) eq " 56.78\n", "Right-side overflow numeric field");

# Mixed numbers and text
ok(form(
		'{[[[[[[} {>.<<<}',
		"Six short people went down to the sea", 6.78
	)
	eq
	"Six       6.78  \nshort           \npeople          \nwent            \ndown to         \nthe sea         \n",
	"Block field with number field next to it"
);

# Multiple numbers
my @nums = (4.5, 5.6, 6.78, 9.101);
ok(
	form(
		'{>>.<<}', [@nums]
	)
	eq
	"  4.5  \n  5.6  \n  6.78 \n  9.101\n",
	"Array of numbers"
); 

# Multiple strings
my @strings = <one two three four>;
ok(
	form(
		'{>>>>>>}',
		[@strings]
	)
	eq
	"     one\n     two\n   three\n    four\n",
	"Array of strings"
);

# Both!

ok(
	form(
		'{>>>>>>}|{>.<<}',
		[@strings], [@nums]
	)
	eq
	"     one| 4.5  \n     two| 5.6  \n   three| 6.78 \n    four| 9.101\n",
	"Array of strings and array of numbers"
);

# vim: ft=perl6 sw=4 ts=4 noexpandtab
