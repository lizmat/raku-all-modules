#! /usr/bin/env perl6
use v6.c;

#! Open all source files in this module with an editor.
#! Calls the edit command provided with the found source files as arguments.
#! Example: open-all.p6 vim
sub MAIN(Str $editor) {
    my @files = gather take-files(
        dir,
        :include-ext<p6 pl pl6 pm pm6 t t6 pod c h cpp hpp cxx hxx>
    );

    run $editor, |@files
}

#! Call take on all files with a matching extension.
sub take-files(Positional $dir, Positional :$include-ext, Positional :$ignore-dirs = <.precomp .git>) {
    for $dir {
        when .f and .extension ~~ $include-ext.any {
            say "Found $_ ({ .extension })";
            .take
        }
        when .d and !(.basename ~~ $ignore-dirs.any) {
            say "Checking $_ ({ .basename })";
            take-files dir($_), :$include-ext
        }
        default {
            say "Ignored { .basename }, ext: { .extension } ($_)";
        }
    }
}
