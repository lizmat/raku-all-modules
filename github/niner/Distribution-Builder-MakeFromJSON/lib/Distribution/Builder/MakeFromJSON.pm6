use v6;
unit class Distribution::Builder::MakeFromJSON:ver<0.4>;

use System::Query;

has $.meta;
has $!collapsed-meta;

method collapsed-meta() {
    $!collapsed-meta //= $!meta<build> ?? system-collapse($!meta<build>) !! {};
}

method can-build(--> Bool) {
    self.collapsed-meta();
    return True;
    CATCH {
        default {
            note $_;
            return False;
        }
    }
}

method build() {
    my $dest-dir = '.';
    my $workdir = '.';
    my $meta = $.collapsed-meta;
    my $src-dir = ($*CWD.child($meta<src-dir>) || $*CWD).IO;

    configure($meta, $src-dir, $dest-dir) if $meta<configure-bin>:exists;
    process-makefile-template($meta, $src-dir, $dest-dir) if $src-dir.child('Makefile.in').e;

    mkdir "$workdir/resources" unless "$workdir/resources".IO.e;
    mkdir "$workdir/resources/libraries" unless "$workdir/resources/libraries".IO.e;
    temp $*CWD = $src-dir;
    # check for gmake here
    my $make = 'make';
    if $meta<make-target> {
        run $make, $meta<make-target>;
    }
    else {
        run $make;
    }
}

sub configure($meta, $src-dir, $dest-dir) {
    temp $*CWD = $src-dir;
    run $meta<configure-bin>;
}

sub process-makefile-template($meta, $src-dir, $dest-dir) {
    my %vars = backend-values();
    %vars<DESTDIR> = $*CWD;
    my %makefile-variables = $meta<makefile-variables> if $meta<makefile-variables>;
    for %makefile-variables.values -> $value is rw {
        next unless $value ~~ Map;
        if $value<resource>:exists and $value<resource>.starts-with('libraries/')
        {
            my $path = $value<resource>.substr(10); # strip off libraries/
            $value = $dest-dir.IO.child('resources').child('libraries')
                .child($*VM.platform-library-name($path.IO)).Str;
        }
        if $value<platform-library-name>:exists {
            $value = $*VM.platform-library-name($value<platform-library-name>.IO);
        }
        if $value<run>:exists {
            $value = chomp run(|$value<run>, :out).out.lines.join('');
        }
        if $value<env>:exists {
            $value = %*ENV{$value<env>};
        }
    }
    %vars.push: %makefile-variables;

    my $makefile = $src-dir.child('Makefile.in').slurp;
    for %vars.kv -> $k, $v {
        $makefile ~~ s:g/\%$k\%/$v/;
    }
    $src-dir.child('Makefile').spurt: $makefile;
}

sub backend-values() {
    my %vars;

    # Code lifted from LibraryMake
    if $*VM.name eq 'moar' {
        %vars<O> = $*VM.config<obj>;
        my $so = $*VM.config<dll>;
        $so ~~ s/^.*\%s//;
        %vars<SO> = $so;
        %vars<CC> = $*VM.config<cc>;
        %vars<CCSHARED> = $*VM.config<ccshared>;
        %vars<CCOUT> = $*VM.config<ccout>;
        %vars<CCFLAGS> = $*VM.config<cflags>;

        %vars<LD> = $*VM.config<ld>;
        %vars<LDSHARED> = $*VM.config<ldshared>;
        %vars<LDFLAGS> = $*VM.config<ldflags>;
        %vars<LIBS> = $*VM.config<ldlibs>;
        %vars<LDOUT> = $*VM.config<ldout>;
        my $ldusr = $*VM.config<ldusr>;
        $ldusr ~~ s/\%s//;
        %vars<LDUSR> = $ldusr;

        %vars<MAKE> = $*VM.config<make>;

        %vars<EXE> = $*VM.config<exe>;
    }
    elsif $*VM.name eq 'jvm' {
        %vars<O> = $*VM.config<nativecall.o>;
        %vars<SO> = '.' ~ $*VM.config<nativecall.so>;
        %vars<CC> = $*VM.config<nativecall.cc>;
        %vars<CCSHARED> = $*VM.config<nativecall.ccdlflags>;
        %vars<CCOUT> = "-o"; # this looks wrong?
        %vars<CCFLAGS> = $*VM.config<nativecall.ccflags>;

        %vars<LD> = $*VM.config<nativecall.ld>;
        %vars<LDSHARED> = $*VM.config<nativecall.lddlflags>;
        %vars<LDFLAGS> = $*VM.config<nativecall.ldflags>;
        %vars<LIBS> = $*VM.config<nativecall.perllibs>;
        %vars<LDOUT> = $*VM.config<nativecall.ldout>;

        %vars<MAKE> = 'make';

        %vars<LDUSR> = '-l';
        # this is copied from moar - probably wrong
        #die "Don't know how to get platform independent '-l' (LDUSR) on JVM";
        #my $ldusr = $*VM.config<ldusr>;
        #$ldusr ~~ s/\%s//;
        #%vars<LDUSR> = $ldusr;

        %vars<EXE> = $*VM.config<exe>;
    }
    else {
        die "Unknown VM; don't know how to build";
    }

    return %vars;
}

=begin pod

=head1 NAME

Distribution::Builder::MakeFromJSON - Makefile based distribution builder

=head1 SYNOPSIS

  use Distribution::Builder::MakeFromJSON;

=head1 DESCRIPTION

Distribution::Builder::MakeFromJSON uses information from your META6.json and
the running system to fill variabls in a Makefile.in template and build your
distribution.

=head1 AUTHOR

Stefan Seifert <nine@detonation.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Stefan Seifert

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
