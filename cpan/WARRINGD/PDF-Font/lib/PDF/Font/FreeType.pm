class PDF::Font::FreeType {
    use PDF::DAO;
    use PDF::IO::Blob;
    use PDF::IO::Util :pack;
    use PDF::Writer;
    use NativeCall;
    use PDF::Font::Enc::Identity-H;
    use PDF::Font::Enc::Type1;
    use Font::FreeType;
    use Font::FreeType::Face;
    use Font::FreeType::Error;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    constant Px = 64.0;

    has Font::FreeType::Face $.face;
    has $!encoder handles <decode>;
    has Blob $.font-stream is required;
    use PDF::Content::Font;
    has PDF::Content::Font $!dict;
    has UInt $!first-char;
    has UInt $!last-char;
    has uint16 @!widths;
    my subset EncodingScheme of Str where 'mac'|'win'|'identity-h';
    has EncodingScheme $!enc;

    submethod TWEAK {
        $!enc = self!font-format eq 'Type1' ?? 'win' !! 'identity-h';
        $!encoder = $!enc eq 'identity-h'
            ?? PDF::Font::Enc::Identity-H.new: :$!face
            !! PDF::Font::Enc::Type1.new: :$!enc, :$!face;
        @!widths[255] = 0;
    }

    method height($pointsize = 1000, Bool :$from-baseline, Bool :$hanging) {
        die "todo: height of non-scaling fonts" unless $!face.is-scalable;
        my List $bbox = $!face.bounding-box.Array;
	my Numeric $height = $hanging ?? $!face.ascender !! $bbox[3];
	$height -= $hanging ?? $!face.descender !! $bbox[1]
            unless $from-baseline;
        $height * $pointsize / $!face.units-per-EM;
    }

    method encode(Str $text, :$str) {
        my $encoded := $!encoder.encode($text);
        my $to-unicode := $!encoder.to-unicode;
        my uint16 $min = $encoded.min;
        my uint16 $max = $encoded.max;
        $!first-char = $min if !$!first-char || $min < $!first-char;
        $!last-char = $max if !$!last-char || $max > $!last-char;
        for $encoded.list {
            @!widths[$_] ||= $.stringwidth($to-unicode[$_].chr).round;
        }

        # 16 bit encoding. convert to bytes
        $encoded := pack($encoded, 16)
            if $encoded.of ~~ uint16;

        $str
            ?? $encoded.decode('latin-1')
            !! $encoded;
    }

    my subset FontFormat of Str where 'TrueType'|'OpenType'|'Type1';
    method !font-format returns FontFormat {
        given $!face.font-format {
            when 'CFF'|'TrueType' { 'TrueType' }
            when 'Type 1' { 'Type1' }
            default { die "unsupported font format: $_" }
        }
    }

      method !font-file-entry {
        given self!font-format {
            when 'TrueType' { 'FontFile2' }
            when 'OpenType' { 'FontFile3' }
            default { 'FontFile' }
        }
    }

    method font-name {
        $!face.postscript-name
    }

    method font-file {
        my $decoded = PDF::IO::Blob.new: $!font-stream;
        my $font-file = PDF::DAO.coerce: :stream{
            :$decoded,
            :dict{
                :Length1($!font-stream.bytes),
                :Filter( :name<FlateDecode> ),
            },
        };
        $font-file<Subtype> = :name<CIDFontType0C>
            unless self!font-format eq 'TrueType';

        $font-file;
    }

    method !font-descriptor {
        my $Ascent = $!face.ascender;
        my $Descent = $!face.descender;
        my $FontName = PDF::DAO.coerce: :name($.font-name);
        my $FontFamily = $!face.family-name;
        my $FontBBox = $!face.bounding-box.Array;
        my $font-file = self.font-file;

        my $dict = {
            :Type( :name<FontDescriptor> ),
            :$FontName, :$FontFamily, :$Ascent, :$Descent, :$FontBBox,
            self!font-file-entry => $font-file,
        };
    }

    method !encoding-name {
        my %enc-name = :win<WinAnsiEncoding>, :mac<MacRomanEncoding>, :identity-h<Identity-H>;
        with %enc-name{$!enc} -> $name {
            :$name;
        }
    }

    method !make-roman-dict {
        my $FontDescriptor = self!font-descriptor;
        my $BaseFont = $FontDescriptor<FontName>;
        my $Encoding = self!encoding-name;
        {
            :Type( :name<Font> ), :Subtype( :name(self!font-format) ),
            :$BaseFont,
            :$Encoding,
            :$FontDescriptor,
        };
    }

    method !unicode-cmap {
        my $dict = {
            :Type( :name<CMap> ),
              :CIDSystemInfo{
                  :Ordering<Identity>,
                    :Registry($.font-name),
                    :Supplement(0),
                },
        };

        my $to-unicode := $!encoder.to-unicode;
        my @cmap-char;
        my @cmap-range;

        loop (my uint16 $cid = $!first-char; $cid <= $!last-char; $cid++) {
            my uint32 $char-code = $to-unicode[$cid]
              || next;
            my uint16 $start-cid = $cid;
            my uint32 $start-code = $char-code;
            while $cid < $!last-char && $to-unicode[$cid + 1] == $char-code+1 {
                $cid++; $char-code++;
            }
            if $start-cid == $cid {
                @cmap-char.push: '<%04X> <%04X>'.sprintf($cid, $start-code);
            }
            else {
                @cmap-range.push: '<%04X> <%04X> <%04X>'.sprintf($start-cid, $cid, $start-code);
            }
        }

        if @cmap-char {
            @cmap-char.unshift: "{+@cmap-char} beginbfchar";
            @cmap-char.push: 'endbfchar';
        }

        if @cmap-range {
            @cmap-range.unshift: "{+@cmap-range} beginbfrange";
            @cmap-range.push: 'endbfrange';
        }

        my $writer = PDF::Writer.new;
        my $cmap-name = $writer.write: :name('pdf-font-p6-' ~ $.font-name);
        my $postscript-name = $writer.write: :literal($.font-name);

        my $decoded = qq:to<--END-->.chomp;
            %% Custom
            %% CMap
            %%
            /CIDInit /ProcSet findresource begin
            12 dict begin begincmap
            /CIDSystemInfo <<
               /Registry $postscript-name
               /Ordering (XYZ)
               /Supplement 0
            >> def
            /CMapName $cmap-name def
            1 begincodespacerange <{$!first-char.fmt("%04x")}> <{$!last-char.fmt("%04x")}> endcodespacerange
            {@cmap-char.join: "\n"}
            {@cmap-range.join: "\n"}
            endcmap CMapName currendict /CMap defineresource pop end end
            --END--

        PDF::DAO.coerce: :stream{ :$dict, :$decoded };
    }

    method !make-index-dict {
        my $FontDescriptor = self!font-descriptor;
        my $BaseFont = $FontDescriptor<FontName>;
        my $Subtype = :name( given self!font-format {
            when 'Type1'    {'Type1'}
            when 'TrueType' {'CIDFontType2'}
            default { 'CIDFontType0' }
        });

        my $DescendantFonts = [
            :dict{
                :Type( :name<Font> ),
                :$Subtype,
                :$BaseFont,
                :CIDToGIDMap( :name<Identity> ),
                :CIDSystemInfo{
                    :Ordering<Identity>,
                      :Registry<Adobe>,
                      :Supplement(0),
                  },
                  :$FontDescriptor,
            }, ];

        { :Type( :name<Font> ), :Subtype( :name<Type0> ),
            :$BaseFont,
            :$DescendantFonts,
            :Encoding( :name<Identity-H> ),
        };
    }

    method !make-dict {
        $!enc eq 'identity-h'
          ?? self!make-index-dict
          !! self!make-roman-dict
      }

    method to-dict {
        $!dict //= PDF::Content::Font.make-font(
            PDF::DAO::Dict.coerce(self!make-dict),
            self);
    }

    method stringwidth(Str $text is copy, Numeric $pointsize?, Bool :$kern) {
        my FT_Pos $x = 0;
        my FT_Pos $y = 0;
        my FT_UInt $prev-idx = 0;
        my $kerning = FT_Vector.new;
        my $struct = $!face.struct;
        my $glyph-slot = $struct.glyph;
        my Numeric $stringwidth = 0;
        my $scale = 1000 / ($!face.units-per-EM || 1000);

        for $text.ords -> $char-code {
            my FT_UInt $this-idx = $struct.FT_Get_Char_Index( $char-code );
            if $this-idx {
                CATCH {
                    when Font::FreeType::Error { warn "error processing char $char-code: " ~ .message; }
                }
                ft-try({ $struct.FT_Load_Glyph( $this-idx, FT_LOAD_NO_SCALE ); });
                $stringwidth += $glyph-slot.metrics.hori-advance * $scale;
                if $kern && $prev-idx {
                    ft-try({ $struct.FT_Get_Kerning($prev-idx, $this-idx, FT_KERNING_UNSCALED, $kerning); });
                    my $dx = ($kerning.x * $scale).round;
                    $stringwidth += $dx;
                }
            }
            $prev-idx = $this-idx;
        }
        $stringwidth = $stringwidth.round;
        $stringwidth *= $_ / 1000 with $pointsize;
        $stringwidth;
    }

    method kern(Str $text) {
        my FT_Pos $x = 0;
        my FT_Pos $y = 0;
        my FT_UInt $prev-idx = 0;
        my $kerning = FT_Vector.new;
        my $face-struct = $!face.struct;
        my $glyph-slot = $face-struct.glyph;
        my $str = '';
        my @chunks;
        my Numeric $stringwidth = 0.0;
        my $scale = 1000 / $!face.units-per-EM;

        for $text.ords -> $char-code {
            my FT_UInt $this-idx =  $face-struct.FT_Get_Char_Index( $char-code );
            if $this-idx {
                ft-try({ $face-struct.FT_Load_Glyph( $this-idx, FT_LOAD_NO_SCALE); });
                $stringwidth += $glyph-slot.metrics.hori-advance * $scale;
                if $prev-idx {
                    ft-try({ $face-struct.FT_Get_Kerning($prev-idx, $this-idx, FT_KERNING_UNSCALED, $kerning); });
                    my $dx = ($kerning.x * $scale).round;
                    if $dx {
                        @chunks.push: $str;
                        @chunks.push: $dx;
                        $stringwidth += $dx;
                        $str = '';
                    }
                }
                $str ~= $char-code.chr;
                $prev-idx = $this-idx;
            }
        }

        @chunks.push: $str
            if $str.chars;

        @chunks, $stringwidth.round;
    }

    method cb-finish {
        given $!enc {
            when 'identity-h' {
                my @Widths;
                my uint $j = -2;
                my $chars = [];
                loop (my uint16 $i = $!first-char; $i <= $!last-char; $i++) {
                    my uint $w = @!widths[$i];
                    if $w {
                        if ++$j == $i {
                            $chars.push: $w;
                        }
                        else {
                            $chars = [ $w, ];
                            $j = $i;
                            @Widths.append: ($i, $chars);
                        }
                    }
                }
                $.to-dict<DescendantFonts>[0]<W> = @Widths;
                $.to-dict<ToUnicode> = self!unicode-cmap;
            }
            default {
                given $.to-dict {
                    .<FirstChar> = $!first-char;
                    .<LastChar> = $!last-char;
                    .<Widths> = @!widths[$!first-char .. $!last-char];
                    my @Differences = $!encoder.differences;
                    if @Differences {
                        .<Encoding> = %(
                            :Type( :name<Encoding> ),
                            :BaseEncoding(self!encoding-name),
                            :@Differences,
                           );
                    }
                }
            }
        }
    }
}
