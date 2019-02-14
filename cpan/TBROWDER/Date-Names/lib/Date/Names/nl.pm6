unit module Date::Names::nl;

#********
# <name of your language in its native script>
# Dutch
#********

# Note all possible hashes and keys should exist in the file (see
# Table 2 in the README for the correct names). They may have missing
# values, but there should be eight (8) total hashes:

# Names of sets with all non-empty values for this language:
our $sets = set <mon dow mon3 dow3 dow2>;

# note all possible hashes and keys exist but they may have missing values
constant $mon = %(
    # Dutch
    1, 'januari',    2, 'februari',  3, 'maart',     4, 'april',
    5, 'mei',        6, 'juni',      7, 'juli',      8, 'augustus',
    9, 'september', 10, 'oktober',  11, 'november', 12, 'december'
);

constant $dow = %(
    # Dutch
    1, 'maandag', 2, 'dinsdag',  3, 'woensdag', 4, 'donderdag',
    5, 'vrijdag', 6, 'zaterdag', 7, 'zondag'
);

# three-letter abbreviations
constant $mon3 = %(
    1, 'jan',   2, 'feb',  3, 'maa',   4, 'apr',
    5, 'mei',   6, 'jun',  7, 'jul',   8, 'aug',
    9, 'sep',  10, 'okt', 11, 'nov',  12, 'dec'
);

constant $dow3 = %(
    1, 'maa', 2, 'din', 3, 'woe', 4, 'don',
    5, 'vri', 6, 'zat', 7, 'zon'
);

# two-letter abbreviations
constant $mon2  = %(
    1, '',  2, '',  3, '',  4, '',
    5, '',  6, '',  7, '',  8, '',
    9, '', 10, '', 11, '', 12, ''
);

constant $dow2 = %(
    # Dutch
    1, 'ma',  2, 'di',  3, 'wo', 4, 'do',
    5, 'vr',  6, 'za',  7, 'zo'
);

# mixed
constant $mona  = %(
    1, '',  2, '',  3, '',  4, '',
    5, '',  6, '',  7, '',  8, '',
    9, '', 10, '', 11, '', 12, ''
);

constant $dowa  = %(
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);
