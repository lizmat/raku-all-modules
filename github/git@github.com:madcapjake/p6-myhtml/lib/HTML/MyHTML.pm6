unit module HTML::MyHTML;

use HTML::MyHTML::Raw;

use HTML::MyHTML::Encoding;
use HTML::MyHTML::Namespace;
use HTML::MyHTML::Tag;
use HTML::MyHTML::Tree;

class HTML::MyHTML is export {

  has $!raw;
  has HTML::MyHTML::Tree $.tree;

  submethod BUILD(:$threads = 1, :$queue-size = 4096) {
    $!raw = myhtml_create();
    myhtml_init($!raw, 0, $threads, $queue-size);
    $!tree .= new(myhtml => $!raw);
  }

  method clean {
    $!tree.clean;
    myhtml_clean($!raw);
  }
  method dispose {
    $!tree.dispose;
    myhtml_destroy($!raw);
  }

  multi method parse($html, :$enc) {
    myhtml_parse(
      $!tree.raw,
      $enc // Enc.default,
      $html.encode,
      $html.encode.bytes
    );
  }
  multi method parse($html, :$fragment, :$base, :$ns, :$enc) {
    myhtml_parse_fragment(
      $!tree,
      $enc // Enc.default,
      $html.encode,
      $html.encode.bytes,
      $base // Tag.default,
      $ns // Namespace.default
    );
  }
  multi method parse($html, :$single, :$enc) {
    myhtml_parse_single(
      $!tree,
      $enc // Enc.default,
      $html.encode,
      $html.encode.bytes
    );
  }
  multi method parse($html, :$fragment, :$single, :$base, :$ns, :$enc) {
    myhtml_parse_fragment_single(
      $!tree,
      $enc // Enc.default,
      $html.encode,
      $html.encode.bytes,
      $base // Tag.default,
      $ns // Namespace.default
    );
  }
  multi method parse($html, :$chunk) {
    myhtml_parse_chunk(
      $!tree,
      $html.encode,
      $html.encode.bytes
    );
  }
  multi method parse($html, :$chunk, :$fragment, :$base, :$ns, :$enc) {
    myhtml_parse_chunk_fragment(
      $!tree,
      $html.encode,
      $html.encode.bytes,
      $base // Tag.default,
      $ns // Namespace.default
    );
  }
  multi method parse($html, :$chunk, :$single) {
    myhtml_parse_chunk_single(
      $!tree,
      $html.encode,
      $html.encode.bytes
    );
  }
  multi method parse($html, :$chunk, :$single, :$base, :$ns) {
    myhtml_parse_chunk_fragment_single(
      $!tree,
      $html.encode,
      $html.encode.bytes,
      $base // Tag.default,
      $ns // Namespace.default
    );
  }
  method chunk-end { myhtml_parse_chunk_end($!tree.raw) }
}
