use v6;
unit class HTML::Escape;

sub escape-html(Str $raw) returns Str is export {
    return $raw.trans([
        '&',
        '<',
        '>',
        q{"},
        q{'},

        # For IE. IE interprets back-quote as valid quoting characters
        # ref: https://rt.cpan.org/Public/Bug/Display.html?id=84971
        q{`},

        # For javascript templates (e.g. AngularJS and such javascript frameworks)
        # ref: https://github.com/angular/angular.js/issues/5601
        '{',
        '}'
    ] => [
        '&amp;',
        '&lt;',
        '&gt;',
        '&quot;',
        '&#39;',
        '&#96;',
        '&#123;',
        '&#125;'
    ]);
}

=begin pod

=head1 NAME

HTML::Escape - Utility of HTML escaping

=head1 SYNOPSIS

    use HTML::Escape;

    escape-html("<^o^>"); # => '&lt;^o^&gt;'

=head1 DESCRIPTION

HTML::Escape provides a function which escapes HTML's special characters. It
performs a similar function to PHP's htmlspecialchars.

This module is perl6 port of L<HTML::Escape of perl5|https://metacpan.org/pod/HTML::Escape>.

=head1 Functions

=head2 C<escape-html(Str $raw-str) returns Str>

Escapes HTML's special characters in given string.

=head1 TODO

=item Support unescaping function?

=head1 SEE ALSO

L<HTML::Escape of perl5|https://metacpan.org/pod/HTML::Escape>

=head1 COPYRIGHT AND LICENSE

    Copyright 2017- moznion <moznion@gmail.com>

    This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

And original perl5's HTML::Escape is

    This software is copyright (c) 2012 by Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF@ GMAIL COME<gt>.

    This is free software; you can redistribute it and/or modify it under
    the same terms as the Perl 5 programming language system itself.

=end pod

