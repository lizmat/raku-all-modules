#!/usr/bin/env perl6

unit module Net::Jupyter::Executer;

use v6;

use Net::Jupyter::Common;
use Net::Jupyter::EvalError;
use Net::Jupyter::ContextREPL;
use Net::Jupyter::Magic;

class X::Jupyter::Timeout is Exception {
  has Str $.message = 'Operation timed out';
  method is-compile-time { False }
}


sub run-with-timeout(&start,  Int :$timeout where {$timeout >= 0 } = 0 ) is export {

  #$*so.print( "TIMEOUT: $timeout \n");
  my $p = Promise.start( &start );
  my $r =  $p;
  $r = Promise.anyof($p,
                    Promise.in($timeout)\
                        .then({ #$*so.print("KILLING\n");
                                $p.kill;
                                sleep 2;
                                $p.kill(9) }))
    if $timeout > 0;
  await $r;

  X::Jupyter::Timeout.new.throw
    if $p.status ~~ 'Planned';

  $p.result;
}


class Executer is export {

  #class
  my int $counter = 0;

  has Str $.code is required;

  #optional
  has Bool $.silent = False;
  has Bool $.store-history = True;
  has %.user-expressions;

  # DO NOT initialize
  has $!value;
  has Str $.out;

  has Str $.err;
  has %.error;
  has $.traceback;
  has Bool $.dependencies-met = True;

  has @.payload;
  has %.metadata;

  has $!repl;
  has Magic $magic;

  method count { return $counter }
  method value {stringify($!value) }
  method reset { $counter = 0; $!repl.reset }

  method TWEAK {
      die "Executer called without code! { $!code.perl }" without $!code;
      ++$counter;
      $!repl = ContextREPL.get-repl;
      %!user-expressions = Hash.new unless %!user-expressions.defined;
      @!payload = [] unless @!payload.defined;
      %!metadata = Hash.new unless %!metadata.defined;
      $magic = Magic.parse( $!code );
      $!code = $magic.perl-code;

      self!run-code;

      self!run-expressions
        unless %!error.defined;


   }

  method !run-code {

    my $out = $*OUT;
    my $*so = $*OUT;
    my $capture ='';

    $*OUT = class { method print(*@args) {  $capture ~= @args.join; True }
                    method flush { True }}
    try {
       my $timeout = $magic.timeout // 0;
       $!value =  run-with-timeout( { $!repl.eval($!code)  }, :$timeout );

      CATCH {
        default { #$out.print( $_.perl);
          my $error = EvalError.new( :exception( $_));
          %!error =  $error.extract;
          $!err = $error.format(:short);
          $!traceback = %!error< traceback >;
          $!value = Nil;
          $!dependencies-met = ! so %!error<  dependencies-error >;
        }
      }
    }
    $*OUT = $out;
    $!out = $capture;
  }

  method !run-expressions {
    return unless %!user-expressions;
    for %!user-expressions.kv -> $name, $expr {
      try {
        my $value = $!repl.eval($expr, :null-context);
        %!user-expressions{ $name }  = $value;
        CATCH {
          default {
            my $err = EvalError.new( :exception( $_));
            my %error = $err.extract;
            %!user-expressions{ $name }  = %error< status evalue>;}}}}}

}#executer
