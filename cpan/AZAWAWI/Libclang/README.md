# Libclang

 [![Build Status](https://travis-ci.org/azawawi/p6-libclang.svg?branch=master)](https://travis-ci.org/azawawi/p6-libclang) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/p6-libclang?svg=true)](https://ci.appveyor.com/project/azawawi/p6-libclang/branch/master)

Perl 6 bindings for [`libclang`](https://clang.llvm.org/doxygen/group__CINDEX.html)

**Note: This is currently experimental and API may change. Please DO NOT use in
a production environment.**

## Example

```perl6
use v6;
use Libclang;

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
});
```
## Dependencies

Please follow the instructions below based on your platform to install `libclang` development libraries / headers:

|Platform|Installation command|
|-|-|
|Debian|`apt-get install libclang-dev`|
|macOS|`brew update;`<br>`brew install llvm --with-clang`|
|Windows|Install [mingw-w64-install.exe](https://sourceforge.net/projects/mingw-w64/files).<br>Install [Clang for Windows 64-bit](http://releases.llvm.org/download.html).|

## Installation

- Install this module using [zef](https://github.com/ugexe/zef):

```
$ zef install Libclang
```

## Testing

- To run tests:
```
$ AUTHOR_TESTING=1 zef test --verbose .
```

- To run all tests including author tests (Please make sure
[Test::Meta](https://github.com/jonathanstowe/Test-META) is installed):
```
$ zef install Test::META
$ AUTHOR_TESTING=1 prove -e "perl6 -Ilib"
```

## See Also
- https://gist.githubusercontent.com/raphaelmor/3150866/raw/4f722b922ae19c9d6c328d79d5a5ca8cb018fb77/clanglib.c
- https://shaharmike.com/cpp/libclang/
- http://bastian.rieck.ru/blog/posts/2015/baby_steps_libclang_ast/

## Author

Ahmad M. Zawawi, [azawawi](https://github.com/azawawi/) on #perl6.

## License

[MIT License](LICENSE)
