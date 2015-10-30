
use Pastebin::Shadowcat;

my $p = Pastebin::Shadowcat.new;

say "Pasting test content...";
my $paste_url = $p.paste('<pre>test paste1</pre>');
say "Paste is located at $paste_url";

say "Retrieiving paste content...";
my ( $content, $summary ) = $p.fetch($paste_url);
say "Summary: $summary";
say "Content: $content";
