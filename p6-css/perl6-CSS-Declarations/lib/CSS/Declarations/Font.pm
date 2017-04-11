use v6;
class CSS::Declarations::Font {
    use CSS::Declarations:ver(v0.0.4..*);
    use CSS::Declarations::Units;

    has Numeric $.em is rw = 10;;
    has Numeric $.ex is rw = $!em * 0.75;
    my subset FontWeight of Numeric where { $_ ~~ 100 .. 900 && $_ %% 100 }
    has FontWeight $.weight is rw = 400;
    has Str $.family = 'times-roman';
    has Str $.style = 'normal';
    has Numeric $.leading;
    has CSS::Declarations $.css = CSS::Declarations.new;
    method css is rw {
        Proxy.new(
            FETCH => sub ($) { $!css },
            STORE => sub ($, $!css) { self.setup },
        );
    }

    submethod TWEAK(Str :$font-style) {
        self.font-style = $_ with $font-style;
        self.setup;
    }

    #| sets/gets the css font property
    #| e.g. $font.font-style = 'italic bold 10pt/12pt sans-serif';
    method font-style is rw {
        Proxy.new(
            FETCH => sub ($) { $!css.font },
            STORE => sub ($, Str \font-prop) {
                $!css.font = font-prop;
                self.setup;
                $!css.font;
            });
    }

    sub pt($_, Numeric :$em = 12, Numeric :$ex = $em * 3/4) is export(:pt) {
        when Numeric {
            (if $_ {
                    my $units = .?type // 'pt';
                    my $scale = do given $units {
                        when 'em' { $em }
                        when 'ex' { $ex }
                        when 'percent' { 0 }
                        default { Units.enums{$units} }
                    } // die "unknown units: $units";
                    (.Num * $scale).Num;
                }
             else {
                 0
             }) does CSS::Declarations::Units::Type["pt"];
        }
        default { Nil }
    }

    method length($v) {
        pt($v, :$!em, :$!ex);
    }

    #| converts a weight name to a three digit number:
    #| 100 lightest ... 900 heaviest
    method !weight($_) returns FontWeight {
        given .lc {
            when FontWeight       { $_ }
            when /^ <[1..9]>00 $/ { .Int }
            when 'normal'         { 400 }
            when 'bold'           { 700 }
            when 'lighter'        { max($!weight - 100, 100) }
            when 'bolder'         { min($!weight + 100, 900) }
            default {
                warn "unhandled font-weight: $_";
                400;
            }
        }
    }

    method font-length($_) returns Numeric {
        if $_ ~~ Numeric {
            .?type ~~ 'percent'
                ?? $!em * $_ / 100
                !! self.length($_);
        }
        else {
            given .lc {
                when 'xx-small' { 6pt }
                when 'x-small'  { 7.5pt }
                when 'small'    { 10pt }
                when 'medium'   { 12pt }
                when 'large'    { 13.5pt }
                when 'x-large'  { 18pt }
                when 'xx-large' { 24pt }
                when 'larger'   { $!em * 1.2 }
                when 'smaller'  { $!em / 1.2 }
                default {
                    warn "unhandled font-size: $_";
                    12pt;
                }
            }
        }
    }

    method setup(CSS::Declarations $css = $!css) {
        $!family = $css.font-family // 'arial';
        $!style = $css.font-style;
        $!weight = self!weight($css.font-weight);
        $!em = self.font-length($css.font-size);

        $!leading = do given $css.line-height {
            when .type eq 'num'     { $_ * $!em }
            when .type eq 'percent' { $_ * $!em / 100 }
            when 'normal'           { $!em * 1.2 }
            default                 { self.length($_) }
        }
    }
}

