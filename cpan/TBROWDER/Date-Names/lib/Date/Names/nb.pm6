unit module Date::Names::nb;

#**********
# Bokmål
# Norwegian
#**********

# Note all possible hashes and keys should exist in the file (see
# Table 2 in the README for the correct names). They may have missing
# values, but there should be eight (8) total hashes:

# Names of sets with all non-empty values for this language:
our $sets = set <mon dow>;

#=== FULL NAMES ======================================================
# 1
constant $mon = %(
    1, 'januar',      2, 'februar',   3, 'mars',      4, 'april',
    5, 'mai',         6, 'juni',      7, 'juli',      8, 'august',
    9, 'september',  10, 'oktober',  11, 'november', 12, 'desember',
);

constant $dow = %(
    1, 'mandag', 2, 'tirsdag', 3, 'onsdag', 4, 'torsdag',
    5, 'fredag', 6, 'lørdag',  7, 'søndag',
);

#=== THREE-LETTER ABBREVIATIONS ======================================
# 3
constant $mon3 = %(
    1, '',  2, '',  3, '',  4, '',
    5, '',  6, '',  7, '',  8, '',
    9, '', 10, '', 11, '', 12, ''
);

# 4
constant $dow3 = %(
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);


#=== TWO-LETTER ABBREVIATIONS ========================================
# 5
constant $mon2  = %(
    1, '',  2, '',  3, '',  4, '',
    5, '',  6, '',  7, '',  8, '',
    9, '', 10, '', 11, '', 12, ''
);

# 6
constant $dow2 = %(
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);

#=== MIXED-LENGTH ABBREVIATIONS ======================================
# 7
constant $mona  = %(
    1, '',  2, '',  3, '',  4, '',
    5, '',  6, '',  7, '',  8, '',
    9, '', 10, '', 11, '', 12, ''
);

# 8
constant $dowa  = %(
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);
