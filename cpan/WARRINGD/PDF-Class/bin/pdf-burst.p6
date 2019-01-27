#!/usr/bin/env perl6
use v6;
use PDF::Class;
use PDF::Catalog;
use PDF::Page;
use PDF::Pages;
use PDF::IO;

#| reading from stdin
multi sub output-filename('-') {"pdf-page%03d.pdf"}
#| user supplied format spec
multi sub output-filename(Str $filename where /'%'/) {$filename}
#| generated sprintf format from input/output filename template
multi sub output-filename(Str $infile) is default {
      my Str $ext = $infile.IO.extension;
      $ext eq ''
      ?? $infile ~ '%03d.pdf'
      !! $infile.subst(/ '.' $ext$/, '%03d.' ~ $ext);
}

subset Number of Int where * > 0;

sub MAIN(Str $infile,              #| input PDF
	 Str :$password = '',      #| password for the input PDF, if encrypted
	 Str :$save-as is copy,    #| output template filename
         Number :$batch-size = 1,  #| number of pages per batch (1)
    ) {

    $save-as = output-filename( $save-as // $infile );

    my $input = PDF::IO.coerce(
       $infile eq '-'
           ?? $*IN.slurp-rest( :bin ) # not random access
           !! $infile.IO
    );

    my PDF::Class $pdf .= open( $input, :$password);
    my PDF::Catalog $catalog = $pdf.catalog;
    # just remove anything in the catalog that may
    # reference other pages or otherwise confuse things
    $catalog<AcroForm MarkInfo Metadata Names OCProperties
             Outlines PageLabels StructTreeRoot>:delete;

    my UInt $page-count = $pdf.page-count;
    my UInt $page-num = 1;

    while $page-num <= $page-count {

	my $save-page-as = $save-as.sprintf($page-num);
	die "invalid 'sprintf' output page format: $save-as"
	    if $save-page-as eq $save-as;

        my PDF::Page @pages;
        for 1 .. $batch-size {
            my PDF::Page $page = $pdf.page($page-num);
            # bind resources and other inherited properties to the page
            for <Resources Rotate MediaBox CropBox> -> $k {
                $page{$k} //= $_ with $page."$k"();
            }
            # strip external references from the page
            $page<StructParents Annots Parent>:delete;
            push @pages, $page;
            last if ++$page-num > $page-count;
        }

        with $catalog.Pages -> PDF::Pages $p {
            # pretend these are the only pages in the document
	    temp $p.Kids = @pages;
	    temp $p.Count = +@pages;
	    warn "saving {+@pages} pages: $save-page-as";
	    $pdf.save-as( $save-page-as, :rebuild );
        }
    }

}

=begin pod

=head1 NAME

pdf-burst.p6 - Burst a PDF into individual pages

=head1 SYNOPSIS

 pdf-burst.p6 [options] --save-as=outspec.pdf infile.pdf

 Options:
   --save-as=outspec.pdf  # e.g. --save-as=myout-%02d.pdf
   --pasword=str       # provide a password for  an encrypted PDF
   --batch-size=n      # number of pages per burst (1)

=head1 DESCRIPTION

This program bursts a large input PDF into single or multi-page output PDF files.

By default, the output pdf will be named infile001.pdf infile002.pdf ...

The save-as argument, if present, will be used as a 'sprintf' template for generation of the individual output files.

=head1 SEE ALSO

PDF

=head1 AUTHOR

See L<PDF>

=end pod
