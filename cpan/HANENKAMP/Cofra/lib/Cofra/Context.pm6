use v6;

use Cofra::App::Godly;

unit role Cofra::Context does Cofra::App::Godly;

=begin pod

=head1 NAME

Cofra::Context - this tells you what is going on right now

=head1 DESCRIPTION

This is a magic flag to add to an object that tells you about the current state
of things. In web applications, this would be the thing that combines the
current request with the session.

I haven't really decided what it means in other kinds of applications, but I
imagine it might be something like mouse events, keyboard events, sensor events,
whatever. That's the context of what's important to the application in the
current moment, at whatever resolution makes sense for the given type of
application.

=end pod
