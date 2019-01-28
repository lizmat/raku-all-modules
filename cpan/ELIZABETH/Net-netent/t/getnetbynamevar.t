use v6.c;
use Test;
use Net::netent :FIELDS;

plan 8;

my $netname = getnetent.name;
ok ?$netname, 'did we get a net name';

getnetbyname($netname);
is $n_name, $netname, 'did we find ourselves by name';

my $addrtype = getnetbyname($netname).addrtype;
my $net      = getnetbyname($netname).net;
getnetbyaddr($net,$addrtype);
is $n_name, $netname, 'did we find ourselves by addr';

is setnetent(False), 1, 'does setnetent(False) return the undocumented 1';
is setnetent(True),  1, 'does setnetent(True) return the undocumented 1';

is endnetent(), 1, 'does endnetent return the undocumented 1';

getnetbyname("thisnameshouldnotexist"),
nok defined($n_name), 'did lookup by non-existing name fail';
getnetbyaddr(666, 42);
nok defined($n_name), 'did lookup by non-existing addr fail';

# vim: ft=perl6 expandtab sw=4
