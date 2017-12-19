#!/usr/bin/env perl6
use v6;
use PDF::Class;
use PDF::DAO::Type::Encrypt :PermissionsFlag;

sub MAIN(*@files, Str :$save-as)  {

    my $pdf = PDF::Class.open: @files.shift;

    die "nothing to do"
	unless @files;

    die "PDF forbids modification\n"
	unless $pdf.permitted( PermissionsFlag::Modify );

    # create a new page root. 
    my $pages = $pdf.Root.Pages;

    for @files -> $in-file {
	my $in-pdf = PDF::Class.open: $in-file;

	die "PDF forbids copy: $in-file"
	    unless $in-pdf.permitted( PermissionsFlag::Copy );

	$pages.add-pages: $in-pdf.Root.Pages;
    }

    if $save-as {
	# save to a new file
	$pdf.save-as: $save-as;
    }
    else {
	# inplace incremental update of first file
	$pdf.update;
    }
}

=begin pod

=head1 NAME

appendpdf.p6 - Append one PDF to another

=head1 SYNOPSIS

 appendpdf.p6 [options] --save-as=output.pdf file1.pdf file2.pdf

 Options:
   --save-as=file     save as a new PDF

=head1 DESCRIPTION

Copy the contents of C<file2.pdf> to the end of C<file1.pdf>.  This may
break complex PDFs which include forms, so the C<--forms> option is
provided to eliminate those elements from the resulting PDF.

=head1 SEE ALSO

PDF (Perl 6)
CAM::PDF (Perl 5)

=head1 AUTHOR

See L<CAM::PDF>

=cut

=end pod
