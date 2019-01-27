
#include <stdlib.h>
#include <assert.h>
#include <clang-c/Index.h>

// We need to wrap it since Perl 6's NativeCall does not pass CStruct by value
extern CXCursor* wrapped_clang_getTranslationUnitCursor(CXTranslationUnit unit) {
  CXCursor cursor  = clang_getTranslationUnitCursor(unit);
  CXCursor* result = (CXCursor*)malloc(sizeof(CXCursor));
  *result          = cursor;
  return result;
}

extern void wrapped_free(void *pointer) {
  assert(pointer != NULL);
  free(pointer);
}

extern CXString wrapped_clang_getCursorSpelling(CXCursor *cursor) {
  return clang_getCursorSpelling(*cursor);
}

typedef unsigned int (*VisitorCallback)(CXCursor *cursor, CXCursor *parent);

unsigned cursorVisitor(
  CXCursor cursor,
  CXCursor parent,
  CXClientData client_data) {

  VisitorCallback visitor = (VisitorCallback)client_data;
  return visitor(&cursor, &parent);
}

extern unsigned wrapped_clang_visitChildren(
  CXCursor *parent,
  VisitorCallback visitorCallback,
  CXClientData client_data
) {
  return clang_visitChildren(*parent, &cursorVisitor, visitorCallback);
}

extern enum CXCursorKind wrapped_clang_getCursorKind(CXCursor* cursor) {
  return clang_getCursorKind(*cursor);
}

CINDEX_LINKAGE CXSourceLocation* wrapped_clang_getCursorLocation(CXCursor* cursor) {
  CXSourceLocation sourceLocation = clang_getCursorLocation(*cursor);
  CXSourceLocation* result        = (CXSourceLocation*)malloc(
    sizeof(CXSourceLocation)
  );
  *result = sourceLocation;
  return result;
}

CINDEX_LINKAGE CXSourceRange* wrapped_clang_getCursorExtent(CXCursor* cursor) {
  CXSourceRange extent  = clang_getCursorExtent(*cursor);
  CXSourceRange* result = (CXSourceRange*)malloc(sizeof(CXSourceRange));
  *result               = extent;
  return result;
}
