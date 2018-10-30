use v6;
use Test;
plan 16;

use CLDR::List;

my $list = CLDR::List.new;

is $list.format(),           '',               'root: 0 elements';
is $list.format(1),          '1',              'root: 1 Num element';
is $list.format(1, 2),       '1, 2',           'root: 2 Num elements';
is $list.format(1..3),       '1, 2, 3',        'root: 3 Num elements';
is $list.format('A'),        'A',              'root: 1 Str element';
is $list.format(<A B>),      'A, B',           'root: 2 Str elements';
is $list.format('A'..'C'),   'A, B, C',        'root: 3 Str elements';
is $list.format('A'..'D'),   'A, B, C, D',     'root: 4 Str elements';

$list.locale = 'en';
is $list.format('A'),        'A',              'en: 1 element';
is $list.format(<A B>),      'A and B',        'en: 2 elements';
is $list.format('A'..'C'),   'A, B, and C',    'en: 3 elements';
is $list.format('A'..'D'),   'A, B, C, and D', 'en: 4 elements';

$list.locale = 'en-GB';
is $list.format('A'..'C'),   'A, B and C',     'en-GB: 3 elements';

$list.locale = 'ru';
is $list.format(<А Б В>),    'А, Б и В',       'ru: 3 elements';

$list.locale = 'zh-Hant';
is $list.format(<一 丁 丈>), '一、丁和丈',     'zh-Hant: 3 elements';

$list.locale = 'ar';
is $list.format(<ﺍ ﺏ ﺕ>),    'ﺍ، ﺏ، و ﺕ',      'ar: 3 elements';
