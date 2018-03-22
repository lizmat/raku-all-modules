use v6.c;
use Test;
plan 4;
use Test::SourceFiles;

given collect-sources.head {
  is .key, 'Test::SourceFiles', "Collect returned a module name.";
  is .value.f, True, "Collect returned a real file.";
}

# Note one additional test will be run here so our plan needs to be one test higher.
is use-libs-ok, 1, "Tested expected number of source files.";
