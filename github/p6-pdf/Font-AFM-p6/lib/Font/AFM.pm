# This -*- perl6 -*-  module is a simple parser for Adobe Font Metrics files.

class Font::AFM {

=begin pod

=head1 NAME

Font::AFM - Interface to Adobe Font Metrics files

=head1 SYNOPSIS

 use Font::AFM;
 my $h = Font::AFM.new: :name<Helvetica>;
 my $copyright = $h.Notice;
 my $w = $h.Wx<aring>;
 $w = $h.stringwidth("Gisle", 10);

=head1 DESCRIPTION

This module implements the Font::AFM class. Objects of this class are
initialised from an AFM (Adobe Font Metrics) file and allow you to obtain information about the font and the metrics of the various glyphs in the font.

All measurements in AFM files are given in terms of units equal to
1/1000 of the scale factor of the font being used. To compute actual
sizes in a document, these amounts should be multiplied by (scale
factor of font)/1000.

=head3 Font Metrics Classes

This module includes built-in classes for the 14 PDF Core Fonts:

    use Font::Metrics::helvetica;
    my $bbox = Font::Metrics::helvetica.FontBBox;

The list of available fonts is:
=over 3

=item Courier Fonts
    Font::Metrics::courier
    Font::Metrics::courier-bold
    Font::Metrics::courier-oblique
    Font::Metrics::courier-boldoblique
=item Helvetica Fonts
    Font::Metrics::helvetica
    Font::Metrics::helvetica-bold
    Font::Metrics::helvetica-oblique
    Font::Metrics::helvetica-boldoblique
=item Times-Roman Fonts
    Font::Metrics::times-roman
    Font::Metrics::times-bold
    Font::Metrics::times-italic
    Font::Metrics::times-bolditalic
=item Symbolic Fonts
    Font::Metrics::symbol
    Font::Metrics::zapfdingbats
=back

=head2 Methods

=over 3

=item my $afm = Font::AFM.new: :$name;

Object constructor. Takes the name of the font as argument.
Croaks if the font can not be found.

=item $afm.stringwidth($string, $fontsize?, :kern, :%glyphs)

Returns the width of the string passed as argument. The
string is assumed to contains only characters from `%glyphs`
A second argument can be used to scale the width according to
the font size.

=item ($kerned, $width) = $afm.kern($string, $fontsize?, :%glyphs?)

Kern the string. Returns an array of string segments, separated
by numeric kerning distances, and the overall width of the string.

       :%glyphs            - an optional mapping of characters to glyph-names.

=item $afm.FontName

The name of the font as presented to the PostScript language
C<findfont> operator, for instance "Times-Roman".

=item $afm.FullName

Unique, human-readable name for an individual font, for instance
"Times Roman".

=item $afm.FamilyName

Human-readable name for a group of fonts that are stylistic variants
of a single design. All fonts that are members of such a group should
have exactly the same C<FamilyName>. Example of a family name is
"Times".

=item $afm.Weight

Human-readable name for the weight, or "boldness", attribute of a font.
Examples are C<Roman>, C<Bold>, C<Light>.

=item $afm.ItalicAngle

Angle in degrees counterclockwise from the vertical of the dominant
vertical strokes of the font.

=item $afm.IsFixedPitch

If C<true>, the font is a fixed-pitch
(monospaced) font.

=item $afm.FontBBox

An array of integers giving the lower-left x, lower-left y,
upper-right x, and upper-right y of the font bounding box. The font
bounding box is the smallest rectangle enclosing the shape that would
result if all the characters of the font were placed with their
origins coincident, and then painted.

=item $afm.KernData

A two dimensional hash containing from and to glyphs and kerning widths.

=item $afm.UnderlinePosition

Recommended distance from the baseline for positioning underline
strokes. This number is the y coordinate of the center of the stroke.

=item $afm.UnderlineThickness

Recommended stroke width for underlining.

=item $afm.Version

Version number of the font.

=item $afm.Notice

Trademark or copyright notice, if applicable.

=item $afm.Comment

Comments found in the AFM file.

=item $afm.EncodingScheme

The name of the standard encoding scheme for the font. Most Adobe
fonts use the C<AdobeStandardEncoding>. Special fonts might state
C<FontSpecific>.

=item $afm.CapHeight

Usually the y-value of the top of the capital H.

=item $afm.XHeight

Typically the y-value of the top of the lowercase x.

=item $afm.Ascender

Typically the y-value of the top of the lowercase d.

=item $afm.Descender

Typically the y-value of the bottom of the lowercase p.

=item $afm.Wx

Returns a hash table that maps from glyph names to the width of that glyph.

=item $afm.BBox

Returns a hash table that maps from glyph names to bounding box information.
The bounding box consist of four numbers: llx, lly, urx, ury.

=back

The AFM specification can be found at:

