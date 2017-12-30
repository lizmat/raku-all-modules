#! /usr/bin/env perl6
#Note `zef build .` will run this script
use v6.c;

class Build {
    need LibraryMake;
    # adapted from deprecated Native::Resources

    #| Sets up a C<Makefile> and runs C<make>.  C<$folder> should be
    #| C<"$folder/resources/lib"> and C<$libname> should be the name of the library
    #| without any prefixes or extensions.
    sub make(Str $folder, Str $destfolder, :$outname) {
        my %vars = LibraryMake::get-vars($destfolder);

        mkdir($destfolder);
        LibraryMake::process-makefile($folder, %vars);
        shell(%vars<MAKE>);
    }


    method build($workdir) {
        for <lib resources/bin resources/lib> -> $dir-to-make {
          mkdir $dir-to-make;
        }

        for <resources/lib libjust-for-tests resources/bin P6-Fcntl> -> $dir, $obj {
          make($workdir, $dir, :outname($obj));
        }
    }
}

# Build.pm can also be run standalone
sub MAIN(Str $working-directory = '.' ) {
    Build.new.build($working-directory);
}
