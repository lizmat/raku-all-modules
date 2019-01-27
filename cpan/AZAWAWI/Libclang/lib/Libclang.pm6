
use v6;

unit class Libclang;

use Libclang::Cursor;
use Libclang::Index;
use Libclang::Raw;
use Libclang::TranslationUnit;

enum ChildVisitResult is export (
  child-visit-break     => CXChildVisit_Break,
  child-visit-continue  => CXChildVisit_Continue,
  child-visit-recurse   => CXChildVisit_Recurse
);

# Returns version string
method version returns Str {
  return clang_getClangVersion;
}
