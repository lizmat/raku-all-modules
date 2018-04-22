use v6;

#| this role is applied to PDF::Content::Type::Page, PDF::Content::Type::Pattern and PDF::Content::Type::XObject::Form
role PDF::Content::Graphics {

    use PDF::Content;
    use PDF::Content::Ops :OpCode;
    use PDF::COS;

    has PDF::Content $!pre-gfx; #| prepended graphics
    method has-pre-gfx { ? .ops with $!pre-gfx }
    method pre-gfx { $!pre-gfx //= PDF::Content.new( :parent(self) ) }
    method pre-graphics(&code) { self.pre-gfx.graphics( &code ) }
    has PDF::Content $!gfx;     #| appended graphics
    has Bool $!rendered = False;

    #| add any missing 'q' (Save) and 'Q' (Restore) operators
    #| if missing at the end of input, or if needed to make the
    #| content safely editable
    method !tidy(@ops) {
        my int $nesting = 0;
        my $needed = False;

        for @ops {
            given .key {
                when OpCode::Save {$nesting++}
                when OpCode::Restore {$nesting--}
                default {
                    $needed = True
                        if $nesting <= 0
                        && PDF::Content::Ops.is-graphics-op: $_;
                }
            }
        }

        @ops.push: OpCode::Restore => []
            while $nesting-- > 0;

	if $needed {
	    @ops.unshift: OpCode::Save => [];
	    @ops.push: OpCode::Restore => [];
	}
        @ops;
    }

    method gfx(Bool :$render = False, |c) {
	$!gfx //= self.new-gfx(|c);
        self.render(|c) if $render && !$!rendered;
        $!gfx;
    }
    method graphics(&code) { self.gfx.graphics( &code ) }
    method text(&code) { self.gfx.text( &code ) }
    method canvas(&code) { self.gfx.canvas( &code ) }

    method contents-parse {
        PDF::Content.parse($.contents);
    }

    method contents returns Str {
	with $.decoded {
           .isa(Str) ?? $_ !! .Str;
        }
        else {
            ''
        }
    }

    method new-gfx(|c) {
        PDF::Content.new( :parent(self), |c );
    }

    method render($g? is copy, Bool :$tidy = True, |c) is default {
        warn '$render($gfx,...) is deprecated' with $g;
        $g //= $.gfx(|c);
        my Pair @ops = self.contents-parse;
        @ops = self!tidy(@ops)
            if $tidy;
        $g.ops: @ops;
        $!rendered = True;
        $g;
    }

    method finish {
        if $!gfx.defined || $!pre-gfx.defined {
            # rebuild graphics, if they've been accessed
            my $decoded = do with $!pre-gfx { .Str } else { '' };
            if !$!rendered && $.contents {
                # skipping rendering. copy raw content
                $decoded ~= "\n" if $decoded;
                $decoded ~= ~ OpCode::Save ~ "\n"
                    ~ $.contents
                    ~ "\n" ~ OpCode::Restore;
            }
            with $!gfx {
                $decoded ~= "\n" if $decoded;
                $decoded ~= .Str;
            }
            $!gfx = $!pre-gfx = Nil;
            self.decoded = $decoded;
        }
    }

    method cb-finish { $.finish }

    method xobject-form(:$group = True, *%dict) {
        %dict<Type> = :name<XObject>;
        %dict<Subtype> = :name<Form>;
        %dict<Resources> //= {};
        %dict<BBox> //= [0,0,612,792];
        %dict<Group> //= %( :S( :name<Transparency> ) )
            if $group;
        PDF::COS.coerce( :stream{ :%dict });
    }

    method tiling-pattern(List    :$BBox!,
                          Numeric :$XStep = $BBox[2] - $BBox[0],
                          Numeric :$YStep = $BBox[3] - $BBox[1],
                          Int :$PaintType = 1,
                          Int :$TilingType = 1,
                          Hash :$Resources = {},
                          *%dict
                         ) {
        %dict.push: $_
                     for (:Type(:name<Pattern>), :PatternType(1),
                          :$PaintType, :$TilingType,
                          :$BBox, :$XStep, :$YStep, :$Resources);
        PDF::COS.coerce( :stream{ :%dict });
    }
    my subset ImageFile of Str where /:i '.'('png'|'svg'|'pdf') $/;
    method save-as-image(ImageFile $outfile) {
        # experimental draft rendering via Cairo
        (try require PDF::Render::Cairo) !=== Nil
             or die "save-as-image method is only supported if PDF::Render::Cairo is installed";
        ::('PDF::Render::Cairo').save-as-image(self, $outfile);
    }
}
