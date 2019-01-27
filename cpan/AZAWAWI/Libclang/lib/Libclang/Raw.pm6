
use v6;

unit module Libclang::Raw;

use NativeCall;

sub libclang {
  # Windows
  return "C:/Program Files/LLVM/bin/libclang.dll" if $*DISTRO.is-win;

  # macOS
  return 'libclang.dynlib' if $*DISTRO.name eq 'darwin';

  # Linux / Unix
  my @libs = (
    # Debian et al
    '/usr/lib/llvm-6.0/lib/libclang.so',
    '/usr/lib/llvm-3.4/lib/libclang.so',
    '/usr/lib/llvm-3.8/lib/libclang.so'
  );
  
  for @libs -> $lib {
    return $lib if $lib.IO ~~ :f;
  }

  # Fallback
  return '/usr/lib/libclang.so';
}

sub libclang-perl6 {
  my $lib-name = sprintf($*VM.config<dll>, "clang-perl6");
  return ~(%?RESOURCES{$lib-name});    
}

class CXIndex is repr('CPointer') is export { }
class CXTranslationUnit is repr('CPointer') is export { }
class CXClientData is repr('CPointer') is export { }

# CINDEX_LINKAGE CXString clang_getClangVersion(void);
sub clang_getClangVersion is native(&libclang) is export returns Str { * }

# CINDEX_LINKAGE CXIndex clang_createIndex(int excludeDeclarationsFromPCH,
#                                          int displayDiagnostics);
sub clang_createIndex(
  int32 $excludeDeclarationsFromPCH,
  int32 $displayDiagnostics
) is native(&libclang)
  is export
  returns CXIndex
  { * }

# CINDEX_LINKAGE void clang_disposeIndex(CXIndex index);
sub clang_disposeIndex(
  CXIndex $index
) is native(&libclang)
  is export
  { * }

enum CXGlobalOptFlags is export (
  CXGlobalOpt_None                                => 0x0,
  CXGlobalOpt_ThreadBackgroundPriorityForIndexing => 0x1,
  CXGlobalOpt_ThreadBackgroundPriorityForEditing  => 0x2,
  CXGlobalOpt_ThreadBackgroundPriorityForAll      => 0x1 +| 0x2
);

# CINDEX_LINKAGE void clang_CXIndex_setGlobalOptions(CXIndex, unsigned options);
sub clang_CXIndex_setGlobalOptions(
  CXIndex $index,
  uint32  $options
) is native(&libclang)
  is export
  { * }

# CINDEX_LINKAGE unsigned clang_CXIndex_getGlobalOptions(CXIndex);
sub clang_CXIndex_getGlobalOptions(
  CXIndex $index
) returns uint32
  is native(&libclang)
  is export
  { * };

# CINDEX_LINKAGE void clang_disposeTranslationUnit(CXTranslationUnit);
sub clang_disposeTranslationUnit(
  CXTranslationUnit $unit
) is native(&libclang)
  is export
  { * }

enum CXTranslationUnit_Flags  is export (
  CXTranslationUnit_None                                 => 0x0,
  CXTranslationUnit_DetailedPreprocessingRecord          => 0x01,
  CXTranslationUnit_Incomplete                           => 0x02,
  CXTranslationUnit_PrecompiledPreamble                  => 0x04,
  CXTranslationUnit_CacheCompletionResults               => 0x08,
  CXTranslationUnit_ForSerialization                     => 0x10,
  CXTranslationUnit_CXXChainedPCH                        => 0x20,
  CXTranslationUnit_SkipFunctionBodies                   => 0x40,
  CXTranslationUnit_IncludeBriefCommentsInCodeCompletion => 0x80,
  CXTranslationUnit_CreatePreambleOnFirstParse           => 0x100
);

