class PDF::Font {

    use Font::FreeType;
    use Font::FreeType::Face;
    use PDF::Font::FreeType;
    use PDF::Font::Type1;

    subset TrueTypish of Font::FreeType::Face where .font-format eq 'TrueType'|'CFF';
    subset Type1ish of Font::FreeType::Face where .font-format eq 'Type 1';
    subset TrueTypeData of Blob where { .subbuf(0,4).decode('latin-1') ne 'ttcf' }

    multi method load-font(Str :$file!, |c) is default {
        my $free-type = Font::FreeType.new;
        my $font-stream = $file.IO.open(:r, :bin).slurp: :bin;
        my $face = $free-type.face($font-stream);
        self.load-font(:$face, :$font-stream, |c);
    }

    multi method load-font(TrueTypish :$face!, TrueTypeData :$font-stream!, |c) {
        PDF::Font::FreeType.new( :$face, :$font-stream, |c);
    }

    multi method load-font(Type1ish :$face!, TrueTypeData :$font-stream!, |c) {
        PDF::Font::Type1.new( :$face, :$font-stream, |c);
    }

    # experimental; resolve font name via fontconfig
    multi method load-font(Str :$name!, |c) {
        my $cmd =  run('fc-match',  '-f', '%{file}', $name, :out, :err);
        given $cmd.err.slurp {
            note $_ if $_;
        }
        my $file = $cmd.out.slurp;
        die "unable to resolve font-name: $name"
          unless $file;
        self.load-font: :$file, |c;
    }

    multi method load-font(Font::FreeType::Face :$face!, |c) {
        die "unsupported font format: {$face.font-format}";
    }

}

=begin pod

=head1 NAME

PDF::Font

=head1 SYNPOSIS

 use PDF::Lite;
 use PDF::Font;
 my $deja = PDF::Font.load-font: :file<t/fonts/DejaVuSans.ttf>;

 # experimental. requires fontconfig
 my $deja-vu = PDF::Font.load-font: :name<DejaVuSans>;

 my PDF::Lite $pdf .= new;
 $pdf.add-page.text: {
    .font = $deja;
    .text-position = [10, 600];
    .say: 'Hello, world';
 }
 $pdf.save-as: "/tmp/example.pdf";

=head1 DESCRIPTION

This module provdes font handling for
L<PDF::Lite>,  L<PDF::API6> and other PDF modules.

=head1 METHODS

=head3 load-font

 PDF::Font.load-font(Str $font-file);

A class level method to create a new font object from a font file.

parameters:
=begin item
C<$font-file>

Font file to load. Currently supported formats are:
=item2 Open-Type (C<.otf>)
=item2 True-Type (C<.ttf>)
=item2 Postscript (C<.pfb>, or C<.pfa>)

=end item

=head1 BUGS AND LIMITATIONS

=item Font subsetting is not yet implemented. I.E. fonts are always fully embedded, which may result in large PDF files.

=end pod

