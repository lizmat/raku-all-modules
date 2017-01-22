use v6;
use HTML::Tag::Tags;

unit class HTML::Tag::Exports;

sub tag($tag-name = 'p', *%opts) is export {
    HTML::Tag::{$tag-name}.new(|%opts);
}

=begin pod

=head1 NAME HTML::Tag::Exports

=head1 SYNOPSIS

    =begin code
    use HTML::Tag::Exports;

    say tag(text => 'I am a paragraph').render;
    # <p>I am a paragraph</p>

    say tag('span', :text('In a span zone'));
    # <span>In a span zone</span>
    =end code
    
=head1 DESCRIPTION

Use'ing HTML::Tag::Exports will place the "tag" key into your current
scope, and this tag will give you a shorthand for calling
C<HTML::Tag::<whatever>.new> -- in that you instead call
C<tag('whatever')> instead.

Options given after the tag name string, which must be the first
parameter, are passed along as-is to the HTML tag.

=head1 AUTHOR

Mark Rushing mark@orbislumen.net

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
