use v6.c;
use Net::LibIDN::StringPrep;
use Test;

plan 11;

my $sp := Net::LibIDN::StringPrep.new;
is $sp.check_version, STRINGPREP_VERSION;
is $sp.check_version(''), STRINGPREP_VERSION;
is $sp.check_version('255.255.65525'), '';
is $sp.strerror(STRINGPREP_OK), 'Success';

{
    my $input = 'test';
    my Int $code;
    my $output = $sp.profile($input, 'plain', 0, $code);
    is $code, 0;
    is $output, $input;
}

{
    my $input = 'test';
    my Int $code;
    my $output = $sp.plain($input, $code);
    is $code, 0;
    is $output, $input;

    $input ~= "\x7F";
    $output = $sp.plain($input, $code);
    is $code, STRINGPREP_CONTAINS_PROHIBITED;
    is $output, '';
}

{
    my $input = "m\xFC\xDFli.de".encode('utf8-c8');
    my $output := $sp.utf8_to_ucs4($input);
    is $sp.ucs4_to_utf8($output), $input;
}

done-testing;
