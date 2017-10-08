use v6;

use Test;

use LibYAML;
use LibYAML::Parser;
use LibYAML::Loader::TestSuite;
use LibYAML::Loader::Event;

my $DATA = $*PROGRAM;

my $loader = LibYAML::Loader::Event.new;
my $parser = LibYAML::Parser.new(
    loader => $loader,
);

my $yaml1 = q:to/EOM/;
---
foo: bar
...
EOM

my $yaml2 = q:to/EOM/;
%YAML 1.1
---
foo: bar
...
EOM

my $yaml3 = q:to/EOM/;
%TAG !e! tag:example.com,2000:app/
---
foo: bar
...
EOM


my @yaml = ($yaml1, $yaml2, $yaml3);

plan @yaml.elems * 2;

for 1 .. @yaml.elems -> $i {
    my $yaml = @yaml[ $i - 1 ];
    $loader.events = ();
    $parser.parse-string($yaml);

    my @events = $loader.events.Array;
    my $doc-start = @events[1];
    my $doc-end = @events[6];
    #dd $doc-start;
    #dd $doc-end;
    todo "explicit doc start not working yet";
    cmp-ok($doc-start<implicit>, 'eq', False, "yaml$i - explicit document start");
    todo "explicit doc end not working yet";
    cmp-ok($doc-end<implicit>, 'eq', False, "yaml$i - explicit document end");
}



done-testing;
