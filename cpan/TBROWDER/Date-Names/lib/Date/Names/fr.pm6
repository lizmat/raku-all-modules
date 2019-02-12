unit module Date::Names::fr;

constant $mon = %(
    # French
    1, 'janvier',    2, 'février',  3, 'mars',      4, 'avril',
    5, 'mai',        6, 'juin',     7, 'juillet',   8, 'août',
    9, 'septembre', 10, 'octobre', 11, 'novembre', 12, 'décembre'
);

constant $dow = %(
    # French
    1, 'lundi',    2, 'mardi',  3, 'mercredi', 4, 'jeudi',
    5, 'vendredi', 6, 'samedi', 7, 'dimanche'
);

# three-letter abbreviations
constant $mon3 = %(
    # French
    1, '',  2, '',  3, '',  4, '',
    5, '',  6, '',  7, '',  8, '',
    9, '', 10, '', 11, '', 12, ''
);

# two-letter abbreviations
constant $mon2 = %(
    # French
    1, 'JR',  2, 'FR',  3, 'MS',  4, 'AL',
    5, 'MI',  6, 'JN',  7, 'JT',  8, 'AT',
    9, 'SE', 10, 'OE', 11, 'NE', 12, 'DE'
);

# two-letter abbreviations
constant $dow2 = %(
    # French
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);

constant $dow3 = %(
    # French
    1, 'lun', 2, 'mar', 3, 'mer', 4,  'jeu',
    5, 'ver', 6, 'sam', 7, 'dim'
);

# some languages don't have a complete set of two- or three-letter
# abbreviations so we use another hash
constant $mona = %(
    # French (abbreviations "courante")
    1, 'janv',  2, 'févr',  3, 'mars',   4, 'avr',
    5, 'mai',   6, 'juin',  7, 'juill',  8, 'août',
    9, 'sept', 10, 'oct',  11, 'nov',   12, 'déc'
);

constant $dowa = %(
    # French (abbreviations "courante")
    1, 'lundi', 2, 'mardi', 3, 'mercr', 4, 'jeudi',
    5, 'vendr', 6, 'sam',   7, 'dim'
);
