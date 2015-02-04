use v6;
use XML::Parser::Tiny;
use DateTime::Format::W3CDTF;
use LWP::Simple;
use URI;

class Sitemap::XML::Parser;

has $!parser = XML::Parser::Tiny.new;
has $!w3cdtf = DateTime::Format::W3CDTF.new;
has $.lwp = LWP::Simple.new;

method parse-url ( Str $url ) {
    my $data = $.lwp.get($url).decode('UTF-8');
    return self.parse($data);
}

method parse-file ( Str $fname ) {
    my $data = slurp($fname);
    return self.parse($data);
}

method parse ( Str $data ) {
    my $xml = $!parser.parse($data);
    die "Tag 'urlset' is missing" unless $xml{'body'}{'name'} eq 'urlset';

    my @urls;
    for @( $xml{'body'}{'data'} ) -> %url {
        die "Unexpected tag '" ~ %url{'name'} ~ "' found" unless %url{'name'} eq 'url';

        my %info;
        for @( %url{'data'} ) -> %item {
            unless %item{'name'} eq [|] qw/loc lastmod changefreq priority/ {
                die "Unexpected tag '" ~ %item{'name'} ~ "' found";
            }
            unless @( %item{'data'} ) == 1 && %item{'data'}[0].isa('Str') {
                die "Invalid tag value for '" ~ %item{'name'} ~ "'";
            }
            %info{ %item{'name'} } = %item{'data'}[0];
        }

        %info = self!check-loc(%info);
        %info = self!check-lastmod(%info);
        %info = self!check-changefreq(%info);
        %info = self!check-priority(%info);

        @urls.push( $(%info) );
    }
    return @urls;
}

method !check-loc ( %info is copy ) {
    unless any(%info.keys) eq 'loc' && %info{'loc'} ne '' {
        die "Tag 'loc' is missing";
    }

    %info{'loc'} = URI.new(%info{'loc'}, is_validating => True);
    return %info;
}

method !check-lastmod ( %info is copy ) {
    return %info unless any(%info.keys) eq 'lastmod';

    %info{'lastmod'} = $!w3cdtf.parse: %info{'lastmod'};
    return %info;
}

method !check-changefreq ( %info ) {
    return %info unless any(%info.keys) eq 'changefreq';

    unless %info{'changefreq'} eq [|] qw/always hourly daily weekly monthly yearly never/ {
        die "Invalid tag value '" ~ %info{'changefreq'} ~ "' for 'changefreq'"
    }
    return %info;
}

method !check-priority ( %info is copy ) {
    return %info unless any(%info.keys) eq 'priority';

    my $value = %info{'priority'}.Real;
    unless $value ~~ 0.0..1.0 {
        die "Invalid tag value '" ~ %info{'priority'} ~ "' for 'priority'"
    }
    %info{'priority'} = $value;
    return %info;
}

=begin pod

=head1 NAME

Sitemap::XML::Parser is a module for parsing sitemap.xml files.

=head1 SYNOPSYS

=begin code
use Sitemap::XML::Parser;

my $parser = Sitemap::XML::Parser.new;
my $sitemap = $parser.parse-url('http://example.ru/sitemap.xml');
# $sitemap == [
#    {
#        loc => URI.new('http://example/'),
#        lastmod => DateTime.new('2012-09-06T03:22:42Z'),
#        changefreq => 'daily',
#        priority => 1.0
#    },
#    ....
# ];

=end code

=head1 DESCRIPTION

Module for parsing sitemap.xml files.

=head1 METHODS

=head2 parse-url( Str $url )
=head2 parse-file( Str $fname )
=head2 parse( Str $data )

=head1 AUTHOR

Alexandr Alexeev, <eax at cpan.org> (L<http://eax.me/>)

=head1 COPYRIGHT

Copyright 2012 Alexandr Alexeev

This program is free software; you can redistribute it and/or modify it
under the same terms as Rakudo Perl 6 itself.

=end pod

