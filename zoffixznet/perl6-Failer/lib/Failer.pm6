unit module Failer;
use nqp;

sub no-fail ($v) is export {
    nqp::if(
        nqp::istype($v, Failure),
        nqp::throwpayloadlexcaller(nqp::const::CONTROL_RETURN, $v),
        $v,
    )
}
sub postfix:<∨-fail> ($v) is prec(:prec(&[orelse].prec.<prec>)) is export {
    nqp::if(
        nqp::istype($v, Failure),
        nqp::throwpayloadlexcaller(nqp::const::CONTROL_RETURN, $v),
        Nil,
    )
}
sub prefix:<so-fail> ($v) is equiv(&prefix:<so>) is export {
    nqp::if( nqp::istype($v, Failure), False, so $v )
}
sub prefix:<de-fail> ($v) is equiv(&prefix:<so>) is export {
    nqp::if( nqp::istype($v, Failure), False, defined $v )
}
