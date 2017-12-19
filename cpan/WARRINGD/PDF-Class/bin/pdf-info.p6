#!/usr/bin/env perl6
use v6;

use PDF::Class;
use PDF::IO::Input::Str;
use PDF::IO::Input::IOH;

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

    my $input = $infile eq '-'
	?? PDF::IO::Input::Str.new( :value($*IN.slurp-rest( :enc<latin-1> )) )
	!! PDF::IO::Input::IOH.new( :value($infile.IO.open( :enc<latin-1> )) );

    my $doc = PDF::Class.open( $input, :$password );

    my UInt $size = $input.codes;
    my UInt $pages = $doc.page-count;
    my Version $pdf-version = $doc.version;
    my $pdf-info = $doc.Info;
    my $box = $doc.Pages.MediaBox;
    my $encrypt = $doc.Encrypt;
    my $catalog = $doc.Root;
    my $tagged  = $catalog.?MarkInfo.?Marked   // False;
    my $partial = $catalog.?MarkInfo.?Suspects // False;
    my UInt $revisions = + $doc.reader.xrefs;

    my UInt @page-size = $box
	?? ($box[2] - $box[0],  $box[3] - $box[1])
	!! (0, 0);

    say "File:         $infile";
    say "File Size:    $size bytes";
    say "Pages:        $pages";
    if $pdf-info {
	for $pdf-info.keys -> $key {
	    my Str $info = pretty-print( $pdf-info{$key} );
	    printf "%-13s %s\n", $key ~ q{:}, $info
	        unless $info eq '';
	}
    }
    say 'Tagged:       ' ~ yes-no($tagged) ~ ($partial ?? ' (partial)' !! '');
    say 'Page Size:    ' ~ (@page-size[0] ?? "@page-size[0] x @page-size[1] pts" !! 'variable');
##	say 'Optimized:    '.($doc->isLinearized()?'yes':'no');
	say "PDF version:  $pdf-version";
	say "Revisions:    $revisions";
        use PDF::DAO::Type::Encrypt :PermissionsFlag;

	print 'Encryption:   ';
	if my $enc = $doc.Encrypt and $enc.O {
            my $V = $enc.V // 0;
            my $Length = $enc.Length // 40;
	    print "yes (";

	    # show user, not owner, permissions
	    temp $doc.reader.crypt.is-owner = False
	        if $doc.reader.?crypt;

            for :print(PermissionsFlag::Print), :copy(PermissionsFlag::Copy),
                :change(PermissionsFlag::Modify), :addNotes(PermissionsFlag::Add) {
	        print "{.key}:{yes-no( $doc.permitted: .value)} ";
            }
            say "algorithm:RC4 {$V}.{$enc.R}, $Length bits)";
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
