use v6;
use Test;
use File::Compare;

plan 8;

ok files_are_equal("t/00-basic.t", "t/00-basic.t"), "basic equality";
ok files_are_different("t/00-basic.t", "lib/File/Compare.pm6"), "basic inequality";
nok files_are_different("t/00-basic.t", "t/00-basic.t"), "equality (are_different)";
nok files_are_equal("t/00-basic.t", "lib/File/Compare.pm6"), "inequality (are_equal)";

ok files_are_equal("t/00-basic.t", "t/00-basic.t", chunk_size => 1024), "chunk size (are_equal)";
ok files_are_different("t/00-basic.t", "lib/File/Compare.pm6", chunk_size => 2048), "chunk size (are_different)";
dies_ok { files_are_equal("t/00-basic.t", "t/00-basic.t", chunk_size => -23) }, "bad chunk size";

dies_ok {say files_are_equal("t/doesn't exist", "lib/File/Compare.pm6") }, "nonexistent files";
