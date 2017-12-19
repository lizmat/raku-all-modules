#!/usr/bin/env perl6
use v6;
use PDF::Class;

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

sub MAIN(Str $infile,            #| input PDF
	 Str :$password = '',    #| password for the input PDF, if encrypted
	 Str :$save-as is copy,  #| output template filename
    ) {

    $save-as = output-filename( $save-as // $infile );

    my $input = $infile eq q{-}
        ?? $*IN
	!! $infile;

    my $doc = PDF::Class.open( $input, :$password);
    my $catalog = $doc<Root>;

    my UInt $pages = $doc.page-count;

    for 1 .. $pages -> UInt $page-num {

	my $save-page-as = $save-as.sprintf($page-num);
	die "invalid 'sprintf' output page format: $save-as"
	    if $save-page-as eq $save-as;

	my $page = $doc.page($page-num);

        with $catalog.Pages {
            # pretend this is the only page in the document
	    temp .Kids = [ $page, ];
	    temp .Count = 1;
            temp $page.Parent = $catalog;

	    warn "saving page: $save-page-as";
	    $doc.save-as( $save-page-as, :rebuild );
        }
    }

}

=begin pod

=head1 NAME

pdf-burst.p6 - Burst a PDF into individual pages

=head1 SYNOPSIS

 pdf-burst.p6 [options] --save-as=outspec.pdf infile.pdf

 Options:
   --save=outspec.pdf  # e.g. --save-as=myout-%02d.pdf
   --pasword=str       # provide a password for  an encrypted PDF

=head1 DESCRIPTION

This program bursts a multiple page into single page PDF files.

By default, the output pdf will be named infile001.pdf infile002.pdf ...

The save-as argument, if present, will be used as a 'sprintf' template
for generation of the individual output files.

=head1 SEE ALSO

PDF

=head1 AUTHOR

See L<PDF>

=end pod
