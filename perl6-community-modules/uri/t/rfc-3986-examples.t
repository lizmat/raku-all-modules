use v6;
use Test;
plan 22;

use URI;
my $u = URI.new('ftp://ftp.is.co.za/rfc/rfc1808.txt', :validating<1>);
is($u.scheme, 'ftp', 'ftp scheme');
is($u.host, 'ftp.is.co.za', 'ftp host');
is($u.path, '/rfc/rfc1808.txt', 'ftp path');

$u.parse('http://www.ietf.org/rfc/rfc2396.txt');
is($u.scheme, 'http', 'http scheme');
is($u.host, 'www.ietf.org', 'http host'); 
is($u.path, '/rfc/rfc2396.txt', 'http path'); 

$u.parse('ldap://[2001:db8::7]/c=GB?objectClass?one');
is($u.scheme, 'ldap', 'ldap scheme');
is($u.host, '[2001:db8::7]', 'ldap host');
is($u.path, '/c=GB', 'ldap path');
is($u.query, 'objectClass?one', 'ldap query');

$u.parse('mailto:John.Doe@example.com');
is($u.scheme, 'mailto', 'mailto scheme');
is($u.path, 'John.Doe@example.com', 'news path');

$u.parse('news:comp.infosystems.www.servers.unix');
is($u.scheme, 'news', 'news scheme');
is($u.path, 'comp.infosystems.www.servers.unix', 'news path');

$u.parse('tel:+1-816-555-1212');
is($u.scheme, 'tel', 'telephone scheme');
is($u.path, '+1-816-555-1212', 'telephone path');

$u.parse('telnet://192.0.2.16:80/');
is($u.scheme, 'telnet', 'telnet scheme');
is($u.authority, '192.0.2.16:80', 'telnet authority');
is($u.host, '192.0.2.16', 'telnet host');
is($u.port, '80', 'telnet port');

$u.parse('urn:oasis:names:specification:docbook:dtd:xml:4.1.2');
is($u.scheme, 'urn', 'urn scheme');
is($u.path, 'oasis:names:specification:docbook:dtd:xml:4.1.2', 'urn path');

# vim:ft=perl6
