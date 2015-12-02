use v6;
use Test;
use JavaScript::SpiderMonkey;


ok js-eval(q:to/JS/) ~~ JavaScript::SpiderMonkey::Value::Object, 'evaling an object';
    car = {
        seats  : "leather",
        plates : true,
        doors  : [1, 2.3],
        "ℕℤℚℝ" : "林花謝了春紅",
    };
    JS

my $car = js-eval('car');
ok $car ~~ JavaScript::SpiderMonkey::Value::Object, 'referencing evaled object';


is-deeply $car<seats>,  'leather', 'referencing string property';
is-deeply $car<plates>,  True,     'referencing boolean property';


given $car<doors>
{
    ok $_ ~~ JavaScript::SpiderMonkey::Value::Object, 'referencing array property';

    is-deeply $_[0], 1.0e0, 'referencing number in array';
    is-deeply $_[1], 2.3e0, 'another number in array';
    nok defined($_[2]),     'referencing nonexistent array element';
}


is-deeply $car<ℕℤℚℝ>, '林花謝了春紅', 'unicode property and string';


nok defined($car<nonexistent>), 'referencing nonexistent object key';
nok defined($car[0]),           'referencing array element on non-array';


done-testing
