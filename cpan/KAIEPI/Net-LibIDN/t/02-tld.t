use v6.c;
use NativeCall;
use Net::LibIDN::StringPrep;
use Net::LibIDN::TLD;
use Test;

my $version := Version.new(STRINGPREP_VERSION);
plan :skip-all<TLD functions did not exist before LibIDN v2.0.0> if $version < v0.4.0;
plan 13;

my $idn_tld := Net::LibIDN::TLD.new;

{
    my $errname := $idn_tld.strerror(TLD_SUCCESS);
    is $errname, 'Success';
}

{
    my $domain := 'google.fr';
    my Int $code;
    my $tld := $idn_tld.get_z($domain, $code);
    is $tld, 'fr';
    is $code, TLD_SUCCESS;
}

{
    my $tld := 'fr';
    my Int $code;
    my $tableptr := $idn_tld.default_table($tld);
    ok $tableptr;

    my $table := $tableptr.deref;
    ok $table;
    is $table.name, $tld;
    ok $table.version;
    ok $table.nvalid;
    subtest {
        plan $table.nvalid * 3;
        for 0..^$table.nvalid -> $i {
            my $element := $table.valid[$i];
            ok $element;
            ok $element.start;
            ok $element.end;
        }
    }

    my $tableptr2 := $idn_tld.get_table($tld, [$tableptr]);
    ok $tableptr2;
    is-deeply $tableptr2.deref, $table;
}

{
    my $tld := 'com';
    my Int $code;
    my $errpos := $idn_tld.check_8z($tld, $code);
    is $errpos, 0;
    is $code, TLD_SUCCESS;
}

done-testing;
