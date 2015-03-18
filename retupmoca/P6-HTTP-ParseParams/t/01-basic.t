use v6;
use Test;

plan 6;

use HTTP::ParseParams;

my %data = HTTP::ParseParams::parse("a=b&c=d", :urlencoded);

ok %data, 'parsed query string';
is %data<a>, 'b', 'got first param';
is %data<c>, 'd', 'got second param';

%data = HTTP::ParseParams::parse("a=1&a=2&a=3", :content-type('application/x-www-form-urlencoded'));

ok %data, 'parsed query string with passed content-type';
ok %data<a> ~~ Positional, 'Got multiple values for parameter';
ok %data<a> ~~ ['1', '2', '3'], 'Got correct results';
