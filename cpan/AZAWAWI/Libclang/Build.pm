
use v6;

unit class Build;

method build($workdir) {

    # on *inux, let us try to make it
    my $makefiledir = "$workdir/src";
    my $destdir = "$workdir/resources";
    $destdir.IO.mkdir;

    # Create empty resources files for all platforms so that package managers
    # do not complain
    for <dylib so> -> $ext {
      "$destdir/libclang-perl6.$ext".IO.spurt('');
    }
    "$destdir/clang-perl6.dll".IO.spurt('');

    sub find-libclang-config {
      my @versions = <3.4 3.8 6.0>;
      for @versions -> $version {
        my $include-dir = "/usr/lib/llvm-$version/include";
        if $include-dir.IO ~~ :d {
          return {
            includes => "-I $include-dir",
            libs     => "-lclang-$version"
          }
        }
      }
      return
    }

    my $libname = sprintf($*VM.config<dll>, "clang-perl6");
    if $*DISTRO.name eq "macosx" {
      # macOS
      #TODO replace with run
      shell("gcc --shared -fPIC -I/usr/local/include -L/usr/local/lib -I /usr/local/Cellar/llvm/7.0.0/include -I /usr/local/Cellar/llvm/7.0.0/lib src/libclang-perl6.c -o $destdir/$libname -lclang")
    } elsif $*DISTRO.is-win {
      my $out-lib-path = $*SPEC.catfile($destdir, $libname);
      my $p = run q{gcc},
        q{--shared},
        q{-fPIC},
        q{-IC:/Program Files/LLVM/include},
        q{-IC:/Program Files/LLVM/lib/clang/7.0.0/lib/windows},
        q{-LC:/Program Files/LLVM/lib},
        q{src/libclang-perl6.c},
        qq{-o$out-lib-path},
        q{-llibclang},
        :err;
        my $captured-error  = $p.err.slurp: :close;
        my $exit-code = $p.exitcode;
        die "Failed while compiling $out-lib-path:\n$captured-error" unless $exit-code == 0;
        return 1;
    }  else {
      # *inux
      #TODO replace with run
      my $libclang-config = find-libclang-config;
      die "Unable to detect clang config" unless $libclang-config.defined;

      my $includes        = $libclang-config<includes>;
      my $libs            = $libclang-config<libs>;
      shell("gcc --shared -fPIC src/libclang-perl6.c -o $destdir/$libname $includes -I /usr/lib/llvm-3.8/include $libs")
    }

}
