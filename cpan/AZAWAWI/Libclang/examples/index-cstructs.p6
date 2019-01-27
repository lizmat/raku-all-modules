
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

my %structs;
$cursor.visit-children(sub ($cursor, $parent) {
    my $name = $cursor.spelling;
    if $cursor.kind-spelling eq "StructDecl" && $name ne '' {
        %structs{$name} = [];
    } else {
        my $parent-name = $parent.spelling;
        my $o           = %structs{$parent-name};
        if $o.defined && $name ne '' {
            $o.push($name);
        }
    }

    return child-visit-recurse;
});

constant $indent = " " x 4;
for %structs.keys -> $key {
    say "class $key is repr('CStruct') \{";
    my @fields = @( %structs{$key} );
    for @fields -> $field {
        say $indent ~ "has \$.$field;";  
    }
    say "}";
}
