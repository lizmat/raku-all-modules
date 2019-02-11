unit module Date::Names;

# Default keys are month numbers with value in English.
#
# Other languages have keys of the ISO two-letter language code (but
# lower-case):
#
#   de - German
#   es - Spanish
#   fr - French
#   it - Italian
#   nb - Norwegian
#   nl - Dutch
#   ru - Russian

# From @luc, an authoritative link for French terms:
#   http://bdl.oqlf.gouv.qc.ca/bdl/gabarit_bdl.asp?id=3619

# a list of the language two-letter codes currently considered
# in this module
constant @lang is export = 'de', 'en', 'es', 'fr', 'it', 'nb', 'nl', 'ru';

constant %mon is export = %(
    # English is the default
    1, 'January',    2, 'February',  3, 'March',     4, 'April',
    5, 'May',        6, 'June',      7, 'July',      8, 'August',
    9, 'September', 10, 'October',  11, 'November', 12, 'December',

    # English as a lang key
    en => %(
        1, 'January',    2, 'February',  3, 'March',     4, 'April',
        5, 'May',        6, 'June',      7, 'July',      8, 'August',
        9, 'September', 10, 'October',  11, 'November', 12, 'December'
    ),

    # German
    de => %(
        1, 'Januar',     2, 'Februar',   3, 'März',      4, 'April',
        5, 'Mai',        6, 'Juni',      7, 'Juli',      8, 'August',
        9, 'September', 10, 'Oktober',  11, 'November', 12, 'Dezember'
    ),

    # Spanish
    es => %(
        1, 'enero',       2, 'febrero',  3, 'marzo',      4, 'abril',
        5, 'mayo',        6, 'junio',    7, 'julio',      8, 'agosto',
        9, 'septiembre', 10, 'octubre', 11, 'noviembre', 12, 'diciembre'
    ),

    # French
    fr => %(
        1, 'janvier',    2, 'février',  3, 'mars',      4, 'avril',
        5, 'mai',        6, 'juin',     7, 'juillet',   8, 'août',
        9, 'septembre', 10, 'octobre', 11, 'novembre', 12, 'décembre'
    ),

    # Italian
    it => %(
        1, 'Gennaio',    2, 'Febbraio',  3, 'Marzo',     4, 'Aprile',
        5, 'Maggio',     6, 'Giugno',    7, 'Luglio',    8, 'Agosto',
        9, 'Settembre', 10, 'Ottobre',  11, 'Novembre', 12, 'Dicembre'
    ),

    # Dutch
    nl => %(
        1, 'januari',    2, 'februari',  3, 'maart',     4, 'april',
        5, 'mei',        6, 'juni',      7, 'juli',      8, 'augustus',
        9, 'september', 10, 'oktober',  11, 'november', 12, 'december'
    ),

    # Norwegian (Bokmål)
    nb => %(
       1, 'januar',      2, 'februar',   3, 'mars',      4, 'april',
       5, 'mai',         6, 'juni',      7, 'juli',      8, 'august',
       9, 'september',  10, 'oktober',  11, 'november', 12, 'desember',
    ),

    # Russian
    ru => %(
        1, 'январь',    2, 'февраль',  3, 'март',    4, 'апрель',
        5, 'май',       6, 'июнь',     7, 'июль',    8, 'август',
        9, 'сентябрь', 10, 'октябрь', 11, 'ноябрь', 12, 'декабрь'
    ),
);

