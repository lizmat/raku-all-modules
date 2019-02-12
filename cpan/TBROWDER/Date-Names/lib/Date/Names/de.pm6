unit module Date::Names::de;

constant $mon = %(
    # German
    1, 'Januar',     2, 'Februar',   3, 'März',      4, 'April',
    5, 'Mai',        6, 'Juni',      7, 'Juli',      8, 'August',
    9, 'September', 10, 'Oktober',  11, 'November', 12, 'Dezember'
);

constant $dow  = %(
    # German
    1, 'Montag',  2, 'Dienstag', 3, 'Mittwoch', 4,  'Donnerstag',
    5, 'Freitag', 6, 'Samstag',  7, 'Sonntag'
);

# three-letter abbreviations
constant $mon3  = %(
    # German
    1, 'Jan',  2, 'Feb',  3, 'Mär',  4, 'Apr',
    5, 'Mai',  6, 'Jun',  7, 'Jul',  8, 'Aug',
    9, 'Sep', 10, 'Okt', 11, 'Nov', 12, 'Dez'
);

# two-letter abbreviations
constant $dow2  = %(
    # German
    1, 'Mo', 2, 'Di', 3, 'Mi', 4, 'Do',
    5, 'Fr', 6, 'Sa', 7, 'So'
);

constant $dow3  = %(
    # German
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);
