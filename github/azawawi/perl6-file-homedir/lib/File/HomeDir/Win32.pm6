
use v6;

unit role File::HomeDir::Win32;

method my-home {
  # Try HOME on every platform first, because even on Windows, some
  # unix-style utilities rely on the ability to overload HOME.
  return %*ENV<HOME> if %*ENV<HOME>.defined;
  return %*ENV<HOMEDRIVE> ~ %*ENV<HOMEPATH>;
}

method my-desktop {
  return $*SPEC.catdir(self.my-home, "Desktop");
}

method my-documents {
  return $*SPEC.catdir(self.my-home, "Documents");
}

method my-music {
  return $*SPEC.catdir(self.my-home, "Music");
}

method my-pictures {
  return $*SPEC.catdir(self.my-home, "Pictures");
}

method my-videos {
  return $*SPEC.catdir(self.my-home, "Videos");
}

method my-data {
  !!!
}

method my-dist-config(Str $distro-name) {
  !!!
}

method my-dist-data(Str $distro-name) {
  !!!
}

method users-home(Str $user) {
  !!!
}

method users-documents(Str $user) {
  !!!
}

method users-data(Str $user) {
  !!!
}

=begin pod

=head1 NAME

File::HomeDir::Win32 - Windows implementation of File::HomeDir operations

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2016 Ahmad M. Zawawi under the MIT License

=end pod
