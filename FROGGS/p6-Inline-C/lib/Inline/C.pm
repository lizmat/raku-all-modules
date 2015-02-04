
role Inline::C[Routine $r, Str $language, Str $code];

use NativeCall;

has int $!setup;
has $!code = "#ifdef WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif
$code";
has $!libname;
has $!dll;

my @to-delete;

method postcircumfix:<( )>(|args) {
    unless $!setup {
        $!setup      = 1;
        my $basename = $*SPEC.catfile( $*TMPDIR, 'inline' );
        my $cfg      = $*VM.config;
        my $o        = $cfg<obj> // $cfg<o>;
        $!libname    = $basename ~ "_" ~ $r.name;
        $!libname    = $basename ~ 1000.rand.Int while $!libname.IO.e || "$!libname$o".IO.e || "$!libname.c".IO.e;
        $!dll        = $cfg<dll> ?? $!libname.IO.dirname ~ '/' ~ $!libname.IO.basename.fmt($cfg<dll>) !! $!libname ~ $cfg<load_ext>;
        my $ccout    = $cfg<ccout> // $cfg<cc_o_out>;
        my $ccshared = $cfg<ccshared> // $cfg<cc_shared>;
        my $cflags   = $cfg<cflags> // $cfg<ccflags>;
        my $ldshared = $cfg<ldshared> // $cfg<ld_load_flags>;
        my $ldlibs   = $cfg<ldlibs> // $cfg<libs>;
        my $ldout    = $cfg<ldout> // $cfg<ld_out>;

        @to-delete.push: $!libname, "$!libname$o", "$!libname.c", $!dll;

        "$!libname.c".IO.spurt: $!code;

        shell "$cfg<cc> -c $ccshared $ccout$!libname$o $cflags -xc $!libname.c";
        shell "$cfg<ld> $ldshared $cfg<ldflags> $ldlibs $ldout$!dll $!libname$o";
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
