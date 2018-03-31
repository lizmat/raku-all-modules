use v6.c;
use Net::LibIDN::Punycode;
use Test;

plan 4;

my $punycode := Net::LibIDN::Punycode.new;
my $domain = "m\xFC\xDFli.de";
my Int $code;
my $ace := $punycode.encode($domain, $code);
is $ace, 'mli.de-bta5u';
is $code, PUNYCODE_SUCCESS;
is $punycode.decode($ace, $code), $domain;
is $code, PUNYCODE_SUCCESS;

done-testing;
