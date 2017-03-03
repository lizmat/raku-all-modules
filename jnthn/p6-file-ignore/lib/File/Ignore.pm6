use MONKEY-SEE-NO-EVAL;

class File::Ignore {
    class Rule {
        grammar Parser {
            token TOP {
                [ $<leading>='/' ]?
                <path-part>+ % '/'
                [ $<trailing>='/' ]?
            }

            proto token path-part { * }
            token path-part:sym<**>      { <sym> }
            token path-part:sym<matcher> {
                :my $*FINAL;
                <matcher>+ {}
                [<?before '/'? $> { $*FINAL = True }]?
            }

            proto token matcher    { * }
            token matcher:sym<*>   { <sym> }
            token matcher:sym<?>   { <sym> }
            token matcher:sym<[]>  { '[' [$<negate>='!']? <( <-[\]]>+ )> ']' }
            token matcher:sym<lit> { <-[/*?[]>+ }
        }

        class RuleCompiler {
            method TOP($/) {
                make Rule.new(
                    pattern => EVAL('/' ~
                                    ($<leading> ?? '^' !! '') ~
                                    $<path-part>.map(*.ast).join(' ')  ~
                                    '<?before "/" | $> /'),
                    directory-only => ?$<trailing>
                );
            }

            method path-part:sym<matcher>($/) {
                make $<matcher>.map(*.ast).join(' ') ~ ($*FINAL ?? "" !! " '/'");
            }

            method path-part:sym<**>($/) {
                make Q{[ <-[/]>+ [ '/' | $ ] ]*};
            }

            method matcher:sym<*>($/) {
                make '<-[/]>*';
            }

            method matcher:sym<?>($/) {
                make '<-[/]>';
            }

            method matcher:sym<[]>($/) {
                make '<' ~
                    ($<negate> ?? '-' !! '') ~
                    '[' ~
                    $/.subst('\\', '\\\\', :g).subst(/. <( '-' )> ./, '..', :g) ~
                    ']-[/]>';
            }

            method matcher:sym<lit>($/) {
                make "'$/.subst('\\', '\\\\', :g).subst('\'', '\\\'', :g)'";
            }
        }

        has Regex $.pattern;
        has Bool $.directory-only;

        method parse(Str() $rule) {
            with Parser.parse($rule, :actions(RuleCompiler)) {
                .ast;
            }
            else {
                die "Could not parse ignore rule $rule";
            }
        }
    }

    has Rule @!rules;

    submethod BUILD(:@rules!) {
        @!rules = @rules.map({ Rule.parse($_) });
    }

    method parse(Str() $ignore-spec) {
        File::Ignore.new(rules => $ignore-spec.lines.grep(* !~~ /^ [ '#' | \s*$ ]/))
    }

    method ignore-file(Str() $path) {
        for @!rules {
            next if .directory-only;
            return True if .pattern.ACCEPTS($path);
        }
        False
    }

    method ignore-directory(Str() $path) {
        for @!rules {
            return True if .pattern.ACCEPTS($path);
        }
        False
    }

    method ignore-path(Str() $path) {
        return True if self.ignore-file($path);
        my @parts = $path.split('/');
        for @parts.produce(* ~ "/" ~ *) {
            return True if self.ignore-directory($_);
        }
        False
    }

    method walk(Str() $path) {
        sub recurse($path, $prefix) {
            for dir($path) {
                my $target = "$prefix$_.basename()";
                when .d {
                    unless self.ignore-directory($target) {
                        recurse($_, "$target/");
                    }
                }
                default {
                    unless self.ignore-file($target) {
                        take $target;
                    }
                }
            }
        }
        gather recurse($path, '');
    }
}
