use v6;

class PDF::Content::Image::PDF {
    method read($fh) {
        $fh.seek(0, SeekFromBeginning);
        my $header = $fh.read(4).decode: 'latin-1';
        my $path = $fh.path;
        die X::PDF::Image::WrongHeader.new( :type<PDF>, :$header, :$path )
            unless $header ~~ "%PDF";
        my $pdf = (require ::('PDF::Lite')).open($fh);
        my $page1 = $pdf.page(1) // die "PDF contains no pages";
        $page1.to-xobject;
    }
}
