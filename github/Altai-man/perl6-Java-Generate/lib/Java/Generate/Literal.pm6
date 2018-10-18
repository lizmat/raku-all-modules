unit module Java::Generate::Literal;

use Java::Generate::Argument;
use Java::Generate::Statement;
use Java::Generate::Utils;

class BooleanLiteral does Argument does Java::Generate::Statement::Literal is export {
    has Bool $.value;

    method generate(--> Str) { $!value ?? 'true' !! 'false' }
}

class FloatLiteral does Argument does Java::Generate::Statement::Literal is export {
    has Num $.value;

    method generate(--> Str) {
        my $float = 1.40e-45 <= $!value <= 3.4028235e38;
        # XXX: the actual minimal number from spec is `4.9e-324`,
        # but it evaluates to 0 currently (possible Rakudo), so using some bigger number instead;
        if 1.7976931348623157e308 < $!value || $!value < 4.9e-323 {
            die "Value {$!value} is too {$!value > 1 ?? 'large' !! 'small'} for double";
        }
        $!value.Str ~ ($float ?? 'f' !! 'd');
    }
}

class IntLiteral does Argument does Java::Generate::Statement::Literal is export {
    has Int $.value;
    has Base $.base = 'dec';

    method generate(--> Str) {
        my $int = (-(2 ** 31) <= $!value <= (2 ** 31 - 1));
        if -9223372036854775808 > $!value || $!value > 9223372036854775808 {
            die "Value {$!value} is too {$!value > 0 ?? 'large' !! 'small'} for integer";
        }
        my $signed = $!value < 0 ?? $!value + 2 ** ($int ?? 32 !! 64) !! $!value;
        (given $!base {
            when 'dec' { $!value.Str }
            when 'oct' { '0' ~ $signed.base(8) }
            when 'hex' { '0x' ~ $signed.base(16) }
            when 'bin' {
                my $n = $signed.base(2);
                '0b' ~ ('0' xx (($int ?? 32 !! 64) - $n.Str.chars)).join ~ $n
            }
        }) ~ ($int ?? '' !! 'L');
    }
}

class NullLiteral does Argument does Java::Generate::Statement::Literal is export {
    method generate(--> Str) { "null" }
}

class StringLiteral does Argument does Java::Generate::Statement::Literal is export {
    has Str $.value;

    method !expand($_) { (0 xx (4 - $_.chars)).join ~ $_ }

    method !non-bmp-sequence($_) {
        my $high = ((($_ - 0x10000) / 0x400) + 0xD800).floor.base(16);
        my $low  =  (($_ - 0x10000) % 0x400 + 0xDC00).base(16);
        qq/\\u$high\\u$low/;
    }

    method generate(--> Str) {
        my $converted = $!value.NFC.list.map(
            -> $ord {
                $ord == 13 ?? "\\r" !!
                $ord == 10 ?? "\\n" !!
                $ord < 32 ?? '\u' ~ self!expand($ord.base(16)) !!
                $ord == ord('\\') ?? "\\\\" !!
                $ord == ord('"') ?? "\\\"" !!
                $ord < 127 ?? chr($ord) !!
                $ord < 65535 ?? '\u' ~ self!expand($ord.base(16)) !!
                    self!non-bmp-sequence($ord);
            }).join;
        qq/"$converted"/
    }
}
