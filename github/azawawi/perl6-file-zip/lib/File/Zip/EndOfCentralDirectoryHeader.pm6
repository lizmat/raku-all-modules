
use v6;

unit class File::Zip::EndOfCentralDirectoryHeader;

use experimental :pack;

has $.signature is rw;
has $.number-disk is rw;
has $.disk-central-directory-on-disk is rw;
has $.number-central-directory-records-on-disk is rw;
has $.total-number-central-directory-records is rw;
has $.central-directory-size is rw;
has $.offset-central-directory is rw;
has $.comment-length is rw;
has Str $.comment is rw;

method read-from-handle(IO::Handle $fh, Int $eocd-offset) {
    $fh.seek(-$eocd-offset, SeekFromEnd);

    my Buf $eocd-buffer = $fh.read(22);
    ( $.signature, $.number-disk, $.disk-central-directory-on-disk,
      $.number-central-directory-records-on-disk,
      $.total-number-central-directory-records, $.central-directory-size,
      $.offset-central-directory, $.comment-length
    ) = $eocd-buffer.unpack("L S S S S L L S");

    if $.comment-length > 0 {
      my Buf $comment-buffer = $fh.read($.comment-length);
      $.comment = $comment-buffer.decode;
    } else {
      $.comment = '';
    }
}
