use v6;
use Test;
use App::ecogen;
plan 4;

sub from-json($json) {
    ::('Rakudo::Internals::JSON').from-json: $json
}

my $prefix = $*TMPDIR.child('app-ecogen');
$prefix.mkdir;

my $meta = q/{
    "meta-version": 1,
    "name": "test",
    "depends": [
        "foo:from<native>",
        "bar",
        {
            "name": "baz",
            "hints": { }
        }
    ]
}/;
class App::ecogen::test does Ecosystem {
    has $.prefix;
    method IO { self.prefix.IO }
    method meta-uris { }
    method package-list(@meta-uris = []) {
        [ from-json($meta) ]
    }
}

App::ecogen::test.new(:prefix($prefix.child('test'))).update-local-package-list;

is-deeply from-json(slurp($prefix.child('test1.json'))), from-json("[\n$meta\n]");
is-deeply from-json(slurp($prefix.child('test.json'))), from-json(q/[{ "meta-version": 0, "name": "test", "depends": [ "bar", "baz" ] }]/);

$meta = q/{
    "meta-version": 1,
    "name": "test",
    "depends": {
        "build": {
            "requires": [
                "foo:from<native>",
                "bar",
                {
                    "name": "baz",
                    "hints": { }
                }
            ]
        }
    }
}/;

App::ecogen::test.new(:prefix($prefix.child('test'))).update-local-package-list;

is-deeply from-json(slurp($prefix.child('test1.json'))), from-json("[\n$meta\n]");
is-deeply from-json(slurp($prefix.child('test.json'))), from-json(q/[{ "meta-version": 0, "name": "test", "build-depends": [ "bar", "baz" ] }]/);

END {
    if $prefix {
        .unlink for $prefix.dir;
        $prefix.rmdir;
    }
}
