module File::Compare:auth<labster>;
use v6;

my $MAX = 8*1024*1024;    # Default maximum bytes for .read

sub files_are_equal (Str $left_filename, Str $right_filename, Int :$chunk_size = $MAX) is export {
	unless $chunk_size > 0 { die "Argument \$chunk_size must be a positive number" } 

	my $left_path  = $left_filename\.IO;
	my $right_path = $right_filename.IO;

	fail "Cannot read file: '$right_filename'" unless $right_path.r;
	fail "Cannot read file: '$left_filename'"  unless $left_path\.r;

	return False unless (my $size = $left_path.s) == $right_path.s;
	return True  if $size == 0;

	my $left  = $left_path\.open;
	my $right = $right_path.open;

	$size min= $chunk_size;

	while my $lhs := $left.read($size) {
		my $rhs := $right.read($size) or return False;
		$lhs eqv $rhs     or return False;
	}
	return False if $right.read($size); #i.e. if right still has data somehow

	True;

}

sub files_are_different (Str $left_filename, Str $right_filename, Int :$chunk_size = $MAX) is export {
	my $result = files_are_equal($left_filename, $right_filename, chunk_size => $chunk_size);
	$result ~~ Failure ?? $result !! !$result;
}

sub compare_multiple_files (@file_list, Int :$chunk_size = $MAX) is export {
	unless $chunk_size > 0 { die "Argument \$chunk_size must be a positive number"; }
	die "File list must contain only Str or IO::Path objects."
		unless $_ ~~ any(Str, IO::Path) for @file_list;

	my @file_paths = @file_list.».IO.grep: { .r };

	fail "Cannot read any files in @file_list." unless @file_paths.elems > 0;
	if @file_paths.elems == 1 {return Array.new};

	my @sizes = @file_paths».s;
	
	my @file = @file_paths».open;

	# since we can't use the contents to hash it, use an arbitrary type id.
	my @type;
	my $type_counter = 1;
	my @index := ^@file.elems;
	for @index -> $i {
		next if @type[$i].defined;
		@type[$i] = $type_counter;
		my $size := @sizes[$i];

		my %skip = map { $_ => True},
			   grep {@sizes[$_] != $size or @type[$_].defined }, @index;

		@file[$i].seek(0,0);
		#reset .tell in files we're not skipping
		#  TODO: check and see if @file».seek(0,0) would be faster anyway
		@file[grep {%skip{$_}.not}, @index]».seek(0,0);

		while my $left := @file[$i].read($chunk_size) {
			for $i^..^@file.elems -> $j {
				next if %skip{$j};
				my $right := @file[$j].read($chunk_size);
				$left eqv $right or %skip{$j} = True;
			}
		}
		@type[$_] = $type_counter for grep { %skip{$_}.not }, @index;
		$type_counter++;
	}

	my %files_by_type;
	%files_by_type.push(@type Z=> @file_paths);
	return %files_by_type.grep({.value ~~ Array}).hash.values;
}


=begin pod

=head1 NAME

File::Compare - Compare files to check for equality/difference

=head1 SYNOPSIS

	use File::Compare;
	
	if files_are_equal("file1.txt", "file2.txt")
		{ say "These are identical files"; }
	files_are_different("foo", "bar") ?? say "diff" !! say "same";


	say "we match" if files_are_equal("x.png", "y.png", chunk_size=> 4*1024*1024);
	say "OH NOES" if files_are_different("i/dont/exist", "me/neither") ~~ Failure;

=head1 DESCRIPTION

File::Compare checks to see if files have the same contents, by comparing them as byte-buffers if they are of the same size.

=head2 files_are_equal(), files_are_different()
  The function C<files_are_equal> returns Bool::True if the files have the same contents, Bool::False if any bytes are different, and a Failure object if an error occurs.  The other function, C<files_are_different>, returns the opposite boolean values, and is mostly provided for code readability sugar.  Note that Failure Boolifies to False, so the behavior is slightly different between the two functions.

=head2 compare_multiple_files
Another function, C<compare_multiple_files>, will compare the contents of an array of files (passed in as any mixture of Str and IO::Path objects).  It will return an array of arrays of IO::Path objects, with matching files grouped together.

=head2 chunk_size parameter
All three functions can take an optional named parameter, C<chunk_size>, which accepts any positive integer.  This parameter tells File::Compare what size of chunks should be read from the disk at once, since the read operation is often the slowest.  The default reads 8 MiB of each file at a time.  A smaller value may be more useful in a memory-limited environment, or when files are most likely different.  A larger value could improve performance when files are most likely the same.

=head1 DIFFERENCES FROM PERL 5 VERSION

This code returns boolean values and Failure objects instead of 1, 0, -1 for difference, equality, and failure respectively.  The read chunk size is also increased four-fold because you're not really trying to run Rakudo on a 80486 processor, are you?

=head2 Comparing Text

This Perl 6 version drops the C<compare_text> function that was included in Perl 5.  Since most text files are of managable size, consider this code, which uses Perl's native newline handling:
	C<"file1".IO.open.lines eq "file2".IO.open.lines>
Functions can be evaluated on this as well:
	C<foo( "old/script.p6".IO.open.lines ) eq foo( "new/script.p6".IO.open.lines )>
Though, you may be better off looking at a module like L<Text::Diff> instead.

=head1 TODO

Support IO objects as parameters.

=head1 SEE ALSO

* L<File::Find::Duplicates> - Searches directories and lists of files to find duplicate items.
* L<Text::Diff> - Perform diffs on files and record sets.

=head1 AUTHOR

Brent "Labster" Laabs, 2013.

Released under the same terms as Perl 6; see the LICENSE file for details.

=end pod

