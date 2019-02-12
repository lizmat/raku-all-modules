unit module Date::Names::nb;

constant $mon = %(
    # Norwegian (Bokmål)
    1, 'januar',      2, 'februar',   3, 'mars',      4, 'april',
    5, 'mai',         6, 'juni',      7, 'juli',      8, 'august',
    9, 'september',  10, 'oktober',  11, 'november', 12, 'desember',
);

constant $dow = %(
    # Norwegian (Bokmål)
    1, 'mandag', 2, 'tirsdag', 3, 'onsdag', 4, 'torsdag',
    5, 'fredag', 6, 'lørdag',  7, 'søndag',
);

# three-letter abbreviations
constant $mon3 = %(
    # Norwegian (Bokmål)
    1, '',  2, '',  3, '',  4, '',
    5, '',  6, '',  7, '',  8, '',
    9, '', 10, '', 11, '', 12, ''
);

# two-letter abbreviations
constant $dow2 = %(
    # Norwegian (Bokmål)
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);

constant $dow3 = %(
    # Norwegian (Bokmål)
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);
