use v6;

unit class X::Cofra::Error is Exception;

has $cause;

method message(--> Str:D) { $cause // 'unknown cause' }

=begin pod

=head1 NAME

X::Cofra::Error - the mother of all errors in Cofra

=head1 DESCRIPTION

This is the exception all other Cofra exceptions inherit from.

=end pod
