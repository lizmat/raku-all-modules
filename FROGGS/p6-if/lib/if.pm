use v6;
use nqp;
use QAST:from<NQP>;

sub find_symbol(@arr) {
    $*W.find_symbol(nqp::gethllsym("nqp", "nqplist")(|@arr))
}
multi sub postcircumfix:<{ }>( NQPMatch \SELF, \key, Mu :$BIND ) is rw {
    SELF.hash{key};
}
multi sub postcircumfix:<[ ]>( QAST::Node \SELF, \idx, Mu :$BIND ) is rw {
    SELF.list[idx];
}

sub EXPORT(|) {
    my role IfGrammar {
        token statement_control:sym<use> {
            :my $longname;
            :my $*IN_DECL  := 'use';
            :my $*HAS_SELF := '';
            :my $*SCOPE    := 'use';
            :my $OLD_MAIN  := ~$*MAIN;
            :my %*MYSTERY;
            $<doc>=[ 'DOC' \h+ ]**0..1
            <sym> <.ws>
            [
            | <version> [
                        ||  <?{ $<version><vnum>[0].Str eq '5' }> {
                                my $module := $*W.load_module(nqp::decont($/), 'Perl5', nqp::hash(), $*GLOBALish);
                                $*W.do_import(nqp::decont($/), $module, 'Perl5');
                                $*W.import_EXPORTHOW(nqp::decont($/), $module);
                            }
                        ||  <?{ $<version><vnum>[0].Str eq '6' }> {
                                my $version_parts := $<version><vnum>;
                                my $vwant := $<version>.ast.compile_time_value;
                                my $vhave := find_symbol(['Version']).new(
                                    nqp::getcomp('perl6').language_version());
                                my $sm := find_symbol(['&infix:<~~>']);
                                if !$sm($vhave,$vwant) {
                                    $/.CURSOR.typed_panic: 'X::Language::Unsupported', version => $<version>.Str;
                                }
                                $*MAIN   := 'MAIN';
                                $*STRICT := 1 if $*begin_compunit;
                            }
                        ||  {
                                $/.CURSOR.typed_panic: 'X::Language::Unsupported', version => $<version>.Str;
                            }
                        ]
            | <module_name>
                [
                || <.spacey> <arglist> <.cheat_heredoc>? <?{ $<arglist><EXPR> }> <.explain_mystery> <.cry_sorrows>
                    {
                        $*W.do_pragma_or_load_module(nqp::decont($/), 1);
                    }
                || {
                        unless $<doc>.Str && !%*COMPILING<%?OPTIONS><doc> {
                            my $load = True;
                            for $<module_name><longname><colonpair> -> Mu $colonpair {
                                if $colonpair<identifier>.Str eq 'if' {
                                    my $value := $colonpair.ast[2];
                                    $load      = nqp::p6bool($*W.compile_time_evaluate(nqp::decont($/), $value));
                                    last;
                                }
                            }
                            $*W.do_pragma_or_load_module(nqp::decont($/), 1) if $load;
                        }
                    }
                ]
            ]
            [ <?{ $*MAIN ne $OLD_MAIN }>
              <.eat_terminator>
              <statementlist=.FOREIGN_LANG($*MAIN, 'statementlist', 1)>
            || <?> ]
            <.ws>
        }
    }

    my Mu $MAIN-grammar := nqp::atkey(%*LANG, 'MAIN');
    nqp::bindkey(%*LANG, 'MAIN',         $MAIN-grammar.HOW.mixin($MAIN-grammar, IfGrammar));

    { }
}