   http://partners.adobe.com/asn/developer/pdfs/tn/5004.AFM_Spec.pdf


=head1 ENVIRONMENT

=over 10

=item METRICS

Contains the path to search for AFM-files.  Format is as for the PATH
environment variable. The default path built into this library is:

 /usr/lib/afm:/usr/local/lib/afm:/usr/openwin/lib/fonts/afm/:.

=back


=head1 BUGS

Composite character and Ligature data are not parsed.


=head1 COPYRIGHT

Copyright 1995-1998 Gisle Aas. All rights reserved.

Ported from Perl 5 to 6 by David Warring Copyright 2015

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=end pod

    #-------perl 6 resumes here--------------------------------------------

    has %.metrics;
    # Creates a new Font::AFM object from an AFM file.  Pass it the name of the
    # font as parameter.
    # Synopisis:
    #
    #    $h = Font::AFM.new: :name<Helvetica>;
    #

    method class-name(Str $font-name --> Str) {
        [~] "Font::Metrics::", $font-name.lc.subst( /['.afm'$]/, '');
    }

    #| autoloads the appropriate delegate for the named font. A subclass of Font::AFM
    method metrics-class(Str $font-name --> Font::AFM:U) {
        my $class-name = self.class-name($font-name);
        require ::($class-name);
    }

    #| creates a delegate object for the named font.
    method core-font(Str $font-name --> Font::AFM:D) {
        my $class = self.metrics-class($font-name);
        $class.new;
    }

    submethod TWEAK( Str :$name) {
        self!load-afm-metrics($_) with $name;
    }

    # full list of properties
    # see http://partners.adobe.com/asn/developer/pdfs/tn/5004.AFM_Spec.pdf
    constant %Props = %(
         :FontName(Str), :FullName(Str), :FamilyName(Str),:Weight(Str), :ItalicAngle(Num),
         :IsFixedPitch(Bool), :FontBBox(Array[Int]), :UnderlinePosition(Int), :UnderlineThickness(Int),
         :Version(Version), :Notice(Str), :Comment(Str), :EncodingScheme(Str), :CapHeight(Int),
         :XHeight(Int), :Ascender(Int), :Descender(Int), :StdHw(Num), :StdVW(Num),
         :MappingScheme(Int), :EscChar(Int), :CharacterSet(Str), :Characters(Str), :IsBaseFont(Bool),
         :VVector(Array[Num]), :IsFixedV(Bool), :IsCIDFont(Bool)
    );

    method !coerce(Str $key, Str $val) {
        %Props{$key}:exists
            ?? do given %Props{$key} {
                when $val ~~ $_ { $val }
                when Bool       { $val ~~ 'true' }
                when Int        { $val.Int }
                when Num        { $val.Num }
                when Array[Int] { [ $val.comb(/[<[+-]>|\w|"."]+/).map(*.Int) ] }
                when Array[Num] { [ $val.comb(/[<[+-]>|\w|"."]+/).map(*.Num) ] }
                when Version    { Version.new($val) }
                default { warn "don't know how to convert $key:{$val.perl} of type {.perl}"; $val }
            }
            !! $val
    }

