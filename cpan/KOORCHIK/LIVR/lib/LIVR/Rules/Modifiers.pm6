unit module LIVR::Rules::Modifiers;
use LIVR::Utils;

our sub trim([], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value) || ($value !~~ Str && $value !~~ Numeric);
        
        $output = $value.trim;
        return;
    };
}

our sub to_lc([], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value) || ($value !~~ Str && $value !~~ Numeric);
        
        $output = $value.lc;
        return;
    };
}

our sub to_uc([], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value) || ($value !~~ Str && $value !~~ Numeric);
        
        $output = $value.uc;
        return;
    };
}

our sub remove([Str $chars], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value) || ($value !~~ Str && $value !~~ Numeric);
        
        $output = $value.trans( $chars.Str => '', :delete );
        return;
    };
}

our sub leave_only([Str $chars], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value) || ($value !~~ Str && $value !~~ Numeric);
        
        my $chars-set = set($chars.comb);
        $output= $value.comb.grep(-> $c { $chars-set{$c} }).join('');

        # Does not work. Bug in Perl6 https://github.com/rakudo/rakudo/issues/1227
        # $output = $value.trans( $chars.Str => '',   :complement, :delete ); 
        
        return;
    };
}

our sub default([Cool $default-value], %builders) {
    return sub ($value, %all-values, $output is rw) {
        
        if is-no-value($value) {
            $output = $default-value;
        }
        
        return;
    };
}
