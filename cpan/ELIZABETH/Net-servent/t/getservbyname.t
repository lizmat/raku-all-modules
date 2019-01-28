use v6.c;
use Test;
use Net::servent;

plan 8;

is getservbyname("smtp","tcp").port, 25,
  'did we find smtp by name in scalar context';

is getservbyport(25,"tcp").name, "smtp",
  'did we find ourselves by port in scalar context';

my $servname = getservent;
ok ?$servname, 'did we get a serv name';

is setservent(False), 1, 'does setservent(False) return the undocumented 1';
is setservent(True),  1, 'does setservent(True) return the undocumented 1';

is endservent(), 1, 'does endservent return the undocumented 1';

is getservbyname("thisnameshouldnotexist", "tcp"), Nil,
  'did lookup by non-existing name fail';

is getservbyport(99999, "tcp"), Nil,
  'did lookup by non-existing port fail';

# vim: ft=perl6 expandtab sw=4
