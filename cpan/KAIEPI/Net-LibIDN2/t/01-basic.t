use v6.c;
use Net::LibIDN2;
use Test;

plan 13;

my $idn := Net::LibIDN2.new;
is $idn.check_version, IDN2_VERSION;
is $idn.check_version('0.0.1'), IDN2_VERSION;
is $idn.check_version('255.255.65525'), '';
is $idn.strerror(IDN2_OK), 'success';
is $idn.strerror_name(IDN2_OK), 'IDN2_OK';

if IDN2_VERSION_MAJOR < 2 {
    skip 'idn2_to_ascii_8z and idn2_to_ascii_8z8z did not exist before LibIDN v2.0.0', 4;
} else {
    {
        my $input := "m\xFC\xDFli.de";
        my $flags := IDN2_NFC_INPUT;
        my Int $code;
        my $output := $idn.to_ascii_8z($input, $flags, $code);
        is $output, 'xn--mli-5ka8l.de';
        is $code, IDN2_OK;
    }

    {
        my $input := 'xn--mli-5ka8l.de';
        my $flags := IDN2_NFC_INPUT;
        my Int $code;
        my $output := $idn.to_unicode_8z8z($input, $flags, $code);
        is $output, "m\xFC\xDFli.de";
        is $code, IDN2_OK;
    }
}

{
    my $uinput := "m\xFC\xDFli";
    my $flags := IDN2_NFC_INPUT;
    my Int $code;
    my $ainput := $idn.lookup_u8($uinput, $flags, $code);
    is $ainput, 'xn--mli-5ka8l';
    is $code, IDN2_OK;
    is $idn.register_u8($uinput, $ainput, $flags, $code), $ainput;
    is $code, IDN2_OK;
}

done-testing;
