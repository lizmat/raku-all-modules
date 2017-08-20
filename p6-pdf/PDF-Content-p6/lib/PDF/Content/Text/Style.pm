use v6;

class PDF::Content::Text::Style is rw {
    has         $.font is required;
    has Numeric $.font-size = 16;
    has Numeric $.leading = 1.1;
    has Bool $.kern;

    # directly mapped to graphics state
    has Numeric $.WordSpacing;
    has Numeric $.CharSpacing;
    has Numeric $.HorizScaling;
    has Numeric $.TextRise;

    my subset Baseline of Str is export(:BaseLine) where { !.defined || $_ eq 'alphabetic'|'top'|'bottom'|'middle'|'ideographic'|'hanging' };

    multi submethod TWEAK(:$gfx, Baseline :$baseline) is default {
        $!CharSpacing  //= do with $gfx {.CharSpacing}  else {0.0};
	$!WordSpacing  //= do with $gfx {.WordSpacing}  else {0.0};
	$!HorizScaling //= do with $gfx {.HorizScaling} else {100};
	$!TextRise     //= do with $baseline {
	    self.baseline-shift($_);
	} else {
	    with $gfx {.TextRise} else {0.0};
	}
    }

    method !baseline-height {  $!font.height( $!font-size, :from-baseline) }
    method baseline-shift(Baseline $_) {
	when 'alphabetic'  { 0 }
	when 'top'         { - self!baseline-height }
	when 'bottom'      {   $!font.height( $!font-size)   - self!baseline-height }
	when 'middle'      {   $!font.height( $!font-size)/2 - self!baseline-height }
	when 'ideographic' {   $!font-size - self!baseline-height }
	when 'hanging'     { - self!baseline-height }
	default            { 0 }
    }

    method space-width { $!font.stringwidth(' ', $!font-size ); }
}
