File::Find::Duplicates

Provides a way to detect duplicate files.  Searches through directories
provided by you to find copies of files, and checks to see if the MD5
checksum is identical.

The basic ways to call it are:

	use File::Find::Duplicates;
	#Functional form:
	my @dupes = find_duplicates(
					dirs=>['/folder1', 'path/folder2'],
					recursive => True,
					ignore_empty => True
	);
	#Method form, for IO::Path objects:
	my @moredupes = "/copiedfiles".path.duplicates;

See the pod in Duplicates.pm for more information.