constant %dow is export = %(
    # English is the default
    1, 'Monday', 2, 'Tuesday',  3, 'Wednesday', 4, 'Thursday',
    5, 'Friday', 6, 'Saturday', 7, 'Sunday',

    # English as a lang key
    en => %(
        1, 'Monday', 2, 'Tuesday',  3, 'Wednesday', 4, 'Thursday',
        5, 'Friday', 6, 'Saturday', 7, 'Sunday'
    ),

    # German
    de => %(
        1, 'Montag',  2, 'Dienstag', 3, 'Mittwoch', 4,  'Donnerstag',
        5, 'Freitag', 6, 'Samstag',  7, 'Sonntag'
    ),

    # Spanish
    es => %(
        1, 'lunes',   2, 'martes', 3, 'miércoles', 4,  'jueves',
        5, 'viernes', 6, 'sábado', 7, 'domingo'
    ),

    # French
    fr => %(
        1, 'lundi',    2, 'mardi',  3, 'mercredi', 4,  'jeudi',
        5, 'vendredi', 6, 'samedi', 7, 'dimanche'
    ),

    # Italian
    it => %(
        1, 'lunedì',  2, 'martedì', 3, 'mercoledì', 4,  'giovedì',
        5, 'venerdì', 6, 'sabato',  7, 'domenica'
    ),

    # Dutch
    nl => %(
        1, 'maandag', 2, 'dinsdag',  3, 'woensdag', 4,  'donderdag',
        5, 'vrijdag', 6, 'zaterdag', 7, 'zondag'
    ),

    # Norwegian (Bokmål)
    nb => %(
        1, 'mandag', 2, 'tirsdag', 3, 'onsdag', 4, 'torsdag',
        5, 'fredag', 6, 'lørdag',  7, 'søndag',
    ),

    # Russian
    ru => %(
        1, 'понедельник', 2, 'вторник', 3, 'среда',      4, 'четверг',
        5, 'пятница',     6, 'суббота', 7, 'воскресенье'

    ),
);

# three-letter abbreviations
constant %mon3 is export = %(
    # English is the default
    1, 'Jan', 2, 'Feb', 3, 'Mar',  4, 'Apr',  5, 'May',  6, 'Jun',
    7, 'Jul', 8, 'Aug', 9, 'Sep', 10, 'Oct', 11, 'Nov', 12, 'Dec',

    # English as a lang key
    en => %(
        1, 'Jan', 2, 'Feb', 3, 'Mar',  4, 'Apr',  5, 'May',  6, 'Jun',
        7, 'Jul', 8, 'Aug', 9, 'Sep', 10, 'Oct', 11, 'Nov', 12, 'Dec'
    ),

    # German
    de => %(
        1, 'Jan',    2, 'Feb',  3, 'Mär',     4, 'Apr',
        5, 'Mai',    6, 'Jun',  7, 'Jul',     8, 'Aug',
        9, 'Sep',   10, 'Okt',  11, 'Nov',   12, 'Dez'
    ),

    # Spanish
    es => %(
        1, '',    2, '',  3, '',     4,  '',
        5, '',        6, '',      7, '',      8,  '',
        9, '', 10, '',  11, '', 12, ''
    ),

    # French
    fr => %(
        1, '',    2, '',  3, '',     4,  '',
        5, '',        6, '',      7, '',      8,  '',
        9, '', 10, '',  11, '', 12, ''
    ),

    # Italian
    it => %(
        1, '',    2, '',  3, '',     4,  '',
        5, '',        6, '',      7, '',      8,  '',
        9, '', 10, '',  11, '', 12, ''
    ),

    # Dutch
    nl => %(
        1, '',    2, '',  3, '',     4,  '',
        5, '',        6, '',      7, '',      8,  '',
        9, '', 10, '',  11, '', 12, ''
    ),

    # Norwegian (Bokmål)
    nb => %(
        1, '',    2, '',  3, '',     4,  '',
        5, '',        6, '',      7, '',      8,  '',
        9, '', 10, '',  11, '', 12, ''
    ),

    # Russian
    ru => %(
        1, 'янв', 2, 'фев', 3, 'мар',  4, 'апр',  5, 'май',  6, 'июн',
        7, 'июл', 8, 'авг', 9, 'сен', 10, 'окт', 11, 'ноя', 12, 'дек'

    ),
);

# two-letter abbreviations
constant %mon2 is export = %(
    # French
    fr => %(
        1, 'JR',  2, 'FR',  3, 'MS',  4, 'AL',
        5, 'MI',  6, 'JN',  7, 'JT',  8, 'AT',
        9, 'SE', 10, 'OE', 11, 'NE', 12, 'DE'
    ),
);

