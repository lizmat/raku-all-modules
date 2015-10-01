
use Pastebin::Shadowcat;

say "Pasting test content...";
my $paste_url = paste('<pre>test paste1</pre>');
say "Paste is located at $paste_url";

say "Retrieiving paste content...";
my ( $content, $summary ) = get_paste($paste_url);
say "Summary: $summary";
say "Content: $content";