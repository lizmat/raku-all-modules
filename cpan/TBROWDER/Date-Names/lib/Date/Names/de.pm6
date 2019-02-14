unit module Date::Names::de;

#********
# <name of your language in its native script>
# German
#********

# Note all possible hashes and keys should exist in the file (see
# Table 2 in the README for the correct names). They may have missing
# values, but there should be eight (8) total hashes:

# Names of sets with all non-empty values for this language:
our $sets = set <mon dow mon3 dow3 dow2>;

#=== FULL NAMES ======================================================
# 1
constant $mon = %(
    1, 'Januar',     2, 'Februar',   3, 'März',      4, 'April',
    5, 'Mai',        6, 'Juni',      7, 'Juli',      8, 'August',
    9, 'September', 10, 'Oktober',  11, 'November', 12, 'Dezember'
);

# 2
constant $dow  = %(
    1, 'Montag',  2, 'Dienstag', 3, 'Mittwoch', 4,  'Donnerstag',
    5, 'Freitag', 6, 'Samstag',  7, 'Sonntag'
);

#=== THREE-LETTER ABBREVIATIONS ======================================
# 3
constant $mon3  = %(
    1, 'Jan',  2, 'Feb',  3, 'Mär',  4, 'Apr',
    5, 'Mai',  6, 'Jun',  7, 'Jul',  8, 'Aug',
    9, 'Sep', 10, 'Okt', 11, 'Nov', 12, 'Dez'
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
constant $dow2  = %(
    1, 'Mo', 2, 'Di', 3, 'Mi', 4, 'Do',
    5, 'Fr', 6, 'Sa', 7, 'So'
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
