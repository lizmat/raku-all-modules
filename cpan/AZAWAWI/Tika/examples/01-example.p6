#!/usr/bin/env perl6

use v6;
use lib ['lib', '../lib'];
use Tika;

my $t = Tika.new;
$t.start;

# Handle Ctrl-C
signal(SIGINT).tap: {
    $t.stop if $t.defined;
    exit;
}

#TODO find if server is up or not...
sleep 3;

say "Found {$t.version} server";
say $t.detectors;
say $t.parsers;
my @files = 'data/demo.docx', 'data/demo.pdf';
for @files -> $file {
    my $filename = $*SPEC.catfile($*PROGRAM.IO.parent, $file);
    my $content-type = $t.mime-type($filename);
    say "Detected stream type $content-type";

    my $metadata = $t.meta($filename, $content-type);
    say "Metadata for $filename:\n{$t._truncate($metadata, 40)}";

    my $text = $t.text($filename, $content-type);
    say "Found {$text.chars} plain text";

    my $language = $t.language($text);
    say "Detected language #{$language}";
}

LEAVE {
    $t.stop if $t.defined;
}
