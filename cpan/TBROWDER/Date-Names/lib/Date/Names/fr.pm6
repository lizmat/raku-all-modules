unit module Date::Names::fr;

#********
# <name of your language in its native script>
# French
#********

# Note all possible hashes and keys should exist in the file (see
# Table 2 in the README for the correct names). They may have missing
# values, but there should be eight (8) total hashes:

# Names of sets with all non-empty values for this language:
our $sets = set <mon dow dow3 mon2 mona dowa>;

#=== FULL NAMES ======================================================
# 1
constant $mon = %(
    1, 'janvier',    2, 'février',  3, 'mars',      4, 'avril',
    5, 'mai',        6, 'juin',     7, 'juillet',   8, 'août',
    9, 'septembre', 10, 'octobre', 11, 'novembre', 12, 'décembre'
);

# 2
constant $dow = %(
    1, 'lundi',    2, 'mardi',  3, 'mercredi', 4, 'jeudi',
    5, 'vendredi', 6, 'samedi', 7, 'dimanche'
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
    1, 'lun', 2, 'mar', 3, 'mer', 4,  'jeu',
    5, 'ver', 6, 'sam', 7, 'dim'
);

#=== TWO-LETTER ABBREVIATIONS ========================================
# 5
constant $mon2 = %(
    1, 'JR',  2, 'FR',  3, 'MS',  4, 'AL',
    5, 'MI',  6, 'JN',  7, 'JT',  8, 'AT',
    9, 'SE', 10, 'OE', 11, 'NE', 12, 'DE'
);

# 6
constant $dow2 = %(
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);

#=== MIXED-LENGTH ABBREVIATIONS ======================================
# 7
constant $mona = %(
    # abbreviations "courante"
    1, 'janv',  2, 'févr',  3, 'mars',   4, 'avr',
    5, 'mai',   6, 'juin',  7, 'juill',  8, 'août',
    9, 'sept', 10, 'oct',  11, 'nov',   12, 'déc'
);

# 8
constant $dowa = %(
    # abbreviations "courante"
    1, 'lundi', 2, 'mardi', 3, 'mercr', 4, 'jeudi',
    5, 'vendr', 6, 'sam',   7, 'dim'
);
