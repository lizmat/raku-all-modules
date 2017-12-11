#!/usr/bin/env perl6

unit module Net::Jupyter::Executer;

use v6;

use Net::Jupyter::Common;
use Net::Jupyter::EvalError;
use Net::Jupyter::ContextREPL;

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

      self!run-code;
      self!run-expressions
        unless %!error.defined;

   }

  method !run-code {
    my $out = $*OUT;
    my $capture ='';
    $*OUT = class { method print(*@args) {  $capture ~= @args.join; True }
                    method flush { True }}
    try {
      $!value = $!repl.eval($!code);
      CATCH {
        default {
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
