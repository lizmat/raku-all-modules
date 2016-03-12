use v6;

unit class LibZip;

use NativeCall;
use LibZip::NativeCall;

class LibZip {
  has Pointer[zip] $.archive;

  method open(Str $file-name) {
    my $error-code;
    my Pointer[zip] $archive = zip_open($file-name, ZIP_CREATE, $error-code);
    die "Failed: $error-code!" unless $archive;
  }
}

=begin pod

=head1 NAME

LibZip - Perl 6 bindings for libzip

=head1 SYNOPSIS

  use LibZip;

=head1 DESCRIPTION

LibZip provides Perl 6 bindings for L<libzip|http://www.nih.at/libzip/libzip.html>.

=head1 INSTALLATION

    sudo apt-get install libzip-dev

=head1 METHODS

=head2 open

TODO document

=head2 close

TODO document

=head1 AUTHOR

Ahmad M. Zawawi <ahmad.zawawi@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Ahmad M. Zawawi under the MIT License

=end pod
