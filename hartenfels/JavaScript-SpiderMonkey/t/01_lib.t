use v6;
use Test;
use NativeCall;


my $got-lib = lives-ok
{
    sub p6sm_version(--> int32) is native('libp6-spidermonkey') { * }
    note "spidermonkey version {p6sm_version}";
},
'spidermonkey helper is installed';


unless $got-lib
{
    say 'Bail out! NativeCall to libp6-spidermonkey not working';
    exit 255;
}


done-testing
