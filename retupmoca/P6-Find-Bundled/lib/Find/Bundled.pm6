unit class Find::Bundled;

method find(Str $lib, Str $base, :$keep-filename, :$return-original, :$throw) {
    # if we can't find one, assume there's a system install
    my $b = $lib;
    if $base {
        $b = $base~"/$lib";
    }
    for @*INC -> $_ is copy {
        $_ = CompUnitRepo.new($_);
        my $base = $b;
        if $_ ~~ CompUnitRepo::Local::File {
            # CUR::Local::File has screwed up .files semantics
            $base = $_.IO ~ '/' ~ $base;
        }
        if my @files = ($_.files($base)
                     || $_.files("lib/$base")
                     || $_.files("blib/$base")
                     || $_.files("blib/lib/$base")) {
            my $files = @files[0]<files>;
            my $tmp = $files{$base} || $files{"blib/$base"};

            if $keep-filename {
                # copy to a temp dir
                $tmp.IO.copy($*SPEC.tmpdir ~ '\\' ~ $lib);
                return $*SPEC.tmpdir ~ '\\' ~ $lib;
            }
            else {
                return $tmp;
            }
        }
    }

    if $throw {
        die "Unable to find $lib";
    }
    elsif $return-original {
        return $lib;
    }
    else {
        return;
    }
}
