#!/usr/bin/env perl6
use lib 'lib';
use Font::QueryInfo;
sub MAIN (Str:D $folder = '.') {
    query-folder($folder.IO);
}
sub query-folder (IO::Path:D $folder) {
    say $_ => font-query-all($_) for dir($folder).grep(/:i '.' [otf|ttf] $ /);
    dir($folder).grep(*.d)».&query-folder;
}