
use v6;

use File::Zip::EndOfCentralDirectoryHeader;
use File::Zip::CentralDirectoryHeader;
use Compress::Zlib;

=begin markdown

Please see https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT

=end markdown

unit class File::Zip;

has Str        $.file-name   is rw;
has Bool       $.debug       is rw;
has IO::Handle $.fh          is rw;
has Int        $.eocd-offset is rw;
has            $.eocd-header is rw;
has            @.cd-headers  is rw;

method BUILD(Bool :$debug = False, Str :$file-name) {
  self.file-name = $file-name;
  self.debug     = $debug;
  self.fh        = $file-name.IO.open(:bin);

  my $eocd-offset = self._find-eocd-record-offset;
  die "Cannot find EOCD record" if $eocd-offset == -1;

  say "eocd offset = $eocd-offset" if self.debug;
  my $eocd-header = File::Zip::EndOfCentralDirectoryHeader.new;
  $eocd-header.read-from-handle(self.fh, $eocd-offset);
  self.eocd-header = $eocd-header;

  say "eocd-header = " ~ $eocd-header if self.debug;

  self._read-cd-headers;
}

method files {
  my @files;
  for @.cd-headers -> $cd-header {
    @files.push( { filename => $cd-header.file-name } );
  }

  return @files;
}

method unzip(Str :$directory = '.') {
  for @.cd-headers -> $cd-header {
    say "Extracting $( $cd-header.file-name )" if self.debug;
    self._read-local-file-header($cd-header, $directory);
  }
}

=begin markdown

=end markdown
method close {
  self.fh.close if self.fh.defined;
}

method _read-local-file-header($cd-header, Str $directory) {
  self.fh.seek($cd-header.local-file-header-offset, 0);

  my Buf $local_file_header-buf = self.fh.read(30);
  my (
    $signature, $version, $general-purpose-bit-flag, $compression-method,
    $last-modified-time, $last-modified-date, $crc32, $compressed-size,
    $uncompressed-size, $file-name-length, $extra-field-length
  ) = $local_file_header-buf.unpack("L S S S S S L L L S S");

  my Buf $file-name-buf = self.fh.read($file-name-length);

  my $output-file-name = $file-name-buf.decode('ascii');

  self.fh.seek($extra-field-length, 1);

  if $compression-method == 0x0 {
    # Not compressed
    if $cd-header.compressed-size > 0 {
      my $original = self.fh.read($cd-header.compressed-size);
      $directory.IO.mkdir;
      "$directory/$output-file-name".IO.spurt($original, :bin);
    } else {
      "$directory/$output-file-name".IO.mkdir;
      #"$directory/$output-file-name".IO.spurt($original, :bin);
    }
  } elsif $compression-method == 0x08 {
    # Deflate compression method
    my $compressed = self.fh.read($cd-header.compressed-size);
    my $decompressor = Compress::Zlib::Stream.new(:deflate);
    my $original = $decompressor.inflate($compressed);
    $directory.IO.mkdir;
    "$directory/$output-file-name".IO.spurt($original, :bin);

    CATCH {
      default {
        say $_;
      }
    }
  } else {
    die "Cannot handle compression method '$compression-method'";
  }
}

method _read-cd-headers {
  self.fh.seek(self.eocd-header.offset-central-directory, 0);

  my $number-records = self.eocd-header.number-central-directory-records-on-disk;
  my @cd-headers;
  for 1..$number-records -> $i {
    my $cd-header = File::Zip::CentralDirectoryHeader.new;
    $cd-header.read-from-handle(self.fh);
    @cd-headers.push( $cd-header );
  }
  self.cd-headers = @cd-headers;
}

=begin markdown

  Private method to scan for the end of central directory record signature
  starting from the end of the zip file.

=end markdown
method _find-eocd-record-offset {

  # Find file size
  self.fh.seek(0, 2);
  my $file-size = self.fh.tell;

  # Find EOCD hexidecimal signature 0x04034b50 in little endian
  for 0..$file-size-1 -> $offset {
    self.fh.seek(-$offset, 2);
    my Buf $bytes = self.fh.read(4);
    return $offset if $bytes[0] == 0x50 && $bytes[1] == 0x4b && $bytes[2] == 0x05 && $bytes[3] == 0x06;
  }

  return -1;
}
