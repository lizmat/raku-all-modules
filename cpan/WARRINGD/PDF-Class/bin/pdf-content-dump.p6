#!/usr/bin/env perl6
use v6;

use PDF::Class;
use PDF::Page;
use PDF::Content::Ops :OpName;

use PDF::IO;

sub MAIN(Str $infile,           #= input PDF
	 Str :$password = '',   #= password for the input PDF, if encrypted
         Int :$page,            #= page-number to dump
         Bool :$perl,           #= dump in a Perl-like notation
         Bool :$strict = False, #= enable extra rendering warnings
    ) {

    my $input = PDF::IO.coerce(
       $infile eq '-'
           ?? $*IN.slurp-rest( :bin ) # not random access
           !! $infile.IO
    );

    my PDF::Class $pdf .= open( $input, :$password );

    for 1 .. $pdf.page-count {
        next if $page && $_ != $page;
        my PDF::Page $p = $pdf.page($_);
        if $perl {
	    my constant Openers = 'q'|'BT'|'BMC'|'BDC'|'BX';
	    my constant Closers = 'Q'|'ET'|'EMC'|'EX';
            my $nesting = 0;
            sub callback($op, *@args) {
                $nesting-- if $nesting && $op ~~ Closers;
                my $pad = '  ' x $nesting;
                $nesting++ if $op ~~ Openers;
                say sprintf '%s.%s(%s);',
                    $pad,
                    %OpName{$op},
                    @args.map(*.perl).join(", ");
            }
            say "# **** Page $_ ****";
            $p.render(:&callback);
        }
        else {
            say "% **** Page $_ ****";
            say $p.render(:comment-ops).Str;
       }
    }
}

=begin pod

=head1 SYNOPSIS

pdf-content-dump.p6 [options] --page=number file.pdf

Options:
   --password   password for an encrypted PDF
   --page=num   dump a single page
   --perl       dump in a Perl-like notation

=head1 DESCRIPTION

Dumps page content streams for a given PDF. The streams are uncompressed indented and commented for readbility.

=end pod
