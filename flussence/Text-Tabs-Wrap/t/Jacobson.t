#!/usr/bin/env perl6
use v6;
use Test;
use Text::Wrap;

my @input = (
    "mmmm,n,ooo,ppp.qqqq.rrrrr,sssssssssssss,ttttttttt,uu,vvv wwwwwwwww####\n",
    "mmmm,n,ooo,ppp.qqqq.rrrrr.adsljasdf\nlasjdflajsdflajsdfljasdfl\nlasjdflasjdflasf,sssssssssssss,ttttttttt,uu,vvv wwwwwwwww####\n"
);

plan +@input;

my $word-break = rx{<?after <[,.]>>};

for @input.kv -> $num, $str {
    lives-ok {
        wrap('', '', $str, :may-overflow, :columns(9), :$word-break)
    }, "Test {1+$num} ran"
}
