#!/usr/bin/env perl6

use v6;

use Test;
use Template::Anti::Selector;
use XML;

my $xml = from-xml-file("t/selector.html");

my $sq = Template::Anti::Selector.new(:source($xml));

{
    my $all = $sq('*');
    is $all.elems, 14, 'selected *';
}

{
    my $li = $sq('li');
    is $li.elems, 3, 'selected li';
}

{
    my $one = $sq('#the-one');
    is $one.elems, 1, 'select #the-one';
}

{
    my $class-ish = $sq('[class]');
    is $class-ish.elems, 3, 'select [class]';
}

{
    my $en-ish = $sq('[hreflang|="en"]');
    is $en-ish.elems, 2, 'selected [hreflang|=en]';
}

{
    my $man-ish = $sq('[href*="man"]');
    is $man-ish.elems, 3, 'select [href*=man]';
}

{
    my $man-ish = $sq('[href~="man"]');
    is $man-ish.elems, 1, 'select [href~=man]';
}

{
    my $man-ish = $sq('[href$="man"]');
    is $man-ish.elems, 1, 'select [href$=man]';
}

{
    my $en-ish = $sq('[hreflang="en"]');
    is $en-ish.elems, 1, 'select [hreflang=en]';
}

{
    my $not-en-ish = $sq('[hreflang!="en"]');
    is $not-en-ish.elems, 13, 'select [hreflang!=en]';
}

{
    my $en-ish = $sq('[hreflang^="en"]');
    is $en-ish.elems, 3, 'select [hreflang^=en]';
}

{
    my $zip-foo = $sq('[class="zip"] > [href="#foo"]');
    is $zip-foo.elems, 1, 'select [class=zip] > [href=#foo]';
}

{
    my $li-as = $sq('li > a');
    is $li-as.elems, 3, 'select li > a';
}

{
    my $zip-ish = $sq('.zip');
    is $zip-ish.elems, 2, 'select .zip';
}

{
    my $some-ish = $sq(':contains("Another")');
    is $some-ish.elems, 7, 'select :contains(Another)';
}

{
    my $body-as = $sq('body a');
    is $body-as.elems, 4, 'select body a';
}

{
    my $li-ish = $sq('li');
    is $li-ish.elems, 3, 'select li';
}

{
    my $a-ish = $sq('[href$="man"][hreflang|="en"]');
    is $a-ish.elems, 1, 'select [href$=man][hreflang|=en]';
}

{
    my $header-ish = $sq('title, h1');
    is $header-ish.elems, 2, 'select title, h1';
}

{
    my $li-sibling = $sq('li + li');
    is $li-sibling.elems, 2, 'select li + li';
}

{
    my $a-multi = $sq('a[class="zip"][hreflang]');
    is $a-multi.elems, 1, 'select a[class=zip][hreflang]';
}

done-testing;
