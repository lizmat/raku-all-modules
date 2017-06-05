use v6;

use Test;

use LibYAML;
use LibYAML::Emitter;

my $emitter = LibYAML::Emitter.new(
);

$emitter.init;
$emitter.buf = '';
$emitter.set-output-string;

plan 1;

$emitter.stream-start-event;
$emitter.document-start-event(False);
$emitter.sequence-start-event(Str, Str);
$emitter.scalar-event("anchor", "!tag", "anchor and tag", "plain");
$emitter.scalar-event(Str, "!tag", "tag", "plain");
$emitter.scalar-event("anchor", Str, "anchor", "plain");
$emitter.sequence-end-event();
$emitter.document-end-event(False);
$emitter.stream-end-event;
$emitter.delete;
my $yaml = $emitter.buf;

my $expected-yaml = q:to/EOM/;
---
- &anchor !tag anchor and tag
- !tag tag
- &anchor anchor
...
EOM
#q:
todo "tag emitting not working yet";
cmp-ok($yaml, 'eq', $expected-yaml, "emit");

done-testing;
