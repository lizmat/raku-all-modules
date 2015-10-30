#!/usr/bin/env perl6

use lib 'lib';
use Pastebin::Gist;

my $p = Pastebin::Gist.new;

say "Pasting test content...";
my $paste_url = $p.paste(
    {
        foo => { content => "<pre>test paste1</pre>" },
        bar => { content => "meow!" }
    },
    desc => "Foo Bar"
);
say "Paste is located at $paste_url";

say "Retrieiving paste content...";
my ( $files, $summary ) = $p.fetch( $paste_url );
say "Summary: $summary";
for $files.keys {
    say "File: $_\nContent:\n$files{$_}";
}
# say "Content: $content";
