use v6;
use Test;
plan 6;
use Text::Abbrev;

pass "Loaded Text::Abbrev";

is_deeply(
    abbrev(<ab bc>),
    (a => 'ab', ab => 'ab', b => 'bc', bc => 'bc').hash,
    'Basic test',
);
is_deeply(
    abbrev(<ins img>),
    (in => 'ins', ins => 'ins', im => 'img', img => 'img').hash,
    'Shortcuts shared by two or more options should be removed' ,
);
is_deeply(
    abbrev(<ab abc abcd>),
    (ab => 'ab', abc => 'abc', abcd => 'abcd').hash,
    "Values on list shouldn't be removed",
);
is_deeply(
    abbrev([1, 2], [1, 3]),
    ('1 2' => [1, 2], '1 3' => [1, 3]).hash,
    'Non stringy arguments should be stringified.',
);
is_deeply(
    abbrev,
    ().hash,
    'Empty list should return empty list',
);
