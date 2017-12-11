#!/usr/bin/env perl6

unit module Net::Jupyter::ContextREPL;

use v6;
use nqp;

%*ENV<RAKUDO_LINE_EDITOR> = 'none';

class ContextREPL {...}

my ContextREPL $repl;

my constant NAMELESS =  '__NAMELESS__';

# use get-repl instead of new
class ContextREPL is REPL is export {
  has %!ctxs = Hash.new;

  method get-repl(::?CLASS:U:) {
    return $repl if $repl.defined;

    $repl .= new(nqp::getcomp('perl6'), {});

    # HACK: ignore global setting
    $repl.^attributes.first('$!multi-line-enabled').set_value($repl,False);

    return $repl;
  }

  method reset(Str $key  = NAMELESS ) {
    %!ctxs{ $key }:delete;
  }

  multi method eval($code, :$no-context! ) {
      return self.eval($code, Nil, False );
  }

  multi method eval($code, $key = NAMELESS, $keep-context=True ) {

    my $*CTXSAVE := self;
    my $*MAIN_CTX;
    my Exception $ex;
    my $value = Nil;
    my $ctx;

    $ctx := ( $keep-context && (%!ctxs{ $key }:exists) )
                  ?? %!ctxs{ $key }
                  !! nqp::null();

    $value = self.repl-eval($code, $ex , :outer_ctx($ctx));

    $ex.throw if $ex.defined;
    $value.Str if $value.isa(Rat);  ## catch div by zero

    %!ctxs{ $key } := $*MAIN_CTX
      if ( $keep-context && $*MAIN_CTX );

    return $value;
  }
}#ContextREPL
