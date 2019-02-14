unit module Date::Names::es;

#********
# <name of your language in its native script>
# Spanish
#********

# Note all possible hashes and keys should exist in the file (see
# Table 2 in the README for the correct names). They may have missing
# values, but there should be eight (8) total hashes:

# Names of sets with all non-empty values for this language:
our $sets = set <mon dow mon3 dow3 mon2 dow2 mona dowa>;

#=== FULL NAMES ======================================================
# 1
constant $mon = %(
    1, 'enero',       2, 'febrero',  3, 'marzo',      4, 'abril',
    5, 'mayo',        6, 'junio',    7, 'julio',      8, 'agosto',
    9, 'septiembre', 10, 'octubre', 11, 'noviembre', 12, 'diciembre'
);

# 2
constant $dow = %(
    1, 'lunes',   2, 'martes', 3, 'miércoles', 4, 'jueves',
    5, 'viernes', 6, 'sábado', 7, 'domingo'
);

#=== THREE-LETTER ABBREVIATIONS ======================================
# 3
constant $mon3 = %(
    1, 'ene',  2, 'feb',  3, 'mar',  4, 'abr',
    5, 'may',  6, 'jun',  7, 'jul',  8, 'ago',
    9, 'sep', 10, 'oct', 11, 'nov', 12, 'dic'
);

# 4
constant $dow3 = %(
    1, 'lun', 2, 'mar', 3, 'mié', 4, 'jue',
    5, 'vie', 6, 'sáb', 7, 'dom'
);

#=== TWO-LETTER ABBREVIATIONS ========================================
# 5
constant $mon2 = %(
    1, 'en',  2, 'fb',  3, 'mr',  4, 'ab',
    5, 'my',  6, 'jn',  7, 'jl',  8, 'ag',
    9, 'sp', 10, 'oc', 11, 'nv', 12, 'dc'
);

# 6
constant $dow2 = %(
    1, 'lu', 2, 'ma', 3, 'mi', 4, 'ju',
    5, 'vi', 6, 'sá', 7, 'do'
);

#=== MIXED-LENGTH ABBREVIATIONS ======================================
# 7
constant $mona = %(
    1, 'en.',    2, 'febr.',  3, 'mzo.',   4, 'abr.',
    5, 'my.',    6, 'jun.',   7, 'jul.',   8, 'ag.',
    9, 'sept.', 10, 'oct.',  11, 'nov.',  12, 'dic.'
);

# 8
constant $dowa = %(
    1, 'lun.',  2, 'mart.',  3, 'miér.', 4, 'juev.',
    5, 'vier.', 6, 'sáb.',   7, 'dom.'
);
