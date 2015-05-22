sub EXPORT {
    for @_ || BEGIN <assert dbg logger> {
        %*ENV{"PERL6_DEBUG_{ .uc }"} = '1';
    }

    once EnumMap.new;
}
