sub EXPORT($c? ) {
    %( do ('ISO_32000-' ~ $c) => (require ::('ISO_32000')::($c)) if $c)
}
module ISO_32000 {
}
