unit module Date::Names::ru;

#********
# <name of your language in its native script>
# Russian
#********

# Note all possible hashes and keys should exist in the file (see
# Table 2 in the README for the correct names). They may have missing
# values, but there should be eight (8) total hashes:

# Names of sets with all non-empty values for this language:
our $sets = set <mon dow mon3 dow2>;

#=== FULL NAMES ======================================================
# 1
constant $mon = %(
    1, 'январь',    2, 'февраль',  3, 'март',    4, 'апрель',
    5, 'май',       6, 'июнь',     7, 'июль',    8, 'август',
    9, 'сентябрь', 10, 'октябрь', 11, 'ноябрь', 12, 'декабрь'
);

# 2
constant $dow = %(
    1, 'понедельник', 2, 'вторник', 3, 'среда',      4, 'четверг',
    5, 'пятница',     6, 'суббота', 7, 'воскресенье'
);

#=== THREE-LETTER ABBREVIATIONS ======================================
# 3
constant $mon3 = %(
    1, 'янв', 2, 'фев', 3, 'мар',  4, 'апр',  5, 'май',  6, 'июн',
    7, 'июл', 8, 'авг', 9, 'сен', 10, 'окт', 11, 'ноя', 12, 'дек'
);

# 4
constant $dow3 = %(
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);

#=== TWO-LETTER ABBREVIATIONS ========================================
# 5
constant $mon2 = %(
    1, '', 2, '', 3, '',  4, '',  5, '',  6, '',
    7, '', 8, '', 9, '', 10, '', 11, '', 12, ''
);

# 6
constant $dow2 = %(
    1, 'Пн', 2, 'Вт', 3, 'Ср', 4, 'Чт',
    5, 'Пт', 6, 'Сб', 7, 'Вс'
);

#=== MIXED-LENGTH ABBREVIATIONS ======================================
# 7
constant $mona = %(
    1, '', 2, '', 3, '',  4, '',  5, '',  6, '',
    7, '', 8, '', 9, '', 10, '', 11, '', 12, ''
);

# 8
constant $dowa = %(
    1, '', 2, '', 3, '', 4, '',
    5, '', 6, '', 7, ''
);
