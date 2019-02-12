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

# a list of the language two-letter codes currently considered
# in this module
constant @lang is export = 'de', 'en', 'es', 'fr', 'it', 'nb', 'nl', 'ru';

use Date::Names::de;
use Date::Names::en;
use Date::Names::es;
use Date::Names::fr;
use Date::Names::it;
use Date::Names::nb;
use Date::Names::nl;
use Date::Names::ru;

# the class (beta)
enum Case <tc uc lc keep-c>;
enum Period <yes no keep-p>;
class Date::Names {
    has $.lang     is required;
    has $.day-hash is required; # name of hash to use
    has $.mon-hash is required; # name of hash to use

    has %.d;
    has %.m;

    has Period $.period = keep-p; # add, remove, or keep a period to end abbreviations
                                  # (True or False; default -1 means use the
                                  # native value as is)
    has UInt $.trunc    = 0;      # truncate to N chars if N > 0
    has Case $.case     = keep-c; # use native case (or choose: tc, lc, uc)
    has $.pad           = False;  # used with trunc to fill short values with
                                  # spaces on the right

    submethod TWEAK() {
        # this sets the class var to the desired
        # dow and mon hashes (lang and value width)
        %!d = $::("Date::Names::{$!lang}::{$!day-hash}");
        %!m = $::("Date::Names::{$!lang}::{$!mon-hash}");
    }

    method !handle-val-attrs($val, :$is-abbrev!) {
        # check for any changes that are to be made
        my $has-period = 0;
        my $nchars = $val.chars; # includes an ending period
        if $val ~~ /^(\s+) '.'$/ {
            die "FATAL: found ending period in val $val (not an abbreviation)"
                if !$is-abbrev;

            # remove the period and return it later if required
            $val = ~$0;
            $has-period = 1;
        }
        elsif $val ~~ /'.'/ {
            die "FATAL: found INTERIOR period in val $val";
        }

        if $.trunc && $val.chars > $.trunc {
            $val .= substr(0, self.trunc);
        }
        elsif $.trunc && $.pad && $val.chars < $.trunc {
            $val .= substr(0, $.trunc);
        }

        if $.case !~~ /keep/ {
            # more checks needed
        }

        if $.trunc && $val.chars > self.trunc {
            $val .= substr(0, $.trunc);
        }
        elsif $.trunc && $.pad && $val.chars < $.truncx {
            $val .= substr(0, $.trunc);
        }
        if $.case !~~ /keep/ {
            # more checks needed
        }

        # treat the period carefully, it may or may not
        # have been removed by now

        return $val;

    }

    method dow(UInt $n where { $n > 0 && $n < 8 }) {
        my $val = %.d{$n};
        my $is-abbrev = $.day-hash eq 'dow' ?? False !! True;
        $val = self!handle-val-attrs($val, :$is-abbrev);
        return $val;
    }

    method mon(UInt $n where { $n > 0 && $n < 13 }) {
        my $val = %.m{$n};
        my $is-abbrev = $.mon-hash eq 'mon' ?? False !! True;
        $val = self!handle-val-attrs($val, :$is-abbrev);
        return $val;
    }
}

constant %mon = %(
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

    # Dutch
    nl => %(
        1, 'januari',    2, 'februari', 3, 'maart',     4, 'april',
        5, 'mei',        6, 'juni',     7, 'juli',      8, 'augustus',
        9, 'september', 10, 'oktober', 11, 'november', 12, 'december'
    ),
);

