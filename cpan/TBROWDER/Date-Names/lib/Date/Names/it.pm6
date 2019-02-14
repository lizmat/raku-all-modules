unit module Date::Names::it;

#********
# <name of your language in its native script>
# Italian
#********

# Note all possible hashes and keys should exist in the file (see
# Table 2 in the README for the correct names). They may have missing
# values, but there should be eight (8) total hashes:

# Names of sets with all non-empty values for this language:
our $sets = set <mon dow>;

#=== FULL NAMES ======================================================
# 1
constant $mon = %(
    1, 'Gennaio',    2, 'Febbraio',  3, 'Marzo',     4, 'Aprile',
    5, 'Maggio',     6, 'Giugno',    7, 'Luglio',    8, 'Agosto',
    9, 'Settembre', 10, 'Ottobre',  11, 'Novembre', 12, 'Dicembre'
);

# 2
constant $dow = %(
    1, 'lunedì',  2, 'martedì', 3, 'mercoledì', 4, 'giovedì',
    5, 'venerdì', 6, 'sabato',  7, 'domenica'
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
