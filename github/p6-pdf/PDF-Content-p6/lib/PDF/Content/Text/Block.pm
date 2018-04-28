use v6;

#| simple plain-text text blocks
class PDF::Content::Text::Block {

    use PDF::Content::Text::Style;
    use PDF::Content::Text::Line;
    use PDF::Content::Ops :OpCode, :TextMode;
    use PDF::Content::Marked :ParagraphTags;
    use PDF::Content::XObject;

    has Numeric $.width;
    has Numeric $.height;
    my subset Alignment of Str is export(:Alignment) where 'left'|'center'|'right'|'justify';
    has Alignment $.align = 'left';
    my subset VerticalAlignment of Str is export(:VerticalAlignment) where 'top'|'center'|'bottom';
    has VerticalAlignment $.valign = 'top';
    has PDF::Content::Text::Style $!style handles <font font-size leading kern WordSpacing CharSpacing HorizScaling TextRise baseline-shift space-width>;
    has @.lines;
    has @.overflow is rw;
    has ParagraphTags $.type = Paragraph;
    has @.images;
    has Str $.text;

    method content-width  { @!lines.map( *.content-width ).max }
    method content-height {
        sum @!lines.map( *.height * $.leading )
    }

    my grammar Text {
        token nbsp  { <[ \c[NO-BREAK SPACE] \c[NARROW NO-BREAK SPACE] \c[WORD JOINER] ]> }
        token space { [\s <!after <nbsp> >]+ }
        token word  { [ <![ - ]> <!before <space>> . ]+ '-'? | '-' }
    }

    method comb(Str $_) {
        .comb(/<Text::word> | <Text::space>/);
    }

    multi submethod TWEAK(Str :$!text!, |c) {
        my Str @chunks = self.comb: $!text;
        self.TWEAK( :@chunks, |c );
    }

    multi submethod TWEAK(:@chunks!, |c) is default {
	$!style .= new(|c);
        $!text = @chunks.map(*.Str).join;
	self!layup(@chunks);
    }

    method !layup(@chunks, :$resume, :$next-line) is default {
        my @atoms = @chunks; # copy
        my @line-atoms;
        my Bool $follows-ws = flush-space(@atoms);
        my $word-gap = self!word-gap;
	my $height = $!style.font-size;

        my PDF::Content::Text::Line $line .= new: :$word-gap, :$height;
	@!lines = [ $line ];

        while @atoms {
            my subset StrOrImage where Str | PDF::Content::XObject;
            my StrOrImage $atom = @atoms.shift;
            my Bool $reserving = False;
	    my $word-width;
            my $word;
            my $pre-word-gap = $follows-ws ?? $word-gap !! 0.0;

            given $atom {
                when Str {
                    if ($!style.kern) {
                        ($word, $word-width) = $!style.font.kern($atom);
                    }
                    else {
                        $word = [ $atom, ];
                        $word-width = $!style.font.stringwidth($atom);
                    }
                    $word-width *= $!style.font-size * $.HorizScaling / 100000;
                    $word-width += ($atom.chars - 1) * $.CharSpacing
                        if $.CharSpacing > -$!style.font-size;

                    for $word.list {
                        when Str {
                            $_ = $!style.font.encode($_, :str);
                        }
                        when Numeric {
                            $_ = -$_;
                        }
                    }
                }
                when PDF::Content::XObject {
                    $reserving = True;
                    $word = [-$atom.width * $.HorizScaling * 10 / $!style.font-size, ];
                    $word-width = $atom.width;
                }
            }

            if $!width && $line.words && $line.content-width + $pre-word-gap + $word-width > $!width {
                # line break
                $line = $line.new: :$word-gap, :$height;
                @!lines.push: $line;
                @line-atoms = [];
                $follows-ws = False;
                $pre-word-gap = 0;
            }
            if $reserving {
                my $height = $atom.height;
                $line.height = $height
                    if $height > $line.height;
            }
            if $!height && self.content-height > $!height {
                # height exceeded
                @!lines.pop if @!lines;
                @!overflow.append: @line-atoms;
                last;
            }

            if $reserving {
                my $Tx = $line.content-width + $pre-word-gap;
                my $Ty = @!lines
                    ?? @!lines[0].height * $.leading  -  self.content-height
                    !! 0.0;
                @!images.push( { :$Tx, :$Ty, :xobject($atom) } )
            }

            @line-atoms.push: $atom;
            $line.word-boundary[+$line.words] = $follows-ws;
            $line.words.push: $word;
            $line.word-width += $word-width;
	    $line.height = $height
		if $height > $line.height;

            $follows-ws = flush-space(@atoms);
        }

        @!overflow.append: @atoms;

    }

