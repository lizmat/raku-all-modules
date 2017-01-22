use v6;

use Test;
use Template::Anti :one-off;

my $str = '<h1>hello</h1>';
my &simple = anti-template :source($str), -> $at, :$h1 {
    is $at('h1', :one).content, 'hello', 'unchanged original';
    $at('h1', :one).content($h1);
};

my $output1 = simple(:h1<X>);
my $output2 = simple(:h1<Y>);

is $output1, '<h1>X</h1>', 'first output is X';
is $output2, '<h1>Y</h1>', 'second output is Y';

done-testing;
