unit module Date::Names::it;

# note all possible hashes and keys exist but they may have missing values
constant $mon = %(
    # Italian
    1, 'Gennaio',    2, 'Febbraio',  3, 'Marzo',     4, 'Aprile',
    5, 'Maggio',     6, 'Giugno',    7, 'Luglio',    8, 'Agosto',
    9, 'Settembre', 10, 'Ottobre',  11, 'Novembre', 12, 'Dicembre'
);

constant $dow = %(
    # Italian
    1, 'lunedì',  2, 'martedì', 3, 'mercoledì', 4, 'giovedì',
    5, 'venerdì', 6, 'sabato',  7, 'domenica'
);

# three-letter abbreviations
constant $mon3 = %(
    # Italian
    1, '',  2, '',  3, '',  4, '',
    5, '',  6, '',  7, '',  8, '',
    9, '', 10, '', 11, '', 12, ''
);

# two-letter abbreviations
constant $dow2 = %(
    # Italian
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);

constant $dow3 = %(
    # Italian
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);
