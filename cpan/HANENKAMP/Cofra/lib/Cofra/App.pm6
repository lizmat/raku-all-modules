use v6;

use Cofra::AppObject;

unit class Cofra::App does Cofra::AppObject;

use Cofra::AccessController;
use Cofra::Biz;
use Cofra::Logger;

# TODO access-controller should be required
has Cofra::AccessController $.access-controller;

has Cofra::Logger $.logger is required;

has Cofra::Biz %.bizzes;

method biz(Str:D $name --> Cofra::Biz:D) {
    %!bizzes{ $name } // die "no biz named $name";
}

=begin pod

=head1 NAME

Cofra::App - the God-object for all applications

=head1 SYNOPSIS

    use Cofra::App;

    unit class MyApp is Cofra::App;

    has $.stuff;

=head1 DESCRIPTION

Applications typically have a global singleton that has links off to all that
random stuff. This is that object and it will help you create that giant object
computer science purists will tell you never to have, but applications always
have anyway.

=end pod
