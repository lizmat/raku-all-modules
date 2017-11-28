# https://github.com/zostay/p6-DOM-Tiny/issues/5

unit class Acme::Advent::Highlighter::HTMLParser;
use DOM::Tiny;

method parse (Str:D $html) { DOM::Tiny.parse: $html }