    method !load-afm-metrics(Str $name) {
       %!metrics = ();

       $name ~~ s/'.afm' $//;
       my $file;

      if ~$*DISTRO ~~ m:i{^VMS} {
           # Perl 5 porters note: Perl 6 on VMS?
           $file = [~] 'sys$ps_font_metrics:', $name, '.afm';
       } else {
           $file = $name ~ '.afm';
           unless $*SPEC.is-absolute($file) {
               # not absolute, search the metrics path for the file
               my @metrics-path = do with %*ENV<METRICS> {
                   .split(/\:/)>>.subst(rx{'/'$},'')
               }
               else {
                   < /usr/lib/afm  /usr/local/lib/afm
                      /usr/openwin/lib/fonts/afm  . >;
               }
               $file = $_
                   with (@metrics-path\
                         .map({ $*SPEC.catfile( $_, $file) })\
                         .first: { .IO ~~ :f });
           }
       }

       die "Can't find the AFM file for $name ($file)"
           unless $file.IO ~~ :e;

       my $afm = $file.IO.open( :r );

       for $afm.lines {

           if /^StartKernData/ ff /^EndKernData/ {
               next unless m:s/ <|w> KPX  $<glyph1>=['.'?\w+] $<glyph2>=['.'?\w+] $<kern>=[< + - >?\d+] /;
               %!metrics<KernData>{ $<glyph1> }{ $<glyph2> } = $<kern>.Int;
               next;
           }
           next if /^StartComposites/ ff /^EndComposites/; # same for composites
           if /^StartCharMetrics/     ff /^EndCharMetrics/ {
               # only lines that start with "C" or "CH" are parsed
               next unless /^ CH? ' ' /;
               my Str $name  = ~ m:s/ <|w> N  <('.'?\w+)> ';' /;
               my Numeric $wx    = + m:s/ <|w> WX <(\d+)>     ';' /;
               warn "no bbox: $_"
                   unless m:s/ <|w> B [ (< + - >?\d+) ]+ ';' /;
               my Array $bbox = [ @0.map: { .Int } ];
               # Should also parse lingature data (format: L successor lignature)
               %!metrics<Wx>{$name} = $wx;
               %!metrics<BBox>{$name} = $bbox;
               next;
           }

           last if /^EndFontMetrics/;

           if /(^\w+)' '+(.*)/ {
               my Str $key = ~ $0;
               my Str $val = ~ $1;
               if %!metrics{$key} ~~ Str {
                   %!metrics{$key} ~= "\n" ~ self!coerce($key, $val);
               }
               else {
                   %!metrics{$key} = self!coerce($key, $val);
               }
           } else {
               die "Can't parse: $_";
           }
       }

       $afm.close;

       unless %!metrics<Wx><.notdef>:exists {
           %!metrics<Wx><.notdef> = 0;
           %!metrics<BBox><.notdef> = [ 0, 0, 0, 0];
       }
    }

    # generated by: cd etc/ && perl6 make-glyphlist.pl --subset

