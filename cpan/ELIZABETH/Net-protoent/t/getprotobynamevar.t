use v6.c;
use Test;
use Net::protoent :FIELDS;

plan 9;

getprotobyname("ip");
is $p_name, "ip", 'did we find ip by name';
is $p_proto,   0, 'did we find ip by name';

getprotobynumber(0);
is $p_name, "ip", 'did we find ip by proto';
is $p_proto,   0, 'did we find ip by proto';

is setprotoent(False), 1, 'does setprotoent(False) return the undocumented 1';
is setprotoent(True),  1, 'does setprotoent(True) return the undocumented 1';

is endprotoent(), 1, 'does endprotoent return the undocumented 1';

getprotobyname("thisnameshouldnotexist");
nok defined($p_name), 'did lookup by non-existing name fail';
getprotobynumber(99999);
nok defined($p_name), 'did lookup by non-existing proto fail';

# vim: ft=perl6 expandtab sw=4
