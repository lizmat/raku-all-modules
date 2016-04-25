unit module Subset::Helper;

sub subset-is (&check, Str $message = '') is export {
    return sub ($v){
        $v.defined
            ?? ( &check($v) or note $message ~ " Got $v" and False )
            !! True
    };
}