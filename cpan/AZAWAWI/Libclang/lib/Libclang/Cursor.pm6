
use v6;

unit class Libclang::Cursor;

use Libclang::Raw;
use NativeCall;

has Pointer $.cursor is required;

method spelling {
  die "Cursor is undefined" unless $!cursor.defined;
  clang_getCursorSpelling($!cursor);
}

method kind {
  die "Cursor is undefined" unless $!cursor.defined;
  clang_getCursorKind($!cursor);
}

method kind-spelling {
  die "Cursor is undefined" unless $!cursor.defined;
  clang_getCursorKindSpelling(self.kind);
}

method location {
  die "Cursor is undefined" unless $!cursor.defined;
  my $location-ptr = clang_getCursorLocation($!cursor);
  $location-ptr
}

method visit-children(&visitor-callback) {
  die "Cursor is undefined"   unless $!cursor.defined;
  die "Callback is undefined" unless &visitor-callback.defined;

  sub visitChildren(
    Pointer[CXCursor] $cursor-pointer,
    Pointer[CXCursor] $parent-pointer
  ) {
    my $cursor = Libclang::Cursor.new(:cursor($cursor-pointer));
    my $parent = Libclang::Cursor.new(:cursor($parent-pointer));
    return &visitor-callback($cursor, $parent);
  }

  clang_visitChildren($!cursor, &visitChildren);
}

method destroy {
  die "Cursor is undefined" unless $!cursor.defined;
  free($!cursor);
}
