use v6;

grammar Apache::LogFormat::Grammar {
    token TOP {
        ^<expr>+$
    }

    token expr {
        [
            '%' [ <block-section> || <char-name> ]
        ] || <anyother>
    }

    token anyother {
        <-[\%]>+
    }
    token identifier { <[a..z A..Z]>+ }

    token char-name {
        <[\<\>]>? <identifier>
    }

    token block-section {
        '{' <block-key> '}' <block-type>
    }

    token block-key {
        <-[ \} ]>+
    }

    token block-type {
        <[a..z A..Z]>
    }
}

class Apache::LogFormat::GrammarActions {
    has %.extra-block-handlers;
    has %.extra-char-handlers;
    has %.char-handlers = (
        '%' => q!'%'!,
        b => q|(defined($length)??$length!!'-')|,
        D => q|($reqtime.defined ?? $reqtime.Int !! '-'|,
        h => q!(%env<REMOTE_ADDR> || '-')!,
        H => q!%env<SERVER_PROTOCOL>!,
        l => q!'-'!,
        m => q!safe-value(%env<REQUEST_METHOD>)!,
        p => q!%env<SERVER_PORT>!,
        P => q!$$!,
        q => q|(%env<QUERY_STRING> ?? '?' ~ safe-value(%env<QUERY_STRING>) !! '')|,
        r => q!safe-value(%env<REQUEST_METHOD>) ~ " " ~ safe-value(%env<REQUEST_URI>) ~ " " ~ %env<SERVER_PROTOCOL>!,
        s => q!@res[0]!,
        t => q!'[' ~ format-datetime($time) ~ ']'!,
        T => q|($reqtime.defined ?? $reqtime.Int.truncate * 1_000_000 !! '-')|,
        u => q!(%env<REMOTE_USER> || '-')!,
        U => q!safe-value(%env<PATH_INFO>)!,
        v => q!(%env<SERVER_NAME> || '-')!,
        V => q!(%env<HTTP_HOST> || %env<SERVER_NAME> || '-')!,
    );

    method TOP($/) {
        my $code = q~sub (%env, @res, $length, $reqtime, DateTime $time = DateTime.now) {
            q!~ ~  $<expr>».made.join("") ~ q~!;
        }~;
        $/.make: $code;
    }

    method expr($/) {
        my $made;
        if $<block-section> {
            $made = $<block-section>.made;
        } elsif $<char-name> {
            $made = $<char-name>.made;
        } elsif $<anyother> {
            $made = $<anyother>.made;
        } else {
            die "Match failed";
        }
        $/.make: $made;
    }

    method anyother($/) {
        $/.make: $/.Str
    }

    method char-name($/) {
        my $hdl;
        my $char = $<identifier>.Str;
        if %.char-handlers{$char}:exists {
            $hdl = %.char-handlers{$char};
        } elsif %.extra-char-handlers{$char}:exists {
            $hdl = q!(%extra-chars{'! ~ $char ~ q!'}(%env, @res))!;
        }

        if !$hdl {
            die "char handler for '$char' undefined";
        }
        my $fmt =  q|! ~ | ~ $hdl ~ q|
            ~ q!|;
        $/.make: $fmt;
    }

    method block-section($/) {
        state %psgi-reserved = (
            CONTENT_LENGTH => 1,
            CONTENT_TYPE => 1,
        );
        my $cb;
        given $<block-type>.Str {
        when 'i' {
            my $hdr-name = $<block-key>.Str.uc.subst(/\-/, "_");
            if !%psgi-reserved{$hdr-name} {
                $hdr-name = "HTTP_" ~ $hdr-name;
            }
            $cb = q!string-value(%env<! ~ $hdr-name ~ q!>)!;
        }
        when 'o' {
            $cb = q!string-value(get-header(@res[1], '! ~ $<block-key>.Str ~ q!'))!;
        }
        when 't' {
            $cb = q!"[" ~ strftime('! ~ $<block-key>.Str ~ q!', $time) ~ "]"!;
        }
        when %.extra-block-handlers{$_}:exists {
            $cb = q!string-value(%extra-blocks{'! ~ $<block-type>.Str ~ q!'}('! ~ $<block-key>.Str ~ q!', %env, @res, $length, $reqtime))!;
        }
        default {
            die '%{' ~ $<block-key>.Str ~ '}' ~ $<block-type>.Str ~ ' not supported';
        }
        }

        $/.make: q|! ~ | ~ $cb ~ q| ~ q!|;
    }
}

class Apache::LogFormat::Compiler {

use Apache::LogFormat::Formatter;

use DateTime::Format;

# [10/Oct/2000:13:55:36 -0700]
my sub format-datetime(DateTime $dt) {
    state @abbr = <Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec>;

    return sprintf("%02d/%s/%04d:%02d:%02d:%02d %s%02d%02d",
        $dt.day-of-month, @abbr[$dt.month-1], $dt.year,
        $dt.hour, $dt.minute, $dt.second, ($dt.offset>0??'+'!!'-'), $dt.offset/3600, $dt.offset%3600);
}

our sub safe-value($s) {
    if !defined($s) {
        return '';
    }

    my $x = $s.Str;
    $x ~~ s:g/(<:C>)/{ "\\x" ~ Blob.new(ord($0)).unpack("H*") }/;
    return $x;
}

our sub string-value($s) {
    if !$s {
        return '-'
    }

    my $x = $s.Str;
    $x ~~ s:g/(<:C>)/{ "\\x" ~ Blob.new(ord($0)).unpack("H*") }/;
    return $x;
}

our sub get-header(@hdrs, $key) {
    my $lkey = $key.lc;
    my @copy = @hdrs;
    for @hdrs -> $pair {
        if $pair.key.lc eq $lkey {
            return $pair.value;
        }
    }
    return;
}

method compile(Apache::LogFormat::Compiler:D: $pat, %extra-blocks?, %extra-chars?) {
    my $fmt = $pat; # copy so we can safely modify
    if !$fmt.defined {
        die "Can't compile undefined pattern";
    }
    if $fmt.chars == 0 {
        die "Can't compile empty pattern";
    }

    $fmt ~~ s:g/'!'/'\''!'/;

    my $actions = Apache::LogFormat::GrammarActions.new(
        extra-block-handlers => %extra-blocks,
        extra-char-handlers => %extra-chars,
    );
    my $match = Apache::LogFormat::Grammar.parse($fmt, :$actions);
    if !$match {
        die "Invalid format";
    }

    my $code = EVAL($match.made.Str);
    return Apache::LogFormat::Formatter.new($code);
}

}

=begin pod

=head1 NAME

Apache::LogFormat::Compiler - Compiles Log Format Into Apache::LogFormat::Formatter

=head1 SYNOPSIS

  use Apache::LogFormat::Compiler;
  my $c = Apache::LogFormat::Compiler.new;
  my $fmt = $c.compile(' ... pattern ... ');
  my $line = $fmt.format(%env, @res, $length, $reqtime, $time);
  $*ERR.print($line);

=head1 DESCRIPTION

Apache::LogFormat::Compiler compiles an Apache-style log format string into
efficient perl6 code. It was originally written for perl5 by kazeburo.

=head1 METHODS

=head2 new(): $compiler:Apache::LogFormat::Compiler

Creates a new parser. The parser is stateless, so you can reuse it as many
times to compile log patterns.

=head2 compile($pat:String, %extra-block-handlers:Hash(Str,Callable), %extra-char-handlers:Hash(Str,Callable)) $fmt:Apache::LogFormat::Formatter

Compiles the pattern into an executable formatter object.

=head1 AUTHOR

Daisuke Maki <lestrrat@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Daisuke Maki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
