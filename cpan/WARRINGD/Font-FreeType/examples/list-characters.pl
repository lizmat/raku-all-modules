use Font::FreeType;
use Font::FreeType::Glyph;

sub MAIN(Str $filename) {
    my $face = Font::FreeType.new.face($filename);

    $face.forall-chars:
    -> Font::FreeType::Glyph $_ {
        my $char = .char-code.chr;
        my $is-printable = $char ~~ /<print>/;
            say (.char-code ~ '[' ~ .index ~ ']', (.name//''), $char.uniname, $is-printable ?? $char !! '')\
                .join: "\t";
        }
}
