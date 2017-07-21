sub MAIN(Str :$glyphlist = 'glyphlist.txt', Bool :$subset = False) {
    my %glyphs;
    my %subset = make-subset()
        if $subset;
    for $glyphlist.IO.lines {
        next if /^ '#'/ || /^ $/;
        m:s/^ $<glyph-name>=[<alnum>+] ';' [ $<code-point>=[<xdigit>+] ]+ $/
            or do {
                   warn "unable to parse encoding line: $_";
                   next;
        };
        my $glyph-name = ~ $<glyph-name>;
        unless $subset && !%subset{$glyph-name} {
            my $char = @<code-point>.map({ :16( .Str ).chr }).join;
            %glyphs{$char} = $glyph-name;
        }
    }
    say %glyphs.perl;
}

sub make-subset {
    require Font::AFM;
    BEGIN our @CoreFonts = <
        Courier      Courier-Bold     Courier-Oblique    Courier-BoldOblique
        Helvetica    Helvetica-Bold   Helvetica-Oblique  Helvetica-BoldOblique
        Times-Roman  Times-Bold       Times-Italic       Times-BoldItalic
        Symbol       ZapfDingbats
    >;

    my %subset;
    $*ERR.print: "building subset";
    for @CoreFonts -> $name {
        $*ERR.print: ".";
        my $class = Font::AFM.metrics-class: $name;
        %subset{$_}++ for $class.Wx.keys;
    }
    $*ERR.say: "done";
    %subset;
}
