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

    # resolve font name via fontconfig
    multi method load-font(Str :$name!, |c) {
        my $file = self.find-font($name, |c);
        self.load-font: :$file, |c;
    }

    multi method load-font(Font::FreeType::Face :$face!, |c) {
        die "unsupported font format: {$face.font-format}";
    }

    subset Weight  of Str where /^[thin|extralight|light|book|regular|medium|semibold|bold|extrabold|black]$/;
    subset Stretch of Str where /^[[ultra|extra]?[condensed|expanded]]|normal$/;
    subset Slant   of Str where /^[normal|oblique|italic]$/;
    method find-font(Str $family-name, Weight :$weight='medium', Stretch :$stretch='normal', Slant :$slant='normal') {
        my $pat = $family-name;
        $pat ~= ':weight=' ~ $weight  unless $weight eq 'medium';
        $pat ~= ':width='  ~ $stretch unless $stretch eq 'normal';
        $pat ~= ':slant='  ~ $slant   unless $slant eq 'normal';

        my $cmd =  run('fc-match',  '-f', '%{file}', $pat, :out, :err);
        given $cmd.err.slurp {
            note $_ if $_;
        }
        my $file = $cmd.out.slurp;
        $file
          || die "unable to resolve font: $pat"
    }
}

=begin pod

=head1 NAME

PDF::Font

=head1 DESCRIPTION

B<This module has been renamed. Please use PDF::Font::Loader>

=end pod

