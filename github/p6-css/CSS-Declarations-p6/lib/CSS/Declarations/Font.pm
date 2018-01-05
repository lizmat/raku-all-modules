use v6;
class CSS::Declarations::Font {
    use CSS::Declarations;
    use CSS::Declarations::Units :Scale, :pt;

    has Numeric $.em is rw = 10;
    has Numeric $.ex is rw = $!em * 0.75;
    my subset FontWeight of Numeric where { 100 <= $_ <= 900 && $_ %% 100 }
    has FontWeight $.weight is rw = 400;
    has Str @!family = ['times-roman'];
    method family { @!family[0] }
    has Str $.style = 'normal';
    has Numeric $.line-height;
    has Str $.stretch;
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

    #| compute a fontconfig pattern for the font
    method fontconfig-pattern {
        my Str $pat = @!family.join: ',';

        $pat ~= ':slant=' ~ $!style
            unless $!style eq 'normal';

        $pat ~= ':weight='
        #    000  100        200   300  400     500    600      700  800       900
          ~ <thin extralight light book regular medium semibold bold extrabold black>[$!weight.substr(0,1)]
            unless $!weight == 400;

        # [ultra|extra][condensed|expanded]
        $pat ~= ':width=' ~ $!stretch.subst(/'-'/, '')
            unless $!stretch eq 'normal';
        $pat;
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
                        default { Scale.enums{$units} }
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
    method !font-weight($_) returns FontWeight {
        given .lc {
            when FontWeight       { .Int }
            when 'normal'         { 400 }
            when 'bold'           { 700 }
            when 'lighter'        { max($!weight - 100, 100) }
            when 'bolder'         { min($!weight + 100, 900) }
            default {
                if /^ <[1..9]>00 $/ {
                    .Int
                }
                else {
                    warn "unhandled font-weight: $_";
                    400;
                }
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
        @!family = [];
        with $css.font-family {
            for .grep(* ne ',') {
                if .type eq 'keyw' {
                    $_ ~= ' ' with @!family.tail;
                    @!family.tail ~= $_;
                }
                else {
                    @!family.push: $_;
                }
            }
        }
        $_ = 'arial' without @!family[0];

        $!style = $css.font-style;
        $!weight = self!font-weight($css.font-weight);
        $!em = self.font-length($css.font-size);
        $!stretch = $css.font-stretch;
        $!line-height = do given $css.line-height {
            when .type eq 'num'     { $_ * $!em }
            when 'normal'           { $!em * 1.2 }
            default                 { self.font-length($_) }
        }
	self;
    }

    method find-font(Str $name = $.fontconfig-pattern) {
        my $cmd =  run('fc-match',  '-f', '%{file}', $name, :out, :err);
        given $cmd.err.slurp {
            note $_ if $_;
        }
        my $file = $cmd.out.slurp;
        $file
          || die "unable to resolve font-name: $name"
    }
}

