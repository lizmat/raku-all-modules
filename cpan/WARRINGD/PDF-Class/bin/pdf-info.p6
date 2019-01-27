#!/usr/bin/env perl6
use v6;

use PDF::Class;
use PDF::Catalog;
use PDF::Info;
use PDF::IO;

multi sub pretty-print(DateTime $dt --> Str) {
    sprintf('%s %s %02d %02d:%02d:%02d %04d',
	    <Mon Tue Wed Thu Fri Sat Sun>[$dt.day-of-week - 1],
	    <Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec>[$dt.month - 1],
	    $dt.day-of-month,
	    $dt.hour, $dt.minute, $dt.second,
	    $dt.year)
}

multi sub pretty-print(Mu $val --> Str) is default {
    ~$val
}

# A port of pdfinfo.pl from the Perl 5 CAM::PDF module to PDF and Perl 6

multi sub MAIN(Bool :$version! where $_) {
    # nyi in rakudo https://rt.perl.org/Ticket/Display.html?id=125017
    say "PDF::Class {PDF::Class.^version}";
    say "this script was ported from the CAM::PDF PDF Manipulation library";
    say "see - https://metacpan.org/pod/CAM::PDF";
}

sub yes-no(Bool $cond) {
    $cond ?? 'yes' !! 'no';
}

multi sub MAIN(Str $infile,           #| input PDF
	       Str :$password = '',   #| password for the input PDF, if encrypted
    ) {

    my $input = PDF::IO.coerce(
       $infile eq '-'
           ?? $*IN.slurp-rest( :bin ) # not random access
           !! $infile.IO
    );

    my PDF::Class $pdf .= open( $input, :$password );

    my UInt $size = $input.codes;
    my UInt $pages = $pdf.page-count;
    my Version $pdf-version = $pdf.version;
    my PDF::Info $pdf-info = $_ with $pdf.Info;
    my List $box = $pdf.Pages.MediaBox;
    my PDF::Catalog $catalog = $pdf.catalog;
    my Bool $tagged = False;
    my Bool $partial = False;
    with $catalog.MarkInfo {
        $tagged  = $_ with .Marked;
        $partial = $_ with .Suspects;
    }
    my UInt $revisions = + $pdf.reader.revision-xrefs;

    my UInt @page-size = $box
	?? ($box[2] - $box[0],  $box[3] - $box[1])
	!! (0, 0);

    say "File:         $infile";
    say "File Size:    $size bytes";
    say "Pages:        $pages";
    say 'Outlines:     ' ~ yes-no(do with $catalog.Outlines {?.First} else {False});
    with $pdf-info {
	for .keys.sort -> $key {
	    my Str $prop = try {pretty-print( $pdf-info{$key} ) } // '???';
	    printf "%-13s %s\n", $key ~ q{:}, $prop
	        unless $prop ~~ '';
	}
    }
    say 'Tagged:       ' ~ yes-no($tagged) ~ ($partial ?? ' (partial)' !! '');
    say 'Page Size:    ' ~ (@page-size[0] ?? "@page-size[0] x @page-size[1] pts" !! 'variable');
 ##   say 'Web Optimized:' ~ yes-no($pdf.is-Linearized);
    say "PDF version:  $pdf-version";
    say "Revisions:    $revisions";
    use PDF::COS::Type::Encrypt :PermissionsFlag;

    print 'Encryption:   ';
    if my $enc = $pdf.Encrypt and $enc.O {
        my $V = $enc.V // 0;
        my $Length = $enc.Length // 40;
	print "yes (";

	# show user, not owner, permissions
##	temp $pdf.reader.crypt.is-owner = False
##	    if $pdf.reader.?crypt;
        my $alg-type = $pdf.reader.crypt.type.join: ',';

        for :print(PermissionsFlag::Print), :copy(PermissionsFlag::Copy),
            :change(PermissionsFlag::Modify), :addNotes(PermissionsFlag::Add) {
	    print "{.key}:{yes-no( $pdf.permitted: .value)} ";
        }
        say "algorithm:{$alg-type} {$V}.{$enc.R}, $Length bits)";
    }
    else {
        say "no";
    }

##	if (@ARGV > 0)
##	{
##	    print "---------------------------------\n";
##	}

}

=begin pod

=head1 NAME

pdf-info.p6 - Print information about PDF file(s)

=head1 SYNOPSIS

pdf-info.p6 [options] file.pdf

Options:
   --password   password for an encrypted PDF

=head1 DESCRIPTION

Prints to STDOUT various basic details about the specified PDF
file(s).

=head1 SEE ALSO

CAM::PDF (Perl 5)
PDF (Perl 6)

=head1 AUTHOR

See L<CAM::PDF>

=cut

=end pod
