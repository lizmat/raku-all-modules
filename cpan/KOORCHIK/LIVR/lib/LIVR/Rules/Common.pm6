unit module LIVR::Rules::Common;
use LIVR::Utils;

our sub required([], %builders) {
    return sub ($value, $all-values, $output is rw) {
        return 'REQUIRED' if is-no-value($value);
    };
}

our sub not_empty([], %builders) {
    return sub ($value, $all-values, $output is rw) {
        if $value.defined {
            return if $value ~~ Hash;
            return if $value ~~ Array;
            return "CANNOT_BE_EMPTY" if $value.defined && $value eq '';
        }
        
        return;
    };
}

our sub not_empty_list([], %builders) {
    return sub ($list, $all-values, $output is rw) {
        return 'CANNOT_BE_EMPTY' if !$list.defined || ($list ~~ Str && $list eq '');
        return 'FORMAT_ERROR' unless $list ~~ Array;
        return 'CANNOT_BE_EMPTY' unless $list.elems;
        return;
    }
}

our sub any_object([], %builders) {
    return sub ($value, $all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' unless $value ~~ Hash;
        return;
    }
}