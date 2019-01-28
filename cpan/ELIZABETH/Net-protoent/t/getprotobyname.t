use v6.c;
use Test;
use Net::protoent;

plan 9;

my $p = getprotobyname("ip");
is $p.name, "ip", 'did we find ip by name';
is $p.proto,   0, 'did we find ip by name';

$p = getprotobynumber(0);
is $p.name, "ip", 'did we find ip by proto';
is $p.proto,   0, 'did we find ip by proto';

is setprotoent(False), 1, 'does setprotoent(False) return the undocumented 1';
is setprotoent(True),  1, 'does setprotoent(True) return the undocumented 1';

is endprotoent(), 1, 'does endprotoent return the undocumented 1';

is getprotobyname("thisnameshouldnotexist"), Nil,
  'did lookup by non-existing name fail in scalar context';
is getprotobynumber(99999), Nil,
  'did lookup by non-existing proto fail in scalar context';

# vim: ft=perl6 expandtab sw=4
