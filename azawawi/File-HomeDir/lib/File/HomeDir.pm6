unit class File::HomeDir;

=begin pod
  Returns the current user home directory if found.
  Otherwise, it is undefined.
=end pod
method my_home {
  # Try HOME on every platform first, because even on Windows, some
  # unix-style utilities rely on the ability to overload HOME.
  return %*ENV<HOME> if %*ENV<HOME>;

  given $*KERNEL.name {
    when 'win32' {
      return %*ENV<HOMEDRIVE> ~ %*ENV<HOMEPATH>
    }
    when 'linux' {
      return %*ENV<HOME>
    }
    when 'darwin' {
      return $*ENV<HOME>
    }
  }
  
  return;
}

=begin pod
  Returns the current user desktop directory if found.
  Otherwise, it is undefined.
=end pod
method my_desktop {
  !!!
}

=begin pod
  Returns the current user documents directory if found.
  Otherwise, it is undefined.
=end pod
method my_documents {
  !!!
}

=begin pod
  Returns the current user music directory if found.
  Otherwise, it is undefined.  
=end pod
method my_music {
  !!!
}

=begin pod
  Returns the current user pictures directory if found.
  Otherwise, it is undefined.
=end pod
method my_pictures {
  !!!
}

=begin pod
  Returns the current user videos directory if found.
  Otherwise, it is undefined.
=end pod
method my_videos {
  !!!
}

=begin pod
  Returns the current user local application internal data directory if found.
  Otherwise, it is undefined.
=end pod
method my_data {
  !!!
}

=begin pod
TODO document
=end pod
method my_dist_config {
  !!!
}

=begin pod
TODO document
=end pod
method my_dist_data {
  !!!
}

=begin pod
TODO document
=end pod
method users_home(Str $user) {
  !!!
}

=begin pod
TODO document
=end pod
method users_documents(Str $user) {
  !!!
}

=begin pod
TODO document
=end pod
method users_data(Str $user) {
  !!!
}
