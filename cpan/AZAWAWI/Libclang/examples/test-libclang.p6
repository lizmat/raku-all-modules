
use v6;

use NativeCall;
use lib 'lib';
use Libclang::Raw;
sub visitChildren(Pointer[CXCursor] $cursor, Pointer[CXCursor] $parent) {
  
  my $spelling      = clang_getCursorSpelling($cursor);
  my $kind          = clang_getCursorKind($cursor);
  my $kind-spelling = clang_getCursorKindSpelling($kind);
  printf("Cursor '%s' of kind '%s'\n", $spelling, $kind-spelling);
  return CXChildVisit_Recurse;
}

printf("libclang version '%s'\n", clang_getClangVersion);

my $index = clang_createIndex(0, 0);
LEAVE clang_disposeIndex($index);

my $null-ptr = Pointer.new;
my $unit = clang_parseTranslationUnit(
  $index,
  $*SPEC.catfile($*PROGRAM.IO.parent, "header.hpp"),
  $null-ptr,
  0,
  $null-ptr,
  0,
  CXTranslationUnit_None
);
die "Unable to parse translation unit. Quitting."
  unless $unit.defined;
LEAVE clang_disposeTranslationUnit($unit) if $unit.defined;

my $cursor-ptr = clang_getTranslationUnitCursor($unit);

LEAVE free($cursor-ptr) if $cursor-ptr.defined;

clang_visitChildren($cursor-ptr, &visitChildren);
