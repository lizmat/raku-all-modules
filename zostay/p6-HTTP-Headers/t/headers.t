#!perl6

use v6;

use Test;
use HTTP::Headers;

my (HTTP::Headers $h, HTTP::Headers $h2);

$h = HTTP::Headers.new;
ok($h);
isa-ok($h, "HTTP::Headers");
is($h.as-string, "");

$h .= new;
$h.header('foo') = "bar", "baaaaz", "baz";
is($h.as-string, "Foo: bar\nFoo: baaaaz\nFoo: baz\n");

$h .= new;
$h.header('foo') = ["bar", "baz"];
is($h.as-string, "Foo: bar\nFoo: baz\n");

$h .= new;
$h.header('foo') = 1;
$h.header('bar') = 2;
$h.header('foo-bar') = 3;
is($h.as-string, "Bar: 2\nFoo: 1\nFoo-Bar: 3\n");
is($h.as-string(:eol<;>), "Bar: 2;Foo: 1;Foo-Bar: 3;");

is($h.header("Foo"), 1);
is($h.header("FOO"), 1);
is($h.header("foo"), 1);
is($h.header("foo-bar"), 3);
is($h.header("foo_bar"), 3);
is(?$h.header("Not-There"), False);
is($h.header("Not-There").list, []);

$h.header("Foo") = [ 1, 1 ];
is(~$h.header("Foo"), "1, 1");
is-deeply($h.header("Foo").list, (1, 1).list.item);
$h.header('foo') = 11;
$h.header('Foo').push: 12; 
$h.header('bar') = 22;
is($h.header("Foo").value, "11, 12");
is($h.header("Bar").value, '22');
$h.header('Bar') = ();
is($h.header("Bar"), '');
$h.header('Bar') = 22;
is($h.header("bar"), '22');
 
$h.header('Bar').push: 22;
is($h.header("Bar"), "22, 22");
$h.header('Bar').push: 23 .. 25;
is($h.header("Bar"), "22, 22, 23, 24, 25");
is($h.header("Bar").list.join('|'), "22|22|23|24|25");

is($h.elems, 3);
$h.clear;
is($h.elems, 0);
$h.header('Foo') = 1;
is($h.as-string, "Foo: 1\n");
$h.header('Foo').init(2);
$h.header('Bar').init(2);
is($h.as-string, "Bar: 2\nFoo: 1\n");
$h.header('Foo').init(2, 3);
$h.header('Baz').init(2, 3);
is($h.as-string, "Bar: 2\nBaz: 2\nBaz: 3\nFoo: 1\n");

is($h.as-string, $h.clone.as-string);
 
is($h.clone.remove-header("Foo"), '1');
is($h.clone.remove-header("Bar"), '2');
is($h.clone.remove-header("Baz"), '2, 3');
is($h.clone.remove-header(|<Foo Bar Baz Not-There>).elems, 4);
is($h.clone.remove-header("Not-There"), HTTP::Header);

$h .= new;
$h.Allow = "GET";
$h.header("Content") = "none";
$h.Content-Type = "text/html";
$h.Content-MD5 = "dummy";
$h.Content-Encoding = "gzip";
$h.header("content_foo") = "bar";
$h.Last-Modified = "yesterday";
$h.Expires = "tomorrow";
$h.ETag = "abc";
$h.Date = "today";
$h.User-Agent = "libwww-perl";
$h.header("zoo") = "foo";
is($h.as-string, q:to/EOT/);
Date: today
User-Agent: libwww-perl
ETag: abc
Allow: GET
Content-Encoding: gzip
Content-MD5: dummy
Content-Type: text/html
Expires: tomorrow
Last-Modified: yesterday
Content: none
Content-Foo: bar
Zoo: foo
EOT

is-deeply([ $h.list».name ], [
    Date, User-Agent, ETag, Allow, Content-Encoding, Content-MD5,
    Content-Type, Expires, Last-Modified, "Content", "Content-Foo",
    "Zoo",
]);

is-deeply([ $h.for-PSGI ], [
    'Date' => 'today',
    'User-Agent' => 'libwww-perl',
    'ETag' => 'abc',
    'Allow' => 'GET',
    'Content-Encoding' => 'gzip',
    'Content-MD5' => 'dummy',
    'Content-Type' => 'text/html',
    'Expires' => 'tomorrow',
    'Last-Modified' => 'yesterday',
    'Content' => 'none',
    'Content-Foo' => 'bar',
    'Zoo' => 'foo',
]);
 
$h2 = $h.clone;
is($h.as-string, $h2.as-string);
isnt($h.WHICH, $h2.WHICH);
isnt($h.internal-headers.WHICH, $h2.internal-headers.WHICH);
 
$h.remove-content-headers;
is($h.as-string, q:to/EOT/);
Date: today
User-Agent: libwww-perl
ETag: abc
Content: none
Zoo: foo
EOT

# Make sure the clone is still the same
is($h2.as-string, q:to/EOT/);
Date: today
User-Agent: libwww-perl
ETag: abc
Allow: GET
Content-Encoding: gzip
Content-MD5: dummy
Content-Type: text/html
Expires: tomorrow
Last-Modified: yesterday
Content: none
Content-Foo: bar
Zoo: foo
EOT

$h2.remove-content-headers;
is($h.as-string, $h2.as-string);
 
$h.clear;
is($h.as-string, "");
$h2 = Nil;

$h.clear;

done;
