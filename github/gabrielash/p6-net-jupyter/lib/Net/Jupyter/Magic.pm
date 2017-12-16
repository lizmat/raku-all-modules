unit module Net::Jupyter::Magic;

use v6;

class X::Jupyter::MalformedMagic is Exception {
  has Str $.message = 'malformed magic declaration';
  method is-compile-time { True }
}


role ActionParser[::Actions, ::Grammar ] {

  has $._g is rw;
  has $._match is rw;
  has $._target is rw;

  method parse(::Actions: Str $str) {
    my Actions $ga .= new;
    $ga._g = Grammar.new;
    $ga._target = $str;
    $ga._match = Grammar.parse($str, actions => $ga);
    return $ga;
  }
}

grammar MagicGrammar {...}
class Magic {...}

class Magic is export does ActionParser[Magic, MagicGrammar ] {

  has Str $.perl-code;
  has Int $.timeout;

  method TOP($/)     { make $!perl-code }
  method code($/)    { $!perl-code = $/.Str }

  method declaration:sym<timeout>($/) {
    $!timeout = $<timeout>.Int;
  }

}#Magic

grammar MagicGrammar {
  token TOP {
    :my $*lineno = 1;
    <magic>* <code>
  }
  token ws  { <!ww> \h* }

  token code { .* }

  rule magic  { <.ws> '%%' ~ '%%' [ <declaration> ] <.eol>  }

  proto token declaration { * }

    rule declaration:sym<timeout>  {
        <sym> [ <timeout=.number> || <.malformed> ]
    }

  token identifier    {  <:alpha> \w+ }
  token eol           { <.n>+ }
  token n             { \n \s* { ++$*lineno } }  #*
  token number        { \d+ }
  token malformed     {
                        .*
                        { --$*lineno; self.error('bad declration') }}

  method FAILGOAL($t) {
    self.error("failed to close $t" );
  }

  method error(Str $message is copy) {
    my $from = self.target.substr(0, self.pos).rindex("\n") || 0;
    ++$from if $from > 0;
    my $to   = self.target.index("\n", self.pos) || self.target.elems - 1;
    my $pre  = self.target.substr($from, self.pos - $from );
    my $post  = self.target.substr(self.pos, $to - self.pos );
    $message = "bad declaration "
      if $message.starts-with('failed to close') && $post.index('%%').defined;

    X::Jupyter::MalformedMagic.new(message =>
         'Malformed Magic: ' ~ $message ~ " at line $*lineno pos {self.pos} \n\t\t-->"
          ~ $pre ~ '***' ~ $post ~ '<--'
    ).throw;
  }

}#Grammar
