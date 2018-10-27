unit module Trait::IO;
use nqp;

my constant auto-close is export = class {};

multi sub trait_mod:<does>(Variable:D $v, auto-close) is export {
    $v.block.add_phaser: 'LEAVE', $v.willdo: {
        try nqp::atkey(
          nqp::ctxcaller(
            nqp::ctxcaller(
              nqp::ctxcaller(
                nqp::ctxcaller(
                  nqp::ctxcaller(
                    nqp::ctx()))))),
          $v.name
        ).close
    }
}
