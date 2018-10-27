use strict;
use Test;
use Cookie::Baker;

# Freeze time
my $now = 1381154217;

my @tests = (
    [ 'foo', 'val', Nil, 'foo=val'],
    [ 'foo', 'foo bar baz', Nil, 'foo=foo%20bar%20baz'],
    [ 'foo', 'val', { expires => Nil }, 'foo=val'],
    [ 'foo', 'val', { path => '/' }, 'foo=val; path=/'],
    [ 'foo', 'val', { path => '/', secure => True, httponly => False }, 'foo=val; path=/; secure'],
    [ 'foo', 'val', { path => '/', secure => False, httponly => True }, 'foo=val; path=/; HttpOnly'],
    [ 'foo', 'val', { expires => 'now' }, 'foo=val; expires=Mon, 07-Oct-2013 13:56:57 GMT'],
    [ 'foo', 'val', { expires => $now + 24*60*60 }, 'foo=val; expires=Tue, 08-Oct-2013 13:56:57 GMT'],
    [ 'foo', 'val', { expires => '1s' }, 'foo=val; expires=Mon, 07-Oct-2013 13:56:58 GMT'],
    [ 'foo', 'val', { expires => '+10' }, 'foo=val; expires=Mon, 07-Oct-2013 13:57:07 GMT'],
    [ 'foo', 'val', { expires => '+1m' }, 'foo=val; expires=Mon, 07-Oct-2013 13:57:57 GMT'],
    [ 'foo', 'val', { expires => '+1h' }, 'foo=val; expires=Mon, 07-Oct-2013 14:56:57 GMT'],
    [ 'foo', 'val', { expires => '+1d' }, 'foo=val; expires=Tue, 08-Oct-2013 13:56:57 GMT'],
    [ 'foo', 'val', { expires => '-1d' }, 'foo=val; expires=Sun, 06-Oct-2013 13:56:57 GMT'],
    [ 'foo', 'val', { expires => '+1M' }, 'foo=val; expires=Wed, 06-Nov-2013 13:56:57 GMT'],
    [ 'foo', 'val', { expires => '+1y' }, 'foo=val; expires=Tue, 07-Oct-2014 13:56:57 GMT'],
    [ 'foo', 'val', { expires => '0' }, 'foo=val; expires=Thu, 01-Jan-1970 00:00:00 GMT'],
    [ 'foo', 'val', { expires => '-1' }, 'foo=val; expires=Mon, 07-Oct-2013 13:56:56 GMT'],
    [ 'foo', 'val', { expires => 'foo' }, 'foo=val; expires=foo'],
);

for @tests {
    my ($name, $value, $opts, $expected) = @$_;
    if $opts {
        $opts<time> = $now;
        is( bake-cookie($name, $value, |$opts), $expected, $_.perl );
    } else {
        is( bake-cookie($name, $value), $expected, $_.perl );
    }
}

done-testing;

