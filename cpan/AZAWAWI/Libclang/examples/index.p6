
use v6;
use lib 'lib';
use Libclang;
use Libclang::Raw;

my $index = Libclang::Index.new;
LEAVE $index.destroy if $index.defined;

my $file-name        = $*SPEC.catfile($*PROGRAM.IO.parent, "header.hpp");
my $translation-unit = Libclang::TranslationUnit.new($index, $file-name);
LEAVE $translation-unit.destroy if $translation-unit.defined;

my $cursor = $translation-unit.cursor;
LEAVE $cursor.destroy if $cursor.defined;

$cursor.visit-children(sub ($cursor, $parent) {
  printf("Cursor '%15s' of kind '%s'\n", $cursor.spelling,
    $cursor.kind-spelling);
  return child-visit-recurse;
})