    constant %Glyphs = {" " => "space", "!" => "exclam", "\"" =>
    "quotedbl", "#" => "numbersign", "\$" => "dollar", "\%" =>
    "percent", "\&" => "ampersand", "'" => "quotesingle", "(" =>
    "parenleft", ")" => "parenright", "*" => "asterisk", "+" =>
    "plus", "," => "comma", "-" => "hyphen", "." => "period", "/" =>
    "slash", "0" => "zero", "1" => "one", "2" => "two", "3" =>
    "three", "4" => "four", "5" => "five", "6" => "six", "7" =>
    "seven", "8" => "eight", "9" => "nine", ":" => "colon", ";" =>
    "semicolon", "<" => "less", "=" => "equal", ">" => "greater", "?"
    => "question", "\@" => "at", :A("A"), :B("B"), :C("C"), :D("D"),
    :E("E"), :F("F"), :G("G"), :H("H"), :I("I"), :J("J"), :K("K"),
    :L("L"), :M("M"), :N("N"), :O("O"), :P("P"), :Q("Q"), :R("R"),
    :S("S"), :T("T"), :U("U"), :V("V"), :W("W"), :X("X"), :Y("Y"),
    :Z("Z"), "[" => "bracketleft", "\\" => "backslash", "]" =>
    "bracketright", "^" => "asciicircum", :_("underscore"), "`" =>
    "grave", :a("a"), :b("b"), :c("c"), :d("d"), :e("e"), :f("f"),
    :g("g"), :h("h"), :i("i"), :j("j"), :k("k"), :l("l"), :m("m"),
    :n("n"), :o("o"), :p("p"), :q("q"), :r("r"), :s("s"), :t("t"),
    :u("u"), :v("v"), :w("w"), :x("x"), :y("y"), :z("z"), "\{" =>
    "braceleft", "|" => "bar", "}" => "braceright", "~" =>
    "asciitilde", "¡" => "exclamdown", "¢" => "cent", "£" =>
    "sterling", "¤" => "currency", "¥" => "yen", "¦" => "brokenbar",
    "§" => "section", "¨" => "dieresis", "©" => "copyright",
    :ª("ordfeminine"), "«" => "guillemotleft", "¬" => "logicalnot",
    "®" => "registered", "¯" => "macron", "°" => "degree", "±" =>
    "plusminus", "²" => "twosuperior", "³" => "threesuperior", "´" =>
    "acute", :µ("mu"), "¶" => "paragraph", "·" => "periodcentered",
    "¸" => "cedilla", "¹" => "onesuperior", :º("ordmasculine"), "»" =>
    "guillemotright", "¼" => "onequarter", "½" => "onehalf", "¾" =>
    "threequarters", "¿" => "questiondown", :À("Agrave"),
    :Á("Aacute"), :Â("Acircumflex"), :Ã("Atilde"), :Ä("Adieresis"),
    :Å("Aring"), :Æ("AE"), :Ç("Ccedilla"), :È("Egrave"), :É("Eacute"),
    :Ê("Ecircumflex"), :Ë("Edieresis"), :Ì("Igrave"), :Í("Iacute"),
    :Î("Icircumflex"), :Ï("Idieresis"), :Ð("Eth"), :Ñ("Ntilde"),
    :Ò("Ograve"), :Ó("Oacute"), :Ô("Ocircumflex"), :Õ("Otilde"),
    :Ö("Odieresis"), "×" => "multiply", :Ø("Oslash"), :Ù("Ugrave"),
    :Ú("Uacute"), :Û("Ucircumflex"), :Ü("Udieresis"), :Ý("Yacute"),
    :Þ("Thorn"), :ß("germandbls"), :à("agrave"), :á("aacute"),
    :â("acircumflex"), :ã("atilde"), :ä("adieresis"), :å("aring"),
    :æ("ae"), :ç("ccedilla"), :è("egrave"), :é("eacute"),
    :ê("ecircumflex"), :ë("edieresis"), :ì("igrave"), :í("iacute"),
    :î("icircumflex"), :ï("idieresis"), :ð("eth"), :ñ("ntilde"),
    :ò("ograve"), :ó("oacute"), :ô("ocircumflex"), :õ("otilde"),
    :ö("odieresis"), "÷" => "divide", :ø("oslash"), :ù("ugrave"),
    :ú("uacute"), :û("ucircumflex"), :ü("udieresis"), :ý("yacute"),
    :þ("thorn"), :ÿ("ydieresis"), :Ā("Amacron"), :ā("amacron"),
    :Ă("Abreve"), :ă("abreve"), :Ą("Aogonek"), :ą("aogonek"),
    :Ć("Cacute"), :ć("cacute"), :Č("Ccaron"), :č("ccaron"),
    :Ď("Dcaron"), :ď("dcaron"), :Đ("Dcroat"), :đ("dcroat"),
    :Ē("Emacron"), :ē("emacron"), :Ė("Edotaccent"), :ė("edotaccent"),
    :Ę("Eogonek"), :ę("eogonek"), :Ě("Ecaron"), :ě("ecaron"),
    :Ğ("Gbreve"), :ğ("gbreve"), :Ģ("Gcommaaccent"),
    :ģ("gcommaaccent"), :Ī("Imacron"), :ī("imacron"), :Į("Iogonek"),
    :į("iogonek"), :İ("Idotaccent"), :ı("dotlessi"),
    :Ķ("Kcommaaccent"), :ķ("kcommaaccent"), :Ĺ("Lacute"),
    :ĺ("lacute"), :Ļ("Lcommaaccent"), :ļ("lcommaaccent"),
    :Ľ("Lcaron"), :ľ("lcaron"), :Ł("Lslash"), :ł("lslash"),
    :Ń("Nacute"), :ń("nacute"), :Ņ("Ncommaaccent"),
    :ņ("ncommaaccent"), :Ň("Ncaron"), :ň("ncaron"), :Ō("Omacron"),
    :ō("omacron"), :Ő("Ohungarumlaut"), :ő("ohungarumlaut"), :Œ("OE"),
    :œ("oe"), :Ŕ("Racute"), :ŕ("racute"), :Ŗ("Rcommaaccent"),
    :ŗ("rcommaaccent"), :Ř("Rcaron"), :ř("rcaron"), :Ś("Sacute"),
    :ś("sacute"), :Ş("Scedilla"), :ş("scedilla"), :Š("Scaron"),
    :š("scaron"), :Ţ("Tcommaaccent"), :ţ("tcommaaccent"),
    :Ť("Tcaron"), :ť("tcaron"), :Ū("Umacron"), :ū("umacron"),
    :Ů("Uring"), :ů("uring"), :Ű("Uhungarumlaut"),
    :ű("uhungarumlaut"), :Ų("Uogonek"), :ų("uogonek"),
    :Ÿ("Ydieresis"), :Ź("Zacute"), :ź("zacute"), :Ż("Zdotaccent"),
    :ż("zdotaccent"), :Ž("Zcaron"), :ž("zcaron"), :ƒ("florin"),
    :Ș("Scommaaccent"), :ș("scommaaccent"), :ˆ("circumflex"),
    :ˇ("caron"), "˘" => "breve", "˙" => "dotaccent", "˚" => "ring",
    "˛" => "ogonek", "˜" => "tilde", "˝" => "hungarumlaut",
    :Α("Alpha"), :Β("Beta"), :Γ("Gamma"), :Ε("Epsilon"), :Ζ("Zeta"),
    :Η("Eta"), :Θ("Theta"), :Ι("Iota"), :Κ("Kappa"), :Λ("Lambda"),
    :Μ("Mu"), :Ν("Nu"), :Ξ("Xi"), :Ο("Omicron"), :Π("Pi"), :Ρ("Rho"),
    :Σ("Sigma"), :Τ("Tau"), :Υ("Upsilon"), :Φ("Phi"), :Χ("Chi"),
    :Ψ("Psi"), :Ω("Omega"), :α("alpha"), :β("beta"), :γ("gamma"),
    :δ("delta"), :ε("epsilon"), :ζ("zeta"), :η("eta"), :θ("theta"),
    :ι("iota"), :κ("kappa"), :λ("lambda"), :ν("nu"), :ξ("xi"),
    :ο("omicron"), :π("pi"), :ρ("rho"), :ς("sigma1"), :σ("sigma"),
    :τ("tau"), :υ("upsilon"), :φ("phi"), :χ("chi"), :ψ("psi"),
    :ω("omega"), :ϑ("theta1"), :ϒ("Upsilon1"), :ϕ("phi1"),
    :ϖ("omega1"), "–" => "endash", "—" => "emdash", "‘" =>
    "quoteleft", "’" => "quoteright", "‚" => "quotesinglbase", "“" =>
    "quotedblleft", "”" => "quotedblright", "„" => "quotedblbase", "†"
    => "dagger", "‡" => "daggerdbl", "•" => "bullet", "…" =>
    "ellipsis", "‰" => "perthousand", "′" => "minute", "″" =>
    "second", "‹" => "guilsinglleft", "›" => "guilsinglright", "⁄" =>
    "fraction", "€" => "Euro", :ℑ("Ifraktur"), "℘" => "weierstrass",
    :ℜ("Rfraktur"), "™" => "trademark", :ℵ("aleph"), "←" =>
    "arrowleft", "↑" => "arrowup", "→" => "arrowright", "↓" =>
    "arrowdown", "↔" => "arrowboth", "↵" => "carriagereturn", "⇐" =>
    "arrowdblleft", "⇑" => "arrowdblup", "⇒" => "arrowdblright", "⇓"
    => "arrowdbldown", "⇔" => "arrowdblboth", "∀" => "universal", "∂"
    => "partialdiff", "∃" => "existential", "∅" => "emptyset", "∆" =>
    "Delta", "∇" => "gradient", "∈" => "element", "∉" => "notelement",
    "∋" => "suchthat", "∏" => "product", "∑" => "summation", "−" =>
    "minus", "∗" => "asteriskmath", "√" => "radical", "∝" =>
    "proportional", "∞" => "infinity", "∠" => "angle", "∧" =>
    "logicaland", "∨" => "logicalor", "∩" => "intersection", "∪" =>
    "union", "∫" => "integral", "∴" => "therefore", "∼" => "similar",
    "≅" => "congruent", "≈" => "approxequal", "≠" => "notequal", "≡"
    => "equivalence", "≤" => "lessequal", "≥" => "greaterequal", "⊂"
    => "propersubset", "⊃" => "propersuperset", "⊄" => "notsubset",
    "⊆" => "reflexsubset", "⊇" => "reflexsuperset", "⊕" =>
    "circleplus", "⊗" => "circlemultiply", "⊥" => "perpendicular", "⋅"
    => "dotmath", "⌠" => "integraltp", "⌡" => "integralbt", "◊" =>
    "lozenge", "♠" => "spade", "♣" => "club", "♥" => "heart", "♦" =>
    "diamond", "〈" => "angleleft", "〉" => "angleright", "" =>
    "commaaccent", "" => "copyrightserif", "" => "registerserif",
    "" => "trademarkserif", "" => "radicalex", "" => "arrowvertex",
    "" => "arrowhorizex", "" => "registersans", "" =>
    "copyrightsans", "" => "trademarksans", "" => "parenlefttp", ""
    => "parenleftex", "" => "parenleftbt", "" => "bracketlefttp",
    "" => "bracketleftex", "" => "bracketleftbt", "" =>
    "bracelefttp", "" => "braceleftmid", "" => "braceleftbt", "" =>
    "braceex", "" => "integralex", "" => "parenrighttp", "" =>
    "parenrightex", "" => "parenrightbt", "" => "bracketrighttp",
    "" => "bracketrightex", "" => "bracketrightbt", "" =>
    "bracerighttp", "" => "bracerightmid", "" => "bracerightbt", ""
    => "apple", :ﬁ("fi"), :ﬂ("fl"), :mu("μ") };

