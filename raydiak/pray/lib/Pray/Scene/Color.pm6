class Pray::Scene::Color;

has Real $.r = 0;
has Real $.g = 0;
has Real $.b = 0;

our sub rgb ($r, $g, $b) is export {
    $?CLASS.bless: :$r, :$g, :$b
}

our sub black () is export { rgb(0, 0, 0) }
our sub white () is export { rgb(1, 1, 1) }

method add (Pray::Scene::Color $color) {
    rgb(
        $!r + $color.r,
        $!g + $color.g,
        $!b + $color.b
    )
}

multi method scale (Numeric $scalar) {
    rgb(
        $!r * $scalar,
        $!g * $scalar,
        $!b * $scalar
    )
}

multi method scale (Pray::Scene::Color $c) {
    rgb(
        $!r * $c.r,
        $!g * $c.g,
        $!b * $c.b
    )
}

method clip_low {
    rgb(
        ($!r, 0).max,
        ($!g, 0).max,
        ($!b, 0).max,
    )
}

method clip_high {
    my %channels = :$!r, :$!g, :$!b;
    
    my $max = %channels.values.max;
    return self.clone if $max <= 1;

    my $value = [+] %channels.values;
    return rgb(1,1,1) if $value >= 3;
    
    my $over  = [+] %channels.values.map: { $_ > 1 ?? $_-1 !! () };
    my $under = [+] %channels.values.map: { $_ < 1 ?? 1-$_ !! () };
    my $fill_ratio = $over / $under;

    for %channels.values {
        when {$_ > 1} { $_ = 1 }
        when {$_ < 1} { $_ += (1-$_) * $fill_ratio }
    }

    rgb(
        %channels<r>,
        %channels<g>,
        %channels<b>
    );
}

method clip {
    self.clip_low.clip_high
}

method is_black () { $!r <= 0 && $!g <= 0 && $!b <= 0 }

method is_white () { $!r >= 1 && $!g >= 1 && $!b >= 1 }

method brightness () { ($!r + $!g + $!b) / 3 }
