use v6;
module PDF::Content::Color {

    use Color;

    my Array enum ColorName is export(:ColorName) «
        :Aqua[0, 1, 1]      :Black[0, 0, 0]
        :Blue[0, 0, 1]      :Fuchsia[1, 0, 1]
        :Gray[.5, .5, .5]   :Green[0, .5, 0]
        :Lime[0, 1, 0]      :Maroon[.5, 0, 0]
        :Navy[0, 0, .5]     :Olive[.5, .5, 0]
        :Orange[1, 0.65, 0] :Purple[.5, 0, .5]
        :Red[1, 0, 0]       :Silver[.75, .75, .75]
        :Teal[0, .5, .5]    :White[1, 1, 1]
        :Yellow[1, 1, 0]    :Cyan[0, 1, 1]
        :Magenta[1, 0, 1]   :Registration[1, 1, 1, 1]
       »;

    our sub rgb(\r, \g, \b) is export(:rgb) {
        :DeviceRGB[r, g, b]
    }
    our sub cmyk(\c, \m, \y, \k) is export(:cmyk) {
        :DeviceCMYK[c, m, y, k];
    }
    our sub gray(\g) is export(:gray) {
        :DeviceGray[g];
    }

    our proto sub color($) is export(:color) {*};
    multi sub color(Color $_) { color([.rgb]) }
    multi sub color(List $_) {
        when .max >= 2   {color .map(*/255).list}
        when .elems == 4 {cmyk(|$_)}
        when .elems == 3 {rgb(|$_)}
        when .elems == 1 {gray(.[0])}
    }
    multi sub color(Str $_) {
        when /^'#'<xdigit>**3$/ { rgb( |@<xdigit>.map({:16(.Str ~ .Str) / 255 })) }
        when /^'#'<xdigit>**6$/ { rgb( |@<xdigit>.map({:16($^a.Str ~ $^b.Str) / 255 })) }
        when /^'%'<xdigit>**4$/ { cmyk( |@<xdigit>.map({:16(.Str ~ .Str) / 255 })) }
        when /^'%'<xdigit>**8$/ { cmyk( |@<xdigit>.map({:16($^a.Str ~ $^b.Str) / 255 })) }
        default { warn "unrecognized color: $_"; gray(1) }
    }
}
