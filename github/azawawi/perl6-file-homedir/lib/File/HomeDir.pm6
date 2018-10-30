unit class File::HomeDir;

use File::HomeDir::Win32;
use File::HomeDir::MacOSX;
use File::HomeDir::Unix;

my File::HomeDir $singleton;

method new
{
  return $singleton if $singleton.defined;
  
  if $*DISTRO.is-win {
    $singleton = self.bless does File::HomeDir::Win32;
  } elsif $*DISTRO.name eq 'macosx' {
    $singleton = self.bless does File::HomeDir::MacOSX;
  } else {
    $singleton = self.bless does File::HomeDir::Unix;
  }

  return $singleton;
}

method my-home {
  return File::HomeDir.new.my-home;
}

method my-desktop {
  return File::HomeDir.new.my-desktop;
}

method my-documents {
  return File::HomeDir.new.my-documents;
}

method my-music {
  return File::HomeDir.new.my-music;
}

method my-pictures {
  return File::HomeDir.new.my-pictures;
}

method my-videos {
  return File::HomeDir.new.my-videos;
}

method my-data {
  return File::HomeDir.new.my-data;
}

method my-dist-config(Str $distro-name) {
  return File::HomeDir.new.my-dist-config($distro-name);
}

method my-dist-data(Str $distro-name) {
  return File::HomeDir.new.my-dist-data($distro-name);
}

method users-home(Str $user) {
  return File::HomeDir.new.users-home($user);
}

method users-documents(Str $user) {
  return File::HomeDir.new.users-documents($user);
}

method users-data(Str $user) {
  return File::HomeDir.new.users-data($user);
}

=begin pod

=head1 NAME

File::HomeDir - Find your home and other directories on any platform

=head1 DESCRIPTION

This is a Perl 6 port of L<File::HomeDir|https://metacpan.org/pod/File::HomeDir>.
File::HomeDir is a module for locating the directories that are "owned" by a
user (typicaly your user) and to solve the various issues that arise trying to
find them consistently across a wide variety of platforms.

The end result is a single API that can find your resources on any platform,
making it relatively trivial to create Perl software that works elegantly and
correctly no matter where you run it.

=head1 SYNOPSIS

  use v6;

  use File::HomeDir;

  say File::HomeDir.my-home;
  say File::HomeDir.my-desktop;
  say File::HomeDir.my-documents;
  say File::HomeDir.my-pictures;
  say File::HomeDir.my-videos;

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2016 Ahmad M. Zawawi under the MIT License

=end pod