    sub flush-space(@words) returns Bool {
        my Bool \flush = ? (@words && @words[0] ~~ /<Text::space>/);
        @words.shift if flush;
        flush;
    }

    #| calculates actual spacing between words
    method !word-gap returns Numeric {
        my $word-gap = $.space-width + $.WordSpacing + $.CharSpacing;
        $word-gap * $.HorizScaling / 100;
    }

    #| calculates ShowSpaceText(TD) atom for the given word-gap
    method !word-spacer($word-gap is copy) {
        if $word-gap =~= $.space-width && $.WordSpacing =~= 0 && $.CharSpacing =~= 0 {
            # A real space fits. use it.
            $!style.space;
        }
        else {
            my Numeric \scale = -1000 / $.font-size;
            $word-gap /= $.HorizScaling / 100
                unless $.HorizScaling =~= 100;
            scale * ($word-gap - $.CharSpacing);
        }
    }

    method width  { $!width  // self.content-width }
    method height { $!height // self.content-height }
    method !dy {
        given $!valign {
            when 'center' { 0.5 }
            when 'bottom' { 1.0 }
            default       { 0 }
        };
    }
    method top-offset {
        self!dy * ($.height - $.content-height);
    }

    method render(
	PDF::Content::Ops $gfx,
	Bool :$nl,   # add trailing line
	Bool :$top,  # position from top
	Bool :$left, # position from left
	Bool :$preserve = True, # restore text state
	) {
	my %saved;
	for :$.CharSpacing, :$.HorizScaling, :$.TextRise {
	    my $gfx-val = $gfx."{.key}"();
	    %saved{.key} = $gfx-val
		if $preserve;
	    $gfx."Set{.key}"(.value)
		unless .value =~= $gfx-val;
	}

        my $width = $!width // self.content-width
            if $!align eq 'justify';

        .align($!align, :$width )
            for @!lines;

        my @content;
	my $space-size = -(1000 * $.space-width / $.font-size).round.Int;

        my $y-shift = $top ?? - $.top-offset !! self!dy * $.height;
        @content.push( OpCode::TextMove => [0, $y-shift ] )
            unless $y-shift =~= 0.0;

        my $dx = do given $!align {
            when 'center' { 0.5 }
            when 'right'  { 1.0 }
            default       { 0.0 }
        }
        my $x-shift = $left ?? $dx * $.width !! 0.0;
        # compute text positions of images content
        for @!images {
            my Numeric @Tm[6] = $gfx.TextMatrix.list;
            @Tm[4] += $x-shift + .<Tx> + $.TextRise;
            @Tm[5] += $y-shift + .<Ty>;
            .<Tm> = @Tm;
        }

        my $leading = $gfx.TextLeading;

        for @!lines.pairs {
	    my \line = .value;

	    if .key {
		@content.push: ( OpCode::SetTextLeading => [ $leading = line.height * $.leading ] )
		    if $leading !=~= line.height * $.leading;
		@content.push: OpCode::TextNextLine;
	    }

            my $space = self!word-spacer(line.word-gap);
            @content.push: line.content(:$.font-size, :$x-shift, :$space);
        }

	if $nl {
	    my $height = @!lines ?? @!lines[*-1].height !! $.font-size;
	    @content.push: ( OpCode::SetTextLeading => [ $leading = $height * $.leading ] )
                unless $.font-size * $.leading =~= $leading;
	    @content.push: OpCode::TextNextLine;
	}

        $gfx.ops: @content;
        # restore original values
	for %saved.pairs {
	    $gfx."Set{.key}"(.value)
                unless $gfx."{.key}"() == .value;
	}

	@content;
    }

    # flow any xobject images. This needs to be done
    # after rendering and exiting text block
    method place-images($gfx) {
        for self.images {
            $gfx.Save;
            $gfx.ConcatMatrix(|.<Tm>);
            .<xobject>.finish;
            $gfx.XObject($gfx.resource-key(.<xobject>));
            $gfx.Restore;
        }
    }

}
