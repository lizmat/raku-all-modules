unit grammar CoreHackers::Q::Parser;
use CoreHackers::Q::Parser::Actions;

method view (Str:D $code, Str:D $source) {
    self.parse($source, :actions(
        CoreHackers::Q::Parser::Actions.new: :$code
    )).made;
}

token TOP      { :my $*indent = 0; <node>+ }
token node     {
    <node-text> [\n {$*indent++} <children> {$*indent--}]?
}
token children {
    :my $*qast-want-v = 0;
    ['  '**{$*indent} <node>]*
}

proto token node-text {*}
token node-text:sym<qast>   { '- QAST::' <name=ident> {} $<rest>=\N+ }
token node-text:sym<want-v> { '- ' < v Ii > { $*qast-want-v = 1 } }
token node-text:sym<misc>   { {} \N+ }
