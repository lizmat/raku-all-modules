use v6;

unit module Sparky::Plugin::Hello;

our sub run ( %ctx, %parameters ) {

  say "hello " ~ %parameters<name>;
  say "project: " ~ ( %ctx<project> );
  say "build-state: " ~ ( %ctx<build-state> );
}