# CINDEX_LINKAGE CXTranslationUnit
# clang_parseTranslationUnit(CXIndex CIdx,
#                            const char *source_filename,
#                            const char *const *command_line_args,
#                            int num_command_line_args,
#                            struct CXUnsavedFile *unsaved_files,
#                            unsigned num_unsaved_files,
#                            unsigned options);
sub clang_parseTranslationUnit(
  CXIndex $CIdx,
  Str $source_filename,
  Pointer $command_line_args,
  int32 $num_command_line_args,
  Pointer $unsaved_files,
  uint32 $num_unsaved_files,
  uint32 $options
) is native(&libclang)
  returns CXTranslationUnit
  is export
  { * };

class CXCursor is repr('CStruct') is export {
  # TODO enum CXCursorKind kind;
  has uint32 $.kind,
  has int32 $.xdata;
  # TODO const void *data[3];
  # Workaround to inability to create static native arrays
  has Pointer $.data1;
  has Pointer $.data2;
  has Pointer $.data3;
}

# CINDEX_LINKAGE CXCursor clang_getTranslationUnitCursor(CXTranslationUnit);
# sub clang_getTranslationUnitCursor(
#   CXTranslationUnit $unit
# ) is native(&libclang)
#   returns CXCursor
#   { * };
sub clang_getTranslationUnitCursor(
  CXTranslationUnit $unit
) is native(&libclang-perl6)
  is symbol('wrapped_clang_getTranslationUnitCursor')
  is export
  returns Pointer[CXCursor]
  { * };

sub free(Pointer $pointer)
  is native(&libclang-perl6)
  is symbol('wrapped_free')
  is export
  { * };

enum CXChildVisitResult  is export <
  CXChildVisit_Break
  CXChildVisit_Continue
  CXChildVisit_Recurse
>;

# typedef enum CXChildVisitResult (*CXCursorVisitor)(CXCursor cursor,
#                                                    CXCursor parent,
#                                                    CXClientData client_data);

# CINDEX_LINKAGE unsigned clang_visitChildren(CXCursor parent,
#                                             CXCursorVisitor visitor,
#                                             CXClientData client_data);
sub clang_visitChildren(
  Pointer[CXCursor] $parent,
  #TODO CXChildVisitResult return result
  &visitor (Pointer[CXCursor], Pointer[CXCursor] --> uint32)
) is native(&libclang-perl6)
  is symbol('wrapped_clang_visitChildren')
  is export
  returns uint32
  { * };
  
# CINDEX_LINKAGE CXString clang_getCursorSpelling(CXCursor);
#sub clang_getCursorSpelling(CXCursor $cursor)
sub clang_getCursorSpelling(Pointer[CXCursor] $cursor)
  is native(&libclang-perl6)
  is symbol('wrapped_clang_getCursorSpelling')
  is export
  returns Str
  { * }

# CINDEX_LINKAGE enum CXCursorKind clang_getCursorKind(CXCursor);
sub clang_getCursorKind(Pointer[CXCursor] $cursor)
  is native(&libclang-perl6)
  is symbol('wrapped_clang_getCursorKind')
  is export
  # TODO CXCursorKind
  returns uint32
  { * }

# CINDEX_LINKAGE CXString clang_getCursorKindSpelling(enum CXCursorKind Kind);
sub clang_getCursorKindSpelling(uint32 $kind)
  is native(&libclang)
  is export
  returns Str
  { * }

class CXSourceLocation is repr('CStruct') is export {
  has Pointer $.ptr_data1;
  has Pointer $.ptr_data2;
  has uint32  $.int_data;
}

class CXSourceRange is repr('CStruct') is export {
  has Pointer $.ptr_data1;
  has Pointer $.ptr_data2;
  has uint32  $.begin_int_data;
  has uint32  $.end_int_data;
}

# CINDEX_LINKAGE CXSourceLocation clang_getCursorLocation(CXCursor);
sub clang_getCursorLocation(Pointer[CXCursor])
  is native(&libclang-perl6)
  is symbol('wrapped_clang_getCursorLocation')
  returns Pointer[CXSourceLocation]
  is export
  { * }

# CINDEX_LINKAGE CXSourceRange clang_getCursorExtent(CXCursor);
sub clang_getCursorExtent(uint32 $kind)
  is native(&libclang-perl6)
  is symbol('wrapped_clang_getCursorExtent')
  returns Pointer[CXSourceRange]
  is export
  { * }
