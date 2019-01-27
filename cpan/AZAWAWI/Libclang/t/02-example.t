use v6;
use Test;

plan 2;

use Libclang;
use Libclang::Raw;

my $index = Libclang::Index.new;
LEAVE $index.destroy if $index.defined;

is $index.global-opts, CXGlobalOpt_None, "initial global-opts getter works";
my $new-value = CXGlobalOpt_ThreadBackgroundPriorityForAll;
$index.global-opts($new-value);
is $index.global-opts, $new-value, "global-opts setter/getter work";

my $file-name        = $*SPEC.catfile($*PROGRAM.IO.parent, "files", "header.hpp");
my $translation-unit = Libclang::TranslationUnit.new($index, $file-name);
LEAVE $translation-unit.destroy if $translation-unit.defined;

my $cursor = $translation-unit.cursor;
LEAVE $cursor.destroy if $cursor.defined;

$cursor.visit-children(sub ($cursor) {
  printf("Cursor '%15s' of kind '%s'\n", $cursor.spelling,
    $cursor.kind-spelling);
  return child-visit-recurse;
});
