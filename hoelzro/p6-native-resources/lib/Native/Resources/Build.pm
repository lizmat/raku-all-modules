use v6;

=head1 TITLE
Native::Resources::Build
=head1 DESCRIPTION
See L<Native::Resources> for an explanation of this module and
an example of its use.

need LibraryMake;

module Native::Resources::Build {
    #| A wrapper around L<LibraryMake>'s C<get-vars>.
    our sub get-vars(|c) is export {
        LibraryMake::get-vars(|c)
    }

    #| A wrapper around L<LibraryMake>'s C<process-makefile>.
    our sub process-makefile(|c) is export {
        LibraryMake::process-makefile(|c)
    }

    #| Sets up a C<Makefile> and runs C<make>.  C<$folder> passed into
    #| C<Panda::Builder.build>; C<$destfolder> should be C<"$folder/resources/lib">,
    #| and C<$libname> should be the name of your library without any prefixes or
    #| extensions.
    our sub make(Str $folder, Str $destfolder, Str :$libname) is export {
        my %vars = get-vars($destfolder);
        my @fake-shared-object-extensions = <.so .dll .dylib>.grep(* ne %vars<SO>);

        %vars<FAKESO> = @fake-shared-object-extensions.map("resources/lib/lib$libname" ~ *).eager;

        my $fake-so-rules = %vars<FAKESO>.map(-> $filename {
            qq{$filename:\n\tperl6 -e "print ''" > $filename}
        }).join("\n");

        mkdir($destfolder);
        process-makefile($folder, %vars);
        spurt("$folder/Makefile", $fake-so-rules, :append);
        shell(%vars<MAKE>);
    }
}
