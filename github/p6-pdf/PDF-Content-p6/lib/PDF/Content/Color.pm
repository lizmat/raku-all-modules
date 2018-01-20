use v6;
module PDF::Content::Color {

    use Color;

    my Array enum ColorName is export(:ColorName) «
        :Cyan[1, 0, 0, 0]    :Magenta[0, 1, 0, 0]
        :Yellow[0, 0, 1, 0]  :Black[0, 0, 0, 1]
        :White[0, 0, 0, 0]   :Registration[1, 1, 1, 1]
        :Aqua[1, 0, 0, 0]    :Blue[1, 1, 0, 0]
        :Fuchsia[0, 1, 0, 0] :Gray[0, 0, 0, .5]
        :Green[1, 0, 1, .5]  :Lime[1, 0, 1, 0]
        :Maroon[0, 1, 1, .5] :Navy[1, 1, 0, .5]
        :Olive[0, 0, 1, .5]  :Purple[0, 1, 0, .5]
        :Red[0, 1, 1, 0]     :Silver[0, 0, 0, .25]
        :Teal[1, 0, 0, .5]
       »;
    constant %CMYK = ColorName.enums.Hash;

    sub rgb(\r, \g, \b) {
        :DeviceRGB[r, g, b]
    }
    sub cmyk(\c, \m, \y, \k) {
        :DeviceCMYK[c, m, y, k];
    }
    sub gray(\g) {
        :DeviceGray[g];
    }

    proto sub color($) is export(:color) {*};
    multi sub color(Color $_) { color([.rgb]) }
    multi sub color(List $_) {
        when .max >= 2   {color .map(*/255).list}
        when .elems == 4 {cmyk(|$_)}
        when .elems == 3 {rgb(|$_)}
        when .elems == 1 {gray(.[0])}
    }
    multi sub color(Str $_) {
        when %CMYK{.lc}:exists  { cmyk: |%CMYK{.lc} }
        when /^'#'<xdigit>**3$/ { rgb( |@<xdigit>.map({:16(.Str ~ .Str) / 255 })) }
        when /^'#'<xdigit>**6$/ { rgb( |@<xdigit>.map({:16($^a.Str ~ $^b.Str) / 255 })) }
        when /^'%'<xdigit>**4$/ { cmyk( |@<xdigit>.map({:16(.Str ~ .Str) / 255 })) }
        when /^'%'<xdigit>**8$/ { cmyk( |@<xdigit>.map({:16($^a.Str ~ $^b.Str) / 255 })) }
        default { warn "unrecognized color: $_"; :gray(1) }
    }
}
