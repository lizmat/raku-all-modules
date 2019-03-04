use v6;

unit role Cofra::AppObject;

# TODO specify all the methods expected here
#
=begin pod

=head1 NAME

Cofra::AppObject - magic helper role for Cofra::App

=head1 DESCRIPTION

Circular dependencies in Perl 6 are frowned upon, that is to say, they don't
work, at all. This role exists purely to provide the magic mojo to allow a
circular dependency with L<Cofra::App> and some other modules.

=end pod
