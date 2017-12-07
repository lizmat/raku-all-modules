use v6;
use Test;
plan 1;
use Sparky::Plugin::Notify::Email;
Sparky::Plugin::Notify::Email::run %( 
    project       => "Animals",
    build-state   => "success"
  ), 
  %( to => "email.me", offline => True );

ok 1, "it's ok so far";

