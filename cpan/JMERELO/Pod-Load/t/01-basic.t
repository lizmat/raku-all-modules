use v6.c;
use Test;
use Pod::Load;

constant %tests = { "test.pod6" => /extension/,
                    "class.pm6" => /Hello/,
                    "multi.pod6" => /mortals/ };

sub do-the-test() {
    diag "Testing strings";
    my $string-with-pod = q:to/EOH/;
=begin pod
This ordinary paragraph introduces a code block:
    $this = 1 * code('block');
    $which.is_specified(:by<indenting>);
=end pod
EOH

    my @pod = load( $string-with-pod );
    ok( @pod, "String load returns something" );
    like( @pod[0].^name, /Pod\:\:/, "The first element of that is a Pod");
    isa-ok( @pod[0].contents[0], Pod::Block::Para, "Parsed OK" );

    diag "Testing files";
    for %tests.kv -> $file, $re {
        my $prefix = $file.IO.e??"./"!!"t/";
        my $file-name = $prefix ~ $file;
        @pod = load( $file-name );
        ok( @pod, "$file-name load returns something" );
        like( @pod[0].^name, /Pod\:\:/, "That something is a Pod");
        my $io = $file-name.IO;
        @pod = load( $io );
        ok( @pod, "$file load returns something" );
        like( @pod[0].^name, /Pod\:\:/, "That something is a Pod");
        like( @pod.gist, $re, "$file gets the content right" );

    }
}

do-the-test(); # Use default values

done-testing;
