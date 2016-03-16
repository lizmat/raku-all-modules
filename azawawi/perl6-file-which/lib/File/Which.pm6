
use v6;

=begin pod
  File::Which finds the full or relative paths to an executable program on the
  system. This is normally the function of which utility which is typically
  implemented as either a program or a built in shell command. On some unfortunate
  platforms, such as Microsoft Windows it is not provided as part of the core
  operating system.

    use File::Which;
    
    # All perl executables in PATH
    say which('perl', :all);
    
    # First executable in PATH
    say which('perl');

=end pod
module File::Which {

  constant IS_MAC = $*DISTRO.name eq 'macosx';
  constant IS_WIN = $*DISTRO.is-win;
  # Removed support for VMS
  # Delayed support for CYGWIN

  # For Win32 systems, stores the extensions used for executable files
  # For others, the empty string is used because 'perl' . '' eq 'perl' => easier
  my @PATHEXT = '';
  if ( IS_WIN ) {
    # WinNT. PATHEXT might be set on Cygwin, but not used.
    if ( %*ENV<PATHEXT>.defined ) {
      @PATHEXT = flat( %*ENV<PATHEXT>.split(';') );
    } else {
      # Win9X or other: doesn't have PATHEXT, so needs hardcoded.
      @PATHEXT.push( <.com .exe .bat> );
    }
  }

  sub which(Str $exec, Bool :$all = False) is export {
    fail("Exec parameter should be defined") unless $exec;

    my @results;

    # check for aliases first
    if IS_MAC {
      my @aliases = %*ENV<Aliases>:exists ?? %*ENV<Aliases>.split( ',' ) !! ();
      for @aliases -> $alias {
        # This has not been tested!!
        # PPT which says MPW-Perl cannot resolve `Alias $alias`,
        # let's just hope it's fixed
        if $alias.lc eq $exec.lc {
          chomp(my $file = qx<Alias $alias>);
          last unless $file;  # if it failed, just go on the normal way
          return $file unless $all;
          @results.push( $file );
          last;
        }
      }
    }

    return $exec
            if !IS_MAC && !IS_WIN && $exec ~~ /\// && $exec.IO ~~ :f && $exec.IO ~~ :x;

    my @path = flat( $*SPEC.path );

    for  @path.map({ $*SPEC.catfile($_, $exec) }) -> $base  {
      for @PATHEXT -> $ext {
        my $file = $base ~ $ext;

        # Ignore possibly -x directories
        next if $file.IO ~~ :d;

        if (
          # Executable, normal case
          $file.IO ~~ :x
          || (
            # MacOS doesn't mark as executable so we check -e
            IS_MAC
            ||
            (
              IS_WIN
              &&
              @PATHEXT[1..@PATHEXT.elems - 1].grep({ $file.match(/ $_ $ /, :i) })
            )
            # Windows systems don't pass -x on
            # non-exe/bat/com files. so we check -e.
            # However, we don't want to pass -e on files
            # that aren't in PATHEXT, like README.
            && $file.IO ~~ :e
          )
        ) {
          return $file unless $all;
          @results.push( $file );
        }
      }
    }

    return @results if $all;
    return;
  }

}
