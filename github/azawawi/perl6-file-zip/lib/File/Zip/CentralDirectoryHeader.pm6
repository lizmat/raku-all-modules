
use v6;

unit class File::Zip::CentralDirectoryHeader;

use experimental :pack;

has $.signature is rw;
has $.version-made-by is rw;
has $.version-needed is rw;
has $.flag is rw;
has $.compression-method is rw;
has $.last-modified-time is rw;
has $.last-modified-date is rw;
has $.crc32 is rw;
has $.compressed-size is rw;
has $.uncompressed-size is rw;
has $.file-name-length is rw;
has $.extra-file-name-length is rw;
has $.file-comment-length is rw;
has $.disk-number is rw;
has $.file-attributes is rw;
has $.extra-file-attributes is rw;
has $.local-file-header-offset is rw;
has $.file-name is rw;
has $.file-comment is rw;

method read-from-handle(IO::Handle $fh) {
  my Buf $buffer = $fh.read(46);
  (
    $.signature, $.version-made-by, $.version-needed, $.flag,
    $.compression-method, $.last-modified-time, $.last-modified-date, $.crc32,
    $.compressed-size, $.uncompressed-size, $.file-name-length,
    $.extra-file-name-length, $.file-comment-length, $.disk-number,
    $.file-attributes, $.extra-file-attributes, $.local-file-header-offset
  ) = $buffer.unpack("L S S S S S S L L L S S S S S L L");

  if $.file-name-length > 0 {
    my $file-name-buf = $fh.read($.file-name-length);
    $.file-name = $file-name-buf.decode('ascii');
  } else {
    $.file-name = '';
  }

  $fh.seek($.extra-file-name-length, SeekFromCurrent);
  
  if $.file-comment-length > 0 {
    my $file-comment-buf = $fh.read($.file-comment-length);
    $.file-comment = $fh.decode('ascii');
  } else {
    $.file-comment = '';
  }
}