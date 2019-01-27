=begin pod

=begin code
perl6 --doc=HTML2 input.pm6 > output.html
=end code

Trying to process this file itself results in the following:
$ perl6 --doc=Markdown lib/Pod/To/Markdown.pm6
=begin code
===SORRY!===
 P6M Merging GLOBAL symbols failed: duplicate definition of symbol Markdown
=end code
Here is a hack to generate README.md from this Pod:
=begin code
perl6 lib/Pod/To/Markdown.pm6 > README.md
=end code

=end pod

unit class Pod::To::HTML2;
use PodCache::Processed;

method render( $pod-tree ) is export {
    say "At $?LINE tree is ", $pod-tree.perl;
    #my PodCache::Processed $p .= new(:name(&?ROUTINE.name), :$pod-tree, :verbose, :!debug);
    #$p.source-wrap
}
