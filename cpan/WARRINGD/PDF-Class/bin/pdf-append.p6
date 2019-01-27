#!/usr/bin/env perl6
use v6;
use PDF::Class;
use PDF::Pages;
use PDF::COS::Type::Encrypt :PermissionsFlag;

sub MAIN(*@files, Str :$save-as, Bool :$drm = True)  {

    my PDF::Class $pdf .= open: @files.shift;

    die "nothing to do"
	unless @files;

    die "PDF forbids modification\n"
	if $drm && !$pdf.permitted( PermissionsFlag::Modify );

    # create a new page root. 
    my PDF::Pages $pages-out = $pdf.catalog.Pages;

    for @files -> $in-file {
	my PDF::Class $pdf-in .= open: $in-file;

	die "PDF forbids copy: $in-file"
	    if $drm && !$pdf-in.permitted( PermissionsFlag::Copy );

        my PDF::Pages $pages-in = $pdf-in.catalog.Pages;
	$pages-out.add-pages: $pages-in;
    }

    if $save-as {
	# save to a new file
	$pdf.save-as: $save-as;
    }
    else {
	# in-place incremental update of first file
	$pdf.update;
    }
}

=begin pod

=head1 NAME

pdf-append.p6 - Append one PDF to another

=head1 SYNOPSIS

 pdf-append.p6 [options] --save-as=output.pdf file1.pdf file2.pdf ...

 Options:
   --save-as=file     save as a new PDF

=head1 DESCRIPTION

Copy the contents of C<file2.pdf> etc, to the end of C<file1.pdf>, optionally saved as a new PDF.

=head1 SEE ALSO

PDF (Perl 6)
CAM::PDF (Perl 5)

=head1 AUTHOR

See L<CAM::PDF>

=cut

=end pod