    #| compute the expected string-width at the given point size for this glyph set
    method stringwidth( Str $string,
                        Numeric $pointsize?,
                        Bool :$kern,                        #| including kerning adjustments
                        Hash :$glyphs = %Glyphs,
        --> Numeric ) {
        my Numeric $width = 0.0;
        my Str $prev-glyph;
        my Hash $kern-data;
        if $kern {
            $kern-data = $_ with self.KernData;
        }
        my Hash $wx = self.Wx;

        for $string.comb {
            my Str $glyph-name = $glyphs{$_} // next;
            $width += $wx{$glyph-name} // next;

            with $kern-data {
                with $prev-glyph && .{$prev-glyph} {
                    $width += $_ with .{$glyph-name};
                }
                $prev-glyph = $glyph-name;
            }
        }
        if ($pointsize) {
            $width *= $pointsize / 1000;
        }
        $width;
    }

    #| kern a string. decompose into an array of: ('string1', $kern , ..., 'stringn' )
    method kern( Str $string,
                 Numeric $pointsize?,
                 Hash :$glyphs = %Glyphs
        --> List ) {
        my Str $prev-glyph;
        my Str $str = '';
        my Numeric $stringwidth = 0;
        my @chunks;
        my Hash $kern-data = $_
            with self.KernData;
        my Hash $wx = self.Wx;

        for $string.comb {
            my Str $glyph-name = $glyphs{$_} // next;
            $stringwidth += $wx{$glyph-name} // next;

            with $kern-data {
                with $prev-glyph && .{$prev-glyph} {
                    with .{$glyph-name} -> $kerning is copy {
                        $stringwidth += $kerning;
                        $kerning *= $pointsize / 1000
                            if $pointsize;
                        @chunks.push: $str;
                        @chunks.push: $kerning;
                        $str = '';
                    }
                }
                $prev-glyph = $glyph-name;
            }

            $str ~= $_;
        }

        @chunks.push: $str
            if $str.chars;

        $stringwidth *= $pointsize / 1000
            if $pointsize;

        @chunks, $stringwidth;
    }

    method Wx { $.metrics<Wx> }
    method BBox { $.metrics<BBox> }
    method KernData { $.metrics<KernData> }

    method !is-prop(Str $prop-name --> Bool) {
        %Props{$prop-name}:exists;
    }

    method perl-gen(:$name = self.^name) {
        qq:to<--END-->
        use Font::AFM;

        class $name
            is Font::AFM \{
            method metrics \{ {$.metrics.perl} }
        \}
        --END--
    }

    method can(Str \name) {
        my @meth = callsame;
        if !@meth && self!is-prop(name) {
            # vivify property accessor method
            @meth.push: method { $.metrics{name} };
            self.^add_method(name,  @meth[0]);
        }
        @meth;
    }

    method dispatch:<.?>(\name, |c) is raw {
        self.can(name) ?? self."{name}"(|c) !! Nil
    }
    method FALLBACK(Str $method, |c) {
        self.can($method)
            ?? self."$method"(|c)
            !! die die X::Method::NotFound.new( :$method, :typename(self.^name) );
    }
}
