unit class Acme::Advent::Highlighter;

use Pastebin::Gist;
use Text::Markdown;
use Acme::Advent::Highlighter::HTMLParser;
use Acme::Advent::Highlighter::MultiMarkdown;
use UUID;
use WWW;

has Str:D $.token is required;
has Pastebin::Gist:D $!gist = Pastebin::Gist.new: :$!token;

method render (Str:D $c, :$wrap, :$multi) {
    my $content = $c.match( /^ 'http' 's'? '://'/ ) ?? do {
        DEBUG "Detected a URL as content… fetching data from $c";
        get $c
    } !! $c.IO ~~ :f & :r
        ?? do {
            DEBUG "Assuming content is a filename… slurping";
            $c.IO.slurp
        } !! $c;

    DEBUG 'Rendering Markdown';
    my $html = $multi
        ?? Acme::Advent::Highlighter::MultiMarkdown.render: $content
        !! Text::Markdown.new($content).render;

    DEBUG 'Finding code chunks in document';
    my $dom = Acme::Advent::Highlighter::HTMLParser.parse: $html;
    my %codes;
    for $dom.find('pre') {
        my $id = ~UUID.new;
        %codes{$id} = %(
            code => .all-text,
            dom  => $_
        );
        .attr: 'id', "advent-code-$id";
    }

    my $gist = $!gist.paste: :!public,
        %(%codes.map: { .key ~ ".p6" => %( content => .value<code> ) });
    DEBUG "Created gist with all the codes: $gist";
    DEBUG "Fetching and parsing the gist's markup";
    my $gist-dom = Acme::Advent::Highlighter::HTMLParser.parse: get $gist;
    for $gist-dom.find('.file') {
        DEBUG "Grabbing highlighted code for $_.attr("id")";
        my $code = .at: 'table.highlight';
        .remove for $code.at: '.js-line-number';
        %codes{
            .attr('id').substr: 'file-'.chars, * - '-p6'.chars
        }<dom>.content: ~$code
    }
    DEBUG "Deleting the gist";
    $!gist.delete: $gist;

    highlight $dom;
    $wrap ?? htmlify ~$dom !! ~$dom;
}

sub htmlify (Str:D $html) {
    q:to/END/;
    <!DOCTYPE html>
    <meta charset="utf-8">
    <style>
      body {
          background: #f3f3f3;
          color: #333;
      }
      #main-content {
          margin: 20px auto;
          width: 584px;
          font-size: 18px;
      }
      pre {
          width: 100%;
          box-sizing: border-box;
          overflow: auto;
          font-size: 16px;
      }
    </style>
    <div id="main-content">

        <!-- STUFF BELOW GOES INTO Wordpress -->

        \qq[$html]

        <!-- STUFF ABOVE GOES INTO Wordpress -->

    </div>
    END
}

sub highlight ($dom) {
    my %styles =
        '.pl-c' => 'color: #6a737d',
        '.pl-c1, .pl-s .pl-v' => 'color: #005cc5',
        '.pl-e, .pl-en' => 'color: #6f42c1',
        '.pl-smi, .pl-s .pl-s1' => 'color: #24292e',
        '.pl-ent' => 'color: #22863a',
        '.pl-k' => 'color: #d73a49',
        '.pl-s, .pl-pds, .pl-s .pl-pse .pl-s1, .pl-sr, .pl-sr .pl-cce,'
            ~ ' .pl-sr .pl-sre, .pl-sr .pl-sra' => 'color: #032f62',
        '.pl-v, .pl-smw' => 'color: #e36209',
        '.pl-bu' => 'color: #b31d28',
        '.pl-ii' => 'color: #fafbfc; background-color: #b31d28',
        '.pl-c2' => 'color: #fafbfc; background-color: #d73a49',
        '.pl-sr .pl-cce' => 'font-weight: bold; color: #22863a',
        '.pl-ml' => 'color: #735c0f',
        '.pl-mh, .pl-mh .pl-en, .pl-ms' => 'font-weight: bold; color: #005cc5',
        '.pl-mi' => 'font-style: italic; color: #24292e',
        '.pl-mb' => 'font-weight: bold; color: #24292e',
        '.pl-md' => 'color: #b31d28; background-color: #ffeef0',
        '.pl-mi1' => 'color: #22863a; background-color: #f0fff4',
        '.pl-mc' => 'color: #e36209; background-color: #ffebda',
        '.pl-mi2' => 'color: #f6f8fa; background-color: #005cc5',
        '.pl-mdr' => 'font-weight: bold; color: #6f42c1',
        '.pl-ba' => 'color: #586069',
        '.pl-sg' => 'color: #959da5',
        '.pl-corl' => 'text-decoration: underline; color: #032f62',

        'td' => 'border: 0; padding: 0; background: none',
        'tr, table' => 'background: none; padding: 0; margin: 0',
        'pre' => 'border: 1px dotted #ddd; background: none;'
            ~ ' border-radius: 3px; padding: 10px;',
    ;

    for %styles.sort -> (:key($selector), :value($style)) {
        DEBUG "Applying styling to selector $selector";
        .attr: 'style', $style for $dom.find: $selector
    }
}

sub DEBUG {
    $*ACME_ADVENT_HIGHLIGHTER_SILENCE_DEBUG or note $^text
}
