unit module File::Directory::Tree;

multi sub mktree (Cool:D $path is copy, Int :$mask = 0o777 ) is export {
	return True if $path.IO ~~ :d;
	$path.=IO;
	my @makedirs;
	while $path !~~ :e {
		@makedirs.push($path);
		$path.=parent;
	}
	for @makedirs.reverse -> $dir {
		mkdir($dir, $mask) or return False unless $dir.e;
	}
	True;
}

multi sub empty-directory (Cool:D $path is copy) {
    empty-directory $path.IO;
}

multi sub empty-directory (IO::Path:D $path) is export {
	$path.d or fail "$path is not a directory";
	for $path.dir -> $file {
		#say $file.perl;
		if $file.l.not and $file.d { rmtree $file }
		else { unlink $file }
	}
	True;
}

multi sub rmtree (Cool:D $path is copy) {
    rmtree $path.IO;
}

multi sub rmtree (IO::Path:D $path) is export {
	return True if !$path.e;
	$path.d or fail "$path is not a directory";
	empty-directory($path.IO) or return False;
	rmdir($path.IO) or return False;
	True;
}
