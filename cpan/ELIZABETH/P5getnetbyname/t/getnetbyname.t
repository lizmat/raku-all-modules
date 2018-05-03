use v6.c;
use Test;
use P5getnetbyname;

plan 11;

my $netname = getnetent(:scalar);
ok ?$netname, 'did we get a net name';

is getnetbyname($netname, :scalar), $netname,
  'did we find ourselves by name';

my @byname = getnetbyname($netname);
is getnetbyaddr(@byname[3],@byname[2],:scalar), $netname,
  'did we find ourselves by addr';

my @byaddr = getnetbyaddr(@byname[3],@byname[2]);
is-deeply @byaddr, @byname, 'did the structs come out the same';

is setnetent(False), 1, 'does setnetent(False) return the undocumented 1';
is setnetent(True),  1, 'does setnetent(True) return the undocumented 1';

is endnetent(), 1, 'does endnetent return the undocumented 1';

is getnetbyname("thisnameshouldnotexist", :scalar), Nil,
  'did lookup by non-existing name fail in scalar context';
is-deeply getnetbyname("thisnameshouldnotexist"), (),
  'did lookup by non-existing name fail';

is getnetbyaddr(666, 42, :scalar), Nil,
  'did lookup by non-existing addr fail in scalar context';
is-deeply getnetbyaddr(666, 42), (),
  'did lookup by non-existing addr fail';

# vim: ft=perl6 expandtab sw=4
