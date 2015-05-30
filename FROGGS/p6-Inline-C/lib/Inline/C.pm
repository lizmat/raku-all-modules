
unit role Inline::C[Routine $r, Str $language, Str $code];

use NativeCall;

has int $!setup;
has $!code = "#ifdef WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif
$code";
has Str $!dll;

my @to-delete;

method postcircumfix:<( )>(|args) {
    unless $!setup {
        $!setup      = 1;
        my $c_line;
        my $l_line;
        my $basename = $*SPEC.catfile( $*TMPDIR, 'inline' );
        my $name     = $basename ~ "_" ~ $r.name;
        my $cfg      = $*VM.config;
        my $o        = $cfg<nativecall.o> // $cfg<o> // $cfg<obj>;
        $name        = $basename ~ 1000.rand.Int while $name.IO.e || "$name$o".IO.e || "$name.c".IO.e;

        "$name.c".IO.spurt: $!code;

        if $*VM.name eq 'parrot' {
            my $so  = $cfg<load_ext>;
            $c_line = "$cfg<cc> -c $cfg<cc_shared> $cfg<cc_o_out>$name$o $cfg<ccflags> $name.c";
            $l_line = "$cfg<ld> $cfg<ld_load_flags> $cfg<ldflags> $cfg<libs> $cfg<ld_out>$name$so $name$o";
            $!dll   = "$name$so";
        }
        elsif $*VM.name eq 'moar' {
            my $so  = $cfg<dll>;
            $so ~~ s/^.*\%s//;
            $c_line = "$cfg<cc> -c $cfg<ccshared> $cfg<ccout>$name$o $cfg<cflags> $name.c";
            $l_line = "$cfg<ld> $cfg<ldshared> $cfg<ldflags> $cfg<ldlibs> $cfg<ldout>$name$so $name$o";
            $!dll   = "$name$so";
        }
        elsif $*VM.name eq 'jvm' {
            $c_line = "$cfg<nativecall.cc> -c $cfg<nativecall.ccdlflags> -o$name$o $cfg<nativecall.ccflags> $name.c";
            $l_line = "$cfg<nativecall.ld> $cfg<nativecall.perllibs> $cfg<nativecall.lddlflags> $cfg<nativecall.ldflags> $cfg<nativecall.ldout>$name.$cfg<nativecall.so> $name$o";
            $!dll   = "$name.$cfg<nativecall.so>";
        }
        else {
            die "Unhandling backend $*VM.name() in Inline::C"
        }

        @to-delete.push: $name, "$name$o", "$name.c", $!dll;

        shell $c_line;
        shell $l_line;
    }

    CATCH {
        default {
            try .IO.unlink for @to-delete;
            .rethrow;
        }
    }

    &trait_mod:<is>($r, native => $!dll);
    $r(|args);
}

END {
    try .IO.unlink for @to-delete
}
