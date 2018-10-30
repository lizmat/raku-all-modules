role PDF::Content::Font::Enc::Glyphic {
    use Font::AFM;
    has Hash $.glyphs is rw = %Font::AFM::Glyphs;
    has @!differences;
    has uint8 @!diff-cids;
    has Bool  $!diff-cids-updated = False;

    method lookup-glyph(UInt $chr-code) {
        $!glyphs{$chr-code.chr}
    }

    method glyph-map {
        %( $!glyphs.invert );
    }

    method add-glyph-diff(UInt $idx) {
        @!diff-cids.push: $idx;
        $!diff-cids-updated = True;
    }

    method differences is rw {
        Proxy.new(
            STORE => sub ($, @!differences) {
                my %glyph-map := self.glyph-map;
                my uint32 $idx = 0;
                for @!differences {
                    when UInt { $idx  = $_ }
                    when Str {
                        self.set-encoding(.ord, $idx)
                            with %glyph-map{$_};
                        $idx++;
                    }
                }
                $!diff-cids-updated = False;
            },
            FETCH => sub ($) {
                if $!diff-cids-updated {
                    @!differences = ();
                    my int $cur-idx = -2;
                    for @!diff-cids.list.sort {
                        unless $_ == ++$cur-idx {
                            @!differences.push: $_;
                            $cur-idx = $_;
                        }
                        @!differences.push: 'name' => self.lookup-glyph( @.to-unicode[$_] ) // '.notdef';
                    }
                    $!diff-cids-updated = False;
                }
                @!differences;
            },
        )
    }
}
