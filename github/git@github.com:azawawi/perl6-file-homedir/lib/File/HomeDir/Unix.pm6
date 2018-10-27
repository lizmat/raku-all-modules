
use v6;

unit role File::HomeDir::Unix;

method my-home {
  # Try HOME on every platform first, because even on Windows, some
  # unix-style utilities rely on the ability to overload HOME.
  return %*ENV<HOME> if %*ENV<HOME>.defined;
  return;
}

method my-desktop {
  !!!
}

method my-documents {
  !!!
}

method my-music {
  !!!
}

method my-pictures {
  !!!
}

method my-videos {
  !!!
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

File::HomeDir::Unix - Unix implementation of File::HomeDir operations

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2016 Ahmad M. Zawawi under the MIT License

=end pod
