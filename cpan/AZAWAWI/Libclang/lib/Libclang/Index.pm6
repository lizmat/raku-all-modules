

use v6;

unit class Libclang::Index;

use Libclang::Raw;

has CXIndex $.index;

method new(
  Bool $exclude-declarations-from-pch = False,
  Bool $display-diagnostics           = False
) {
  my $index = clang_createIndex(
    $exclude-declarations-from-pch ?? 1 !! 0,
    $display-diagnostics           ?? 1 !! 0
  );
  die "Unable to create index" unless $index.defined;

  return self.bless( :$index )
}

multi method global-opts returns CXGlobalOptFlags {
  die "Index is undefined" unless $!index.defined;
  return CXGlobalOptFlags(clang_CXIndex_getGlobalOptions($!index));
}

multi method global-opts(CXGlobalOptFlags $options) {
  die "Index is undefined" unless $!index.defined;
  return clang_CXIndex_setGlobalOptions($!index, $options);
}

method destroy {
  die "Index is undefined" unless $!index.defined;
  clang_disposeIndex($!index);
}

#TODO CINDEX_LINKAGE void clang_CXIndex_setGlobalOptions(CXIndex, unsigned options);
