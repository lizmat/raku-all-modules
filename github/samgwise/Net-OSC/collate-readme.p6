#! /usr/bin/env perl6
use v6.c;
use JSON::Fast;
use Pod::To::Markdown;

sub MAIN(Str :$readme-out = 'README.md', Str :$readme-header = 'res/readme-header.md') {
    my $meta6 = 'META6.json'.IO.slurp.&from-json;
    my $components = gather {
        take $readme-header.IO.slurp if $readme-header.chars > 0;

        for $meta6<provides>.values.sort -> $module-file {
            say $module-file;

            my @cmd = $*EXECUTABLE, '--doc=Markdown', $module-file;
            my $p = run |@cmd , :out;
            LEAVE $p && $p.out.close; # Ensure all is clean when we're done
            # Check result
            die "Failed '@cmd[]' when collecting content." if $p.exitcode ≠ 0;

            take $p.out.slurp;
        }
    }

    # Bring it all together
    $readme-out.IO.spurt: join("\n\n", $components);
}
