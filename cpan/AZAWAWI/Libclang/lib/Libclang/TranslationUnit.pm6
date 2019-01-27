

use v6;

unit class Libclang::TranslationUnit;

use NativeCall;
use Libclang::Index;
use Libclang::Raw;
use Libclang::Cursor;

has $.translation-unit;

method new(Libclang::Index $index, Str $file-name) {
  die "Index is undefined" unless $index.defined;
  die "File name is undefined" unless $file-name.defined;
  die "File is not found '$file-name'" unless $file-name.IO ~~ :f;

  my $null-ptr        = Pointer.new;
  my $translation-unit = clang_parseTranslationUnit(
    $index.index,
    $file-name,
    $null-ptr,
    0,
    $null-ptr,
    0,
    CXTranslationUnit_None
  );
  die "Unable to parse translation unit." unless $translation-unit.defined;

  self.bless(:$translation-unit);
}

method cursor {
  die "Translation unit is undefined" unless $!translation-unit.defined;
  return Libclang::Cursor.new(
    :cursor(clang_getTranslationUnitCursor($!translation-unit))
  );
}

method destroy {
  die "Translation unit is undefined" unless $!translation-unit.defined;
  clang_disposeTranslationUnit($!translation-unit);

  return;
}
