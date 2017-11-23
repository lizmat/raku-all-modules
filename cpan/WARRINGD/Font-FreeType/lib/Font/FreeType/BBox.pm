class Font::FreeType::BBox {

    use Font::FreeType::Native;

    has Numeric  ($.x-min, $.y-min);
    has Numeric  ($.x-max, $.y-max);

    constant Dpi = 72.0;
    constant Px = 64.0;

    submethod TWEAK(FT_BBox :$bbox!) {
        with $bbox {
            $!x-min = .x-min / Px;
            $!x-max = .x-max / Px;
            $!y-min = .y-min / Px;
            $!y-max = .y-max / Px;
        }
    }

    method Array {
        [$!x-min, $!y-min, $!x-max, $!y-max];
    }
}
