use Software::License::Apache_2_0;
use Software::License::Artistic_2_0;
use Software::License::BSD;
use Software::License::FreeBSD;
use Software::License::GPL3;
use Software::License::MIT;

class Software::License:ver<0.02>
{
    method full-text (Str:D $license_name, Str:D $holder, Int:D $year=DateTime.new(time).year)
    {
        my $license;

        given $license_name
        {
            when 'Apache2'
            {
                $license = Software::License::Apache_2_0.new;
            }
            when 'Artistic2'
            {
                $license = Software::License::Artistic_2_0.new;
            }
            when 'BSD'
            {
                $license = Software::License::BSD.new;
            }
            when 'FreeBSD'
            {
                $license = Software::License::FreeBSD.new;
            }
            when 'GPL3'
            {
                $license = Software::License::GPL3.new;
            }
            when 'MIT'
            {
                $license = Software::License::MIT.new;
            }
            default
            {
                die "$license_name is not a recognized license. Try: Apache2, Artistic2, BSD, FreeBSD, GPL3 or MIT";
            }
        }
        return join "\n\n", preamble($holder, $year), '    ' ~ $license.long_name, $license.full_text($holder, $year);
    }

    sub preamble (Str:D $holder, Int:D $year)
    {
        return "This software is Copyright (c) $year by $holder.\n\nThis is free software, licensed under:";
    }
}

=begin pod

=head1 NAME

Software::License - a Perl 6 module for creating free software licenses.

=head2 SYNOPSIS

    use Software::License;

    my $license = Software::License.new;
    my $freebsd_text_2014 = $license.full-text('FreeBSD', 'David Farrell'); # defaults to current year
    my $mit_text_2009 = $license.full-text('FreeBSD', 'David Farrell', 2009); # can provide year as an arg

=head2 DESCRIPTION

Software::License is a Perl 6 module for minting free software license texts. The module recognizes the following licenses:

=item Apache2 - the Apache 2.0 license

=item Artistic2 - the Artistic 2.0 license

=item BSD - the BSD license

=item FreeBSD - the two clause BSD license

=item GPL3 - GPL 3 license 2007

=item MIT - the MIT license

=head2 AUTHOR

David Farrell

=head2 LICENSE

FreeBSD - see LICENSE

=end pod
