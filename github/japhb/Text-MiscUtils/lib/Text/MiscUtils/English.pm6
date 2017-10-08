unit module Text::MiscUtils::English;


#| Choose singular or plural according to English pluralization rules
sub _s(Numeric:D $n, Str $plural = 's', Str $singular = '' --> Str) is export {
    $n.abs == 1 ?? $singular !! $plural
}

#| Convert an integer into an English ordinal
sub ordinal(Int:D $n --> Str:D) is export {
    given $n % 10 {
        when 1  { $n ~ 'st' }
        when 2  { $n ~ 'nd' }
        when 3  { $n ~ 'rd' }
        default { $n ~ 'th' }
    }
}
