perl6-File-Compare
==================

Compare files, byte-by-byte

Determines if two files are alike or if they differ.

Usage:

	use File::Compare;
	
	say files_are_equal("file1.txt", "file2.txt");
	files_are_different("foo", "bar") ?? say "diff" !! say "same";

	say "we match" if files_are_equal("x.png", "y.png",
		chunk_size=> 4*1024*1024);

See the pod in Compare.pm for more details.