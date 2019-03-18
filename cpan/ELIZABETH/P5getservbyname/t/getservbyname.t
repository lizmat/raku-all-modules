use v6.c;
use Test;
use P5getservbyname;
%*ENV<RAKUDO_NO_DEPRECATIONS> = True;

plan 16;

my @smtp = 'smtp', $*KERNEL.name eq 'darwin' ?? '' !! 'mail',25,'tcp';

is getservbyname(Scalar, "smtp","tcp"), 25,
  'did we find smtp by name in scalar context';
is getservbyname("smtp","tcp", :scalar), 25,
  'did we find smtp by name in scalar context';

my @byname = getservbyname("smtp","tcp");
is-deeply @byname, @smtp, 'did we find smtp by name';

is getservbyport(Scalar, 25,"tcp"), "smtp",
  'did we find ourselves by port in scalar context';
is getservbyport(25,"tcp",:scalar), "smtp",
  'did we find ourselves by port in scalar context';

my @byport = getservbyport(25,"tcp");
is-deeply @byport, @smtp, 'did we find smtp by port';

my $servname = getservent(Scalar);
ok ?$servname, 'did we get a serv name';

is setservent(False), 1, 'does setservent(False) return the undocumented 1';
is setservent(True),  1, 'does setservent(True) return the undocumented 1';

is endservent(), 1, 'does endservent return the undocumented 1';

is getservbyname(Scalar, "thisnameshouldnotexist", "tcp"), Nil,
  'did lookup by non-existing name fail in scalar context';
is getservbyname("thisnameshouldnotexist", "tcp", :scalar), Nil,
  'did lookup by non-existing name fail in scalar context';
is-deeply getservbyname("thisnameshouldnotexist", "tcp"), (),
  'did lookup by non-existing name fail';

is getservbyport(Scalar, 99999, "tcp"), Nil,
  'did lookup by non-existing port fail in scalar context';
is getservbyport(99999, "tcp", :scalar), Nil,
  'did lookup by non-existing port fail in scalar context';
is-deeply getservbyport(99999, "foo"), (),
  'did lookup by non-existing port fail';

# vim: ft=perl6 expandtab sw=4
