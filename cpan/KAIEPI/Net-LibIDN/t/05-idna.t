use v6.c;
use Net::LibIDN;
use Test;

plan 4;

my $idna := Net::LibIDN.new;
my $input := "m\xFCssli.de";
my Int $code;
my $output := $idna.to_ascii_8z($input, 0, $code);
is $output, 'xn--mssli-kva.de';
is $code, IDNA_SUCCESS;
is $idna.to_unicode_8z8z($output, 0, $code), "m\xFCssli.de";
is $code, IDNA_SUCCESS;

done-testing;
