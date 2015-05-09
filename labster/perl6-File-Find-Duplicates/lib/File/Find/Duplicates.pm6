#!/usr/bin/env perl6
use v6;
module File::Find::Duplicates:auth<labster>;

use Digest;
use File::Compare;

sub find_duplicates (:@dirs!, :$ignore_empty = False, :$recursive = False, :$method = 'md5' ) is export {
    my (@files, @duplicates);
    if $recursive {
        use File::Find;
        @files = map -> $d {find( dir => $d ).flat}, @dirs.flat
    }
    else { @files = @dirs».IO».dir.flat }

    my %filesizes;
    for @files.unique -> $f { $f.f and push %filesizes, $f.s=>$f }
    my $emptyfiles = %filesizes{'0'} :delete // Nil;
      # since empty files are obviously equivalent

    if ($method eq 'compare') {
        %filesizes
	    ==> grep( { .value ~~ Array } )
	    ==> map( { .value } )
	    ==> map( { compare_multiple_files($_.Array) } )
	    ==> @duplicates ;
    }
    else {
        %filesizes 
            ==> grep( { .value ~~ Array } )
            ==> map(  {  computeMD5($_) } )
            ==> grep( { .value ~~ Array } )
            ==> map(  { .value } )
            ==> @duplicates ;
    }

    @duplicates.push($emptyfiles) if !$ignore_empty and $emptyfiles;
    return @duplicates;
}

use MONKEY-TYPING;
augment class IO::Path {
    method duplicates ( :$ignore_empty = False, :$recursive = False ) is export {
        find_duplicates( :$ignore_empty, :$recursive, dirs=>[self.path] )
    }

}

# COMPUTEMD5 function
sub computeMD5 (Pair $size_files) {
    my $size = $size_files.key;
    my @files = $size_files.value.flat;
    my %checksums;

    for @files -> $f { %checksums.push( md5( $f.IO.slurp(:bin) ).list».fmt("%02x").join => $f)}

    return %checksums;

}


sub MAIN (:r(:$recursive), :l(:$sameline), :S($size), :n($noempty), :c($compare), *@directories) {
    for @directories -> $d { $d.path.d or die "Given path is not a directory" };

    my @dupes = find_duplicates( dirs => @directories,
				ignore_empty => $noempty,
				method => ($compare ?? 'compare' !! 'md5'),
				:$recursive);
    #say @dupes.perl;
    for @dupes -> $f {
            say $f[0].s, " bytes each:" if $size;
            if $sameline { $f».path.say }
            else { $f».path».say; print "\n"; }
    }
}


=begin pod

=head1 NAME

File::Find::Duplicates - get a list of duplicate files in directories

=head1 SYNOPSIS

	use File::Find::Duplicates;

	my @dupes = find_duplicates( dirs => ["~/Pictures", "/camera/import"],
                                     recursive=>True, ignore_empty => True );
        say "First set: {@dupes[0]».path.join(', ')}"
		#Produces (as an example)
                # "First set: ~/Pictures/IMG0001.jpg, /camera/import/IMG0001.JPG"
	my @moredupes = "/copiedfiles".path.duplicates;

=head1 DESCRIPTION

File::Find::Duplicates finds files which are duplicates of each other, by comparing size
and MD5 checksums.  While it is certainly possible that files of the same size will have
a hash collision, it's unlikely enough that most applications won't notice the difference.
Symbolic links can still get you into trouble, though.

The C<find_duplicates> function is the main method for accessing the function, though a
C<duplicates> method for IO::Path objects is also provided.  Both take the same arguments,
with the exception of C<dirs>.  Both functions return an array of arrays, listing each set
of duplicate files as IO::Path objects.

=head2 dirs

A required option, C<dirs> specifies which directories to look in.  Requires an array of
paths (as ordinary strings), though it's okay if it only contains one item.  In the method
form, the invocant IO::Path object serves as the directory to search through, and this
option is not required.

=head2 recursive

Specifies whether to descend through directories encountered; default is False.  If set to
a value like True, this module uses File::Find to descend the directory tree.

=head2 ignore_empty

Specifies whether or not we should bother to report empty files back as duplicates.
Defaults to False, but any value that evaluates to true will omit results with
file size = 0 bytes.

=head2 method

Takes "md5" (default) or "compare".  MD5 mode uses Digest::MD5 to check compare the content
of files, which may cause some rare false positives.  The other method, "compare", uses
File::Compare to look at the individual bytes of files.

=head1 CLI Usage

This module can be directly called from the command line, where it emulates some of the
functionality of fdupes.  Due to a bug, some perl6 implementations might not call C<MAIN>
in a module, and you might have to comment out the C<module> line to get it to work.

	$ perl Duplicates.pm6 [options] directories

=head2 CLI Options

-r	--recursive	Go through directories recursively
-S	--size		Print size of duplicate files
-n	--noempty	Don't include empty files in the results
-l	--sameline	Print results on a single line
			(careful: fdupes uses -1 instead of -l)
-c	--compare	Compare byte-by-byte rather than via MD5 hash


=head1 TODO

Probably optimize the code.  Add options for ordering and file deletion.

=head1 SEE ALSO

* L<File::Find>
* L<Digest::MD5>

=head1 AUTHOR

Brent "Labster" Laabs, 2012-2013.

Released under the same terms as Perl 6; see the LICENSE file for details.

=end pod


