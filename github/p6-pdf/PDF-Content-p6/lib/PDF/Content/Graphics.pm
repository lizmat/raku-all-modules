use v6;

#| this role is applied to PDF::Content::Type::Page, PDF::Content::Type::Pattern and PDF::Content::Type::XObject::Form
role PDF::Content::Graphics {

    use PDF::Content;
    use PDF::Content::Ops :OpCode;
    use PDF::DAO;

    has PDF::Content $!pre-gfx; #| prepended graphics
    method has-pre-gfx { ? .ops with $!pre-gfx }
    method pre-gfx { $!pre-gfx //= PDF::Content.new( :parent(self) ) }
    method pre-graphics(&code) { self.pre-gfx.graphics( &code ) }
    has PDF::Content $!gfx;     #| appended graphics

    method !encapsulate(@ops) {
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

    method gfx(Bool :$render = True, |c) {
	$!gfx //= do {
            my $gfx = self.new-gfx(|c);;
            self.render($gfx, |c) if $render;
            $gfx;
        }
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

    method render($gfx, Bool :$encap = True) {
        my Pair @ops = self.contents-parse;
        @ops = self!encapsulate(@ops)
            if $encap;
        $gfx.ops: @ops;
        $gfx;
    }

    method finish {
        if $!gfx.defined || $!pre-gfx.defined {
            # rebuild graphics, if they've been accessed
            my $decoded = do with $!pre-gfx { .Str } else { '' };
            $decoded ~= "\n" if $decoded;
            $decoded ~= $.gfx.Str;
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
        PDF::DAO.coerce( :stream{ :%dict });
    }

    method tiling-pattern(List    :$BBox!,
                          Numeric :$XStep = $BBox[2] - $BBox[0],
                          Numeric :$YStep = $BBox[3] - $BBox[1],
                          Int :$PaintType = 1,
                          Int :$TilingType = 1,
                          *%dict
                         ) {
        %dict.push: $_
                     for (:Type(:name<Pattern>), :PatternType(1),
                          :$PaintType, :$TilingType,
                          :$BBox, :$XStep, :$YStep);
        PDF::DAO.coerce( :stream{ :%dict });
    }

}
