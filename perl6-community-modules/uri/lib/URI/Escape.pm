use v6;

unit package URI::Escape;

use IETF::RFC_Grammar::URI;

my %escapes = (^256).flatmap: {
    .chr => sprintf '%%%02X', $_
};

# line below may work and be useful when fix RT #126252
#   my token escape_unreserved {<IETF::RFC_Grammar::URI::unreserved>};

sub uri-escape($s, Bool :$no-utf8 = False) is export {
    $s // return $s;
    $s.subst(:g, /<- [\-._~A..Za..z0..9]>/,
        {
            ( $no-utf8 || .Str.ord < 128 ) ?? %escapes{ .Str } !!
                .Str.encode.list.fmt('%%%X', "")
        }
    );
}

# todo - automatic invalid UTF-8 detection
# see http://www.w3.org/International/questions/qa-forms-utf-8
#     find first sequence of %[89ABCDEF]<.xdigit>
#         use algorithm from url to determine if it's valid UTF-8
sub uri-unescape(*@to_unesc, Bool :$no-utf8 = False) is export {
    my @rc = @to_unesc.flatmap: {
        .trans('+' => ' ')\
        .subst(:g, / [ '%' (<.xdigit> ** 2 ) ]+ /, -> $/ {
            $no-utf8
                ?? $0.flatmap({ :16(~$_).chr }).join
                !! Buf.new($0.flatmap({ :16(~$_) })).decode('UTF-8')
        })
    };

    return |@rc;
}

# preserve snake case interface
sub uri_escape($s, Bool :$no_utf8 = False) is export {
    uri-escape($s, no-utf8 => $no_utf8)
}

sub uri_unescape(*@to_unesc, Bool :$no_utf8 = False) is export {
    uri-unescape(@to_unesc, no-utf8 => $no_utf8)
}

=begin pod

=head NAME

URI::Escape - Escape and unescape unsafe characters

=head SYNOPSIS

    use URI::Escape;
    
    my $escaped = uri-escape("10% is enough\n");
    my $un_escaped = uri-unescape('10%25%20is%20enough%0A');

=end pod

# vim:ft=perl6
