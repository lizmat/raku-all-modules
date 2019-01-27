use v6;
use lib 'lib';
use Libclang;
use Libclang::Raw;

my $index = Libclang::Index.new;
LEAVE $index.destroy if $index.defined;

my $file-name        = "/usr/lib/llvm-3.8/include/clang-c/Index.h";
my $translation-unit = Libclang::TranslationUnit.new($index, $file-name);
LEAVE $translation-unit.destroy if $translation-unit.defined;

my $cursor = $translation-unit.cursor;
LEAVE $cursor.destroy if $cursor.defined;

my %funcs;
$cursor.visit-children(sub ($cursor, $parent) {
    my $name = $cursor.spelling;
    if $cursor.kind-spelling eq "FunctionDecl" && $name ne '' {
        %funcs{$name} = [];
    } else {
        my $parent-name = $parent.spelling;
        my $o           = %funcs{$parent-name};
        if $o.defined && $name ne '' {
            $o.push($cursor.kind-spelling ~ " " ~ $name);
        }
    }

    return child-visit-recurse;
});

constant $indent = " " x 4;
for %funcs.keys -> $func-name {
  my @params = @( %funcs{$func-name} );
  my @args;
  for @params -> $param {
      @args.push: $param;  
  }
  my $args = @args.join(', ');

  say "sub $func-name\($args) is native(LIB);";
}