# two-letter abbreviations
constant %dow2 is export = %(
    # English is the default
    1, 'Mo', 2, 'Tu', 3, 'We', 4, 'Th',
    5, 'Fr', 6, 'Sa', 7, 'Su',

    # English as a lang key
    en => %(
        1, 'Mo', 2, 'Tu', 3, 'We', 4, 'Th',
        5, 'Fr', 6, 'Sa', 7, 'Su'
    ),

    # German
    de => %(
        1, 'Mo', 2, 'Di', 3, 'Mi', 4, 'Do',
        5, 'Fr', 6, 'Sa', 7, 'So'
    ),

    # Spanish
    es => %(
        1, '',    2, '',  3, '',     4,  '',
        5, '',        6, '',      7, ''
    ),

    # French
    fr => %(
        1, '',    2, '',  3, '',     4,  '',
        5, '',        6, '',      7, ''
    ),

    # Italian
    it => %(
        1, '',    2, '',  3, '',     4,  '',
        5, '',        6, '',      7, ''
    ),

    # Dutch
    nl => %(
        1, '',    2, '',  3, '',     4,  '',
        5, '',        6, '',      7, ''
    ),


    # Norwegian (Bokmål)
    nb => %(
        1, '',    2, '',  3, '',     4,  '',
        5, '',        6, '',      7, ''
    ),

    # Russian
    ru => %(
        1, 'Пн', 2, 'Вт', 3, 'Ср', 4, 'Чт',
        5, 'Пт', 6, 'Сб', 7, 'Вс'

    ),
);

constant %dow3 is export = %(
    1, 'Mon', 2, 'Tue', 3, 'Wed', 4, 'Thu',
    5, 'Fri', 6, 'Sat', 7, 'Sun',

    # English as a lang key
    en => %(
        1, 'Mon', 2, 'Tue', 3, 'Wed', 4, 'Thu',
        5, 'Fri', 6, 'Sat', 7, 'Sun'
    ),

    # German
    de => %(
        1, '', 2, '', 3, '', 4, '',
        5, '', 6, '', 7, ''
    ),

    # Spanish
    es => %(
        1, '',    2, '',  3, '',     4,  '',
        5, '',        6, '',      7, ''
    ),

    # French
    fr => %(
        1, 'lun', 2, 'mar', 3, 'mer', 4,  'jeu',
        5, 'ver', 6, 'sam', 7, 'dim'
    ),

    # Italian
    it => %(
        1, '',    2, '',  3, '',     4,  '',
        5, '',        6, '',      7, ''
    ),

    # Dutch
    nl => %(
        1, '',    2, '',  3, '',     4,  '',
        5, '',        6, '',      7, ''
    ),

    # Norwegian (Bokmål)
    nb => %(
        1, '',    2, '',  3, '',     4,  '',
        5, '',        6, '',      7, ''
    ),

    # Russian
    ru => %(
        1, '', 2, '', 3, '', 4, '',
        5, '', 6, '', 7, ''
    ),
);

# some languages don't have a complete set of two- or three-letter
# abbreviations so we use another hash
constant %mona is export = %(
    # Russian and French
    # French (abbreviations "courante")
    fr => %(
        1, 'janv',  2, 'févr',  3, 'mars',   4, 'avr',
        5, 'mai',   6, 'juin',  7, 'juill',  8, 'août',
        9, 'sept', 10, 'oct',  11, 'nov',   12, 'déc'
    ),
);

constant %dowa is export = %(
    # French (abbreviations "courante")
    fr => %(
        1, 'lundi', 2, 'mardi', 3, 'mercr', 4, 'jeudi',
        5, 'vendr', 6, 'sam',   7, 'dim'
    ),
    # Russian
    ru => %(
        1, 'пон', 2, 'втр', 3, 'Ср', 4, 'чтв',
        5, 'пт',  6, 'сбт', 7, 'Вс'
    ),
);
