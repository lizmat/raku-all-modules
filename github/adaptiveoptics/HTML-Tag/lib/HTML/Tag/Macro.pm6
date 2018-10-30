use v6;
use HTML::Tag;
use HTML::Tag::Tags;

class HTML::Tag::Macro::CSS is HTML::Tag::link
{
    method do-assignments() {
	callsame;
	$.attr<rel>  = $.rel  || 'stylesheet';
	$.attr<type> = $.type || 'text/css';
    }
}


=begin pod

=head1 NAME HTML::Tag::Macro

=head1 SYNOPSIS

=head2 CSS
    =begin code
    use HTML::Tag::Macro::CSS;
    my $css = HTML::Tag::Macro::CSS.new(:href('css/file.css'));

    # <link rel="stylesheet" href="css/file.css" type="text/css">
    =end code

=head1 DETAIL

Macros are created and rendered tags but offer some automation.

=head2 CSS

Creates a ::link tag for CSS files

HTML::Tag::Macro::CSS accepts the same options as the ::link tag, but
additionally :rel (defaulting to "stylesheet") and :type (defaulting
to "text/css".

=head2 other macros

See the macro subdirectory

=head1 AUTHOR

Mark Rushing mark@orbislumen.net

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod

