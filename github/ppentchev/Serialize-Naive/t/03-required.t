#!/usr/bin/env perl6

use v6.c;

use Serialize::Naive;
use Test;

plan 6;

class Config does Serialize::Naive
{
	has Str $.local is required;
	has Str $.path;
}

my Config $c .= new(:local(Str), :path("foo"));
my $stuff = $c.serialize;
is $stuff.keys.sort, ('path',),
    'Only serialized the "path" field';

my Config $d .= deserialize($stuff);
ok !$d.local.defined, 'Deserialized the "local" field correctly';
is $d.path, 'foo', 'Deserialized the "path" field correctly';

$c .= new(:local(Str), :path(Str));
$stuff = $c.serialize;
is $stuff.keys.sort, (),
    'Serialized none of the fields';

$d .= deserialize($stuff);
ok !$d.local.defined, 'Deserialized the "local" field correctly';
ok !$d.path.defined, 'Deserialized the "path" field correctly';
