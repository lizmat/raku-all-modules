# Changelog for Libclang

## 0.3.0 - **UNRELEASED**
  - :tada: Add support for LLVM 6.0.

## 0.2.0 - 2018-11-3
  - :checkered_flag: Add experimental support for Windows.
  - :tada: Add more examples for indexing C functions and structures.
  - :tada: Add initial plumbing for cursor location and range.

## 0.1.0 - 2018-10-27
  - :construction_worker: Add Travis / AppVeyor CI scripts.
  - :rotating_light: Add more tests.
  - :art: Add object-oriented syntax sugar for `Libclang::Index`, `Libclang::TranslationUnit` and `Libclang::Cursor`.
  - :tada: First OO-sugar AST traversal example is now working.
  - :bug: Better libclang shared library path detection.
  - :hammer: Native stuff now live in `Libclang::Raw`.
  - :hammer: Switch to `clang` instead of `gcc` for compilation in `Build.pm`.

## 0.0.1 - 2018-10-26
  - :tada: :art: First AST traversal example is now working.
