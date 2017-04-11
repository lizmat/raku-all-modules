use v6;
use lib 'lib';
use Test;
use Pod::To::BigPage;

plan 1;

=begin pod

E<171> E<SNOWMAN> E<171;SNOWMAN> E<quot>

=end pod

is $=pod>>.&handle(part-number => 1),
    "<p>\&#171; \&#9731; \&#171;\&#9731; \&quot;</p>\n",
    'E<> entities';
