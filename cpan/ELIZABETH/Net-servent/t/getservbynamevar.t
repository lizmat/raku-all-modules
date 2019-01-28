use v6.c;
use Test;
use Net::servent :FIELDS;

plan 8;

getservbyname("smtp","tcp");
is $s_port, 25, 'did we find smtp by name in scalar context';

getservbyport(25,"tcp");
is $s_name, "smtp", 'did we find ourselves by port in scalar context';

ok getservent() ~~ Net::servent, 'did we get a Net::servent object';

is setservent(False), 1, 'does setservent(False) return the undocumented 1';
is setservent(True),  1, 'does setservent(True) return the undocumented 1';

is endservent(), 1, 'does endservent return the undocumented 1';

getservbyname("thisnameshouldnotexist", "tcp");
nok defined($s_port), 'did lookup by non-existing name fail';

getservbyport(99999, "tcp");
nok defined($s_name), 'did lookup by non-existing port fail';

# vim: ft=perl6 expandtab sw=4
