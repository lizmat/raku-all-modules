use v6;

class Build {
    method build($dist-path) {
        use LibraryMake;

        my $resources-dir = $dist-path.IO.add('resources');
        mkpath $resources-dir;
        make($dist-path, $resources-dir);
    }
}
