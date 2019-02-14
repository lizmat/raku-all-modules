# CHANGE xx BELOW TO YOUR LANGUAGE CODE (LOWER-CASE)
# REMOVE THESE TWO LINES WHEN COMPLETE
unit module Date::Names::xx;

#********
# <name of your language in its native script>
# <English translation of new language>
#********

# Note all possible hashes and keys should exist in the file (see
# Table 2 in the README for the correct names). They may have missing
# values, but there should be eight (8) total hashes:

# Names of sets with all non-empty values for this language:
our $sets = set <mon dow>;

#=== FULL NAMES ======================================================
# 1
constant $mon = %(
    1, '',  2, '',  3, '',  4, '',
    5, '',  6, '',  7, '',  8, '',
    9, '', 10, '', 11, '', 12, ''
);

# 2
constant $dow = %(
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
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
constant $mon2 = %(
    1, '', 2, '', 3, '',  4, '',  5, '',  6, '',
    7, '', 8, '', 9, '', 10, '', 11, '', 12, ''
);

# 6
constant $dow2 = %(
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);

#=== MIXED-LENGTH ABBREVIATIONS ======================================
# 7
constant $mona = %(
    1, '', 2, '', 3, '',  4, '',  5, '',  6, '',
    7, '', 8, '', 9, '', 10, '', 11, '', 12, ''
);

# 8
constant $dowa = %(
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);
