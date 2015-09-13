#!perl6

use v6;

use Test;
use Template::Anti;

my $at = Template::Anti.load("t/basic.html".IO);

{
    $at('body').text('<h1>Test</h1>');

    my $output = $at.render;
    like $output, rx{"&lt;h1&gt;Test&lt;/h1&gt;"}, '.text(HTML) was escaped';
}

{
    $at('body').html('<h1>Test</h1>');

    my $output = $at.render;
    like $output, rx{"<h1>Test</h1>"}, '.html(HTML) was not escaped';
}

done-testing;
