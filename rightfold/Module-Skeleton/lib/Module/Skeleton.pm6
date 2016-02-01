use v6.c;
use JSON::Pretty;

sub catpath(*@paths --> IO::Path:D) {
    @paths.join($*SPEC.dir-sep).IO;
}

sub superspurt(IO::Path:D $where, $what, Bool:D :$overwrite) {
    return if !$overwrite && $where.e;
    $where.dirname.IO.mkdir;
    spurt($where, $what);
}

class Module::Skeleton {
    has Str $.name;
    has $.author;
    has $.description;

    method spurt(IO::Path:D $root) {
        $root.mkdir;
        self!spurt-meta($root);
        self!spurt-lib($root);
        self!spurt-t($root);
    }

    method !spurt-meta(IO::Path:D $root) {
        my $meta-path = catpath($root, 'META.info');
        my $meta = {
            name => $.name,
            perl => '6.*',
            version => '0.0.1',
            description => $.description // '',
            authors => [$.author].grep(*.defined),
            provides => {
                $.name => 'lib/' ~ $.name.subst('::', '/', :g) ~ '.pm6',
            },
            test-depends => ['Test::META'],
        };
        superspurt($meta-path, to-json($meta) ~ "\n", :!overwrite);
    }

    method !spurt-lib(IO::Path:D $root) {
        catpath($root, 'lib').mkdir;
        my $module-path = catpath($root, 'lib', $.name.subst('::', '/', :g) ~ '.pm6');
        superspurt($module-path, q:to:c/EOF/, :!overwrite);
        use v{$*PERL.version};

        unit module {$.name};
        EOF
    }

    method !spurt-t(IO::Path:D $root) {
        catpath($root, 't').mkdir;

        my $test-path = catpath($root, 't', $.name.subst('::', '/', :g) ~ '.t');
        superspurt($test-path, q:to:c/EOF/, :!overwrite);
        use v{$*PERL.version};
        use Test;
        use {$.name};

        diag('TODO: add tests');
        ok('foo' eq 'bar');

        done-testing;
        EOF

        my $meta-test-path = catpath($root, 't', 'META.t');
        superspurt($meta-test-path, q:to:c/EOF/, :!overwrite);
        use v{$*PERL.version};
        use Test;
        use Test::META;

        meta-ok;

        done-testing;
        EOF
    }
}
