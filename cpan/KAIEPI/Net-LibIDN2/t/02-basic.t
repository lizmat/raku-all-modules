use v6.c;
use Net::LibIDN2;
use Test;

plan 9;

my $idn := Net::LibIDN2.new;
is $idn.check_version, IDN2_VERSION;
is $idn.check_version('0.0.1'), IDN2_VERSION;
is $idn.check_version('255.255.65525'), '';
is $idn.strerror(IDN2_OK), 'success';
is $idn.strerror_name(IDN2_OK), 'IDN2_OK';

{
    my $input := 'test';
    my $flags := IDN2_NFC_INPUT;
    my Int $code;
    is $idn.lookup_u8($input, $flags, $code), $input;
    is $code, IDN2_OK;
}

{
    my $uinput := "m\xFC\xDFli";
    my $ainput := 'xn--mli-5ka8l';
    my $flags := IDN2_NFC_INPUT;
    my Int $code;
    is $idn.register_u8($uinput, $ainput, $flags, $code), $ainput;
    is $code, IDN2_OK;
}

done-testing;
