=NAME Control::Bail - Defer cleanup code

=begin SYNOPSIS
=begin code

    # In the following code:
    # If there was a touchdown there is cheering
    # ...then...
    # The Receiver gets an icepack, but only if he was tackled.
    # ...then...
    # A streaker runs across the field, no matter what.
    # ...then...
    # The Receiver always gets juice, unless the QB was sacked.
    # ...then...
    # The QB always gets taunted, unless there was a touchdown.
    # ...then...
    # If there was no touchdown, the failure is thrown.
    use Control::Bail;
    sub towlboy {
        bail { say "Taunt the QB" }
        Bool.pick or die "sacked!";
        trail { say "Bring Receiver juice" }
        LEAVE { say "Streaker runs across field" }
        bail { say "Bring Receiver icepack" }
        Bool.pick or die "tackled!";
        say "touchdown!";
    }
    towlboy();


=end code
=end SYNOPSIS

=begin DESCRIPTION

Using this module adds some control statements to Perl6 syntax:

The C<bail> statement places the closure following it onto the
C<LEAVE> queue, like the C<UNDO> phaser -- the closures will
be run only if the current block exits unsuccessfully.

Unlike the C<UNDO> phaser, the closures will not actually run
unless control flow actually reaches the C<bail> statement at
runtime.  Order with respect to normal C<LEAVE/KEEP/UNDO>
statements is still preserved.  A C<bail> statement is roughly
equivalent to:

    my $run-this = False;
    $run-this = True;
    UNDO { if $run-this { ... } }

This allows nested allocations of resources to be released in
an orderly fashion, without repeating yourself, with no deep block
nesting and with deallocation code placed next to the corresponding
allocation code.  It is a bit like the "defer" statement in go
and swift, but with the added feature that it automatically
cancels itself if the block is left normally.

The C<trail> statement is the same, but places the closure on the
C<LEAVE> queue as a plain C<LEAVE> phaser would do (it always runs,
whether the block exits successfully or not.)  The C<trail-keep>
is probably not very useful, but is included for completeness. 
It is the same, but places the closure as the C<KEEP> phaser would
do (it runs only when the block exits successfully.)

A C<trail-undo> and C<trail-leave> statement are also provided.
They are synonyms for C<bail> and C<trail> respectively, just for
the sake of naming preferences.

=end DESCRIPTION

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2016 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=SEE-ALSO C<perl6::(1)>

use nqp;
use QAST:from<NQP>;
sub EXPORT(|) {
    my sub lk(Mu \h, \k) {
        nqp::atkey(nqp::findmethod(h, 'hash')(h), k)
    }
    role Control::Bail {
        rule statement_control:sym<bail> {
            <sym><.kok> <blorst>
        }
        rule statement_control:sym<trail> {
            <sym><.kok> <blorst>
        }
        rule statement_control:sym<trail-keep> {
            <sym><.kok> <blorst>
        }
        rule statement_control:sym<trail-undo> {
            <sym><.kok> <blorst>
        }
        rule statement_control:sym<trail-leave> {
            <sym><.kok> <blorst>
        }
    }
    role Control::Bail::Actions {
        sub add_phaser($cond, |c) {
            $/ := c[0];
            my $switch := QAST::Node.unique('runtime_leave');
            my $block := QAST::Block.new(
                 QAST::Stmts.new(
                      QAST::Op.new(:op<if>, QAST::Var.new( :name($switch), :scope<lexical>),
                          QAST::Op.new(:op<call>, lk($/,'blorst').ast))
                 )
            );
            nqp::atpos($*W.cur_lexpad(),0).push($block); # Should we?  Should we pop it after?
            my $sig := $*W.create_signature(nqp::hash('parameter_objects', nqp::list()));
            my $code := $*W.stub_code_object('Block');
            $*W.attach_signature($code, $sig);
            $*W.finish_code_object($code, $block);
            $*W.add_phaser($/, $cond, $code);
            $/.make(
                QAST::Stmts.new(
                    QAST::Var.new(:name($switch), :scope<lexical>, :decl<var>),
                    QAST::Op.new(:op<bind>, QAST::Var.new(:name($switch), :scope<lexical>), QAST::WVal.new(:value(1)))
                )
            )
        }
        method statement_control:sym<bail> (|c) {
            add_phaser('UNDO', c[0]);
        }
        method statement_control:sym<trail> (|c) {
            add_phaser('LEAVE', c[0]);
        }
        method statement_control:sym<trail-undo> (|c) {
            add_phaser('UNDO', c[0]);
        }
        method statement_control:sym<trail-keep> (|c) {
            add_phaser('KEEP', c[0]);
        }
        method statement_control:sym<trail-leave> (|c) {
            add_phaser('LEAVE', c[0]);
        }


    }

    my Mu $MAIN-grammar := nqp::atkey(%*LANG, 'MAIN');
    my $grammar := $MAIN-grammar.^mixin(Control::Bail);
    my Mu $MAIN-actions := nqp::atkey(%*LANG, 'MAIN-actions');
    my $actions := $MAIN-actions.^mixin(Control::Bail::Actions);

    # old way
    try {
        nqp::bindkey(%*LANG, 'MAIN', $grammar);
        nqp::bindkey(%*LANG, 'MAIN-actions', $actions);
    }
    # new way
    try $*LANG.define_slang("MAIN", $grammar, $actions);
    {}
}