constant %dow  = %(
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
        1, 'lundi',    2, 'mardi',  3, 'mercredi', 4, 'jeudi',
        5, 'vendredi', 6, 'samedi', 7, 'dimanche'
    ),

    # Italian
    it => %(
        1, 'lunedì',  2, 'martedì', 3, 'mercoledì', 4, 'giovedì',
        5, 'venerdì', 6, 'sabato',  7, 'domenica'
    ),

    # Dutch
    nl => %(
        1, 'maandag', 2, 'dinsdag',  3, 'woensdag', 4, 'donderdag',
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
constant %mon3  = %(
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
        1, 'Jan',  2, 'Feb',  3, 'Mär',  4, 'Apr',
        5, 'Mai',  6, 'Jun',  7, 'Jul',  8, 'Aug',
        9, 'Sep', 10, 'Okt', 11, 'Nov', 12, 'Dez'
    ),

    # Spanish
    es => %(
        1, 'ene',  2, 'feb',  3, 'mar',  4, 'abr',
        5, 'may',  6, 'jun',  7, 'jul',  8, 'ago',
        9, 'sep', 10, 'oct', 11, 'nov', 12, 'dic'
    ),

    # French
    fr => %(
        1, '',  2, '',  3, '',  4, '',
        5, '',  6, '',  7, '',  8, '',
        9, '', 10, '', 11, '', 12, ''
    ),

    # Italian
    it => %(
        1, '',  2, '',  3, '',  4, '',
        5, '',  6, '',  7, '',  8, '',
        9, '', 10, '', 11, '', 12, ''
    ),

    # Dutch
    nl => %(
        1, 'jan',   2, 'feb',  3, 'maa',   4, 'apr',
        5, 'mei',   6, 'jun',  7, 'jul',   8, 'aug',
        9, 'sep',  10, 'okt', 11, 'nov',  12, 'dec'
    ),

    # Norwegian (Bokmål)
    nb => %(
        1, '',  2, '',  3, '',  4, '',
        5, '',  6, '',  7, '',  8, '',
        9, '', 10, '', 11, '', 12, ''
    ),

    # Russian
    ru => %(
        1, 'янв', 2, 'фев', 3, 'мар',  4, 'апр',  5, 'май',  6, 'июн',
        7, 'июл', 8, 'авг', 9, 'сен', 10, 'окт', 11, 'ноя', 12, 'дек'

    ),
);

# two-letter abbreviations
constant %mon2  = %(
    # French
    fr => %(
        1, 'JR',  2, 'FR',  3, 'MS',  4, 'AL',
        5, 'MI',  6, 'JN',  7, 'JT',  8, 'AT',
        9, 'SE', 10, 'OE', 11, 'NE', 12, 'DE'
    ),
);

# two-letter abbreviations
constant %dow2  = %(
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
        1, 'lu', 2, 'ma', 3, 'mi', 4, 'ju',
        5, 'vi', 6, 'sá', 7, 'do'
    ),

    # French
    fr => %(
        1, '', 2, '', 3, '', 4, '',
        5, '', 6, '', 7, ''
    ),

    # Italian
    it => %(
        1, '', 2, '', 3, '', 4, '',
        5, '', 6, '', 7, ''
    ),

    # Dutch
    nl => %(
        1, 'ma',  2, 'di',  3, 'wo', 4, 'do',
        5, 'vr',  6, 'za',  7, 'zo'
    ),


    # Norwegian (Bokmål)
    nb => %(
        1, '', 2, '', 3, '', 4, '',
        5, '', 6, '', 7, ''
    ),

    # Russian
    ru => %(
        1, 'Пн', 2, 'Вт', 3, 'Ср', 4, 'Чт',
        5, 'Пт', 6, 'Сб', 7, 'Вс'

    ),
);

constant %dow3  = %(
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
        1, 'lun',  2, 'mar',  3, 'mié',  4, 'jue',
        5, 'vie',  6, 'sáb',  7, 'dom'
    ),

    # French
    fr => %(
        1, 'lun', 2, 'mar', 3, 'mer', 4,  'jeu',
        5, 'ver', 6, 'sam', 7, 'dim'
    ),

    # Italian
    it => %(
        1, '', 2, '', 3, '', 4, '',
        5, '', 6, '', 7, ''
    ),

    # Dutch
    nl => %(
        1, 'maa', 2, 'din', 3, 'woe', 4, 'don',
        5, 'vri', 6, 'zat', 7, 'zon'
    ),

    # Norwegian (Bokmål)
    nb => %(
        1, '', 2, '', 3, '', 4, '',
        5, '', 6, '', 7, ''
    ),

    # Russian
    ru => %(
        1, '', 2, '', 3, '', 4, '',
        5, '', 6, '', 7, ''
    ),
);

# some languages don't have a complete set of two- or three-letter
# abbreviations so we use another hash
constant %mona  = %(
    # French (abbreviations "courante")
    fr => %(
        1, 'janv',  2, 'févr',  3, 'mars',   4, 'avr',
        5, 'mai',   6, 'juin',  7, 'juill',  8, 'août',
        9, 'sept', 10, 'oct',  11, 'nov',   12, 'déc'
    ),
);

constant %dowa  = %(
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
