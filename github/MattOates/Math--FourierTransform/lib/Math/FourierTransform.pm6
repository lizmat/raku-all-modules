unit module Math::FourierTransform;

sub discrete-fourier-transform(Complex @input) returns Array[Complex] is export {
    my Int $n = @input.elems;
    my Complex @output = 0i xx $n;
    for ^$n -> $k {
        my Complex $s = 0i;
        for ^$n -> $t {
            $s += @input[$t] * exp(-2i * pi * $t * $k / $n);
        }
        @output[$k] = $s;
    }
    return @output;
}
