#! /usr/bin/env false

use v6.c;

use I18n::Simple;
use String::Fold;

unit module App::Assixt::Output;

my Bool $initialized = False;

sub err (
	Str:D $key,
	*%context,
) is export {
	init unless $initialized;

	i18n($key, |%context).&fold.note;
}

sub out (
	Str:D $key,
	*%context,
) is export {
	init unless $initialized;

	i18n($key, |%context).&fold.say;
}

sub init (
) {
	i18n-init(%?RESOURCES<i18n/en.yml>);

	$initialized = True;
}

=begin pod

=NAME    App::Assixt::Error
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 1.0.0

=head1 Synopsis

=head1 Description

=head1 Examples

=head1 See also

=end pod

# vim: ft=perl6 noet
