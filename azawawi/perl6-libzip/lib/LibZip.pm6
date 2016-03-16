use v6;

unit class LibZip;

use NativeCall;
use NativeHelpers::Blob;
use LibZip::NativeCall;

# TODO Pointer[zip] is not working at the moment (NYI as of rakudo 2016.02)
has Pointer $.archive is rw;

method open(Str $file-name) {
  my $error-code;
  my Pointer $archive = zip_open($file-name, ZIP_CREATE, $error-code);
  die "Failed: $error-code!" unless $archive;
  $.archive = $archive;
}

method add-file(Str $file-name) {
  die "No open zip archive" unless $.archive;
  my $file-data-source = zip_source_file($.archive, $file-name, 0, -1);
  die "Failed!" unless $file-data-source;
  my $result = zip_add($.archive, $file-name.IO.basename, $file-data-source);
  die "Failed while adding to zip archive" if $result == -1;
}

method add-blob(Str $file-name, Blob $blob) {
  die "No open zip archive" unless $.archive;

  # Prepare a zip data source from memory buffer
  my $data = carray-from-blob($blob);
  my $memory-data-source = zip_source_buffer($.archive, $data, $blob.elems, 0);
  unless $memory-data-source {
    my $error-code        = CArray[int32].new;
    my $system-error-code = CArray[int32].new;
    zip_error_get($.archive, $error-code, $system-error-code);
    die "Failed with the following error code: $($error-code[0]) and system error code: $($system-error-code[0])";
  }

  # Add memory data source to zip archive
  my $result = zip_add($.archive, $file-name, $memory-data-source);
  die "Failed" if $result == -1;
}

method close {
  die "No open zip archive" unless $.archive;

  # Close the zip archive
  my $result = zip_close($.archive);
  die "Failed" if $result != ZIP_ER_OK;
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

=head2 add-file

TODO document

=head2 add-buffer

TODO document

=head2 close

TODO document

=head1 AUTHOR

Ahmad M. Zawawi <ahmad.zawawi@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Ahmad M. Zawawi under the MIT License

=end pod
