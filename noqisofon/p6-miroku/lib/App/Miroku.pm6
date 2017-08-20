use v6;

use File::Find;
use JSON::Fast;

use App::Miroku::Template;

unit class App::Miroku;

has $!author = qx{git config --global user.name}.chomp;
has $!email  = qx{git config --global user.email}.chomp;
has $!year   = Date.today.year;

my &normalize-path = -> $path {
    $*DISTRO.is-win ?? $path.subst( '\\', '/', :g ).IO.relative !! $path.IO.relative
};

my &to-module = -> $filename {
    normalize-path( $filename ).Str.subst( 'lib/', '' ).subst( '/', '::', :g ).subst( /\.pm6?$/, '' )
};

my &to-file = -> $module-name {
    my $path = $module-name.subst( '::', '/', :g ) ~ '.pm6';

    './lib/'.IO.add( $path ).Str
};


multi method perform('new', Str $module-name is copy, Str :$prefix, Str :$to = '.', Str :$type = 'lib') {
    my $main-dirname = $module-name.subst( '::', '-', :g );

    $main-dirname = $prefix ~ $main-dirname if $prefix;

    my $main-dir = $to.IO.resolve.add( $main-dirname );

    die "Already exists $main-dir" if $main-dir.IO ~~ :d;
    
    $main-dir.mkdir;
    chdir( $main-dir );
    my $module-filepath = to-file( $module-name );
    my $module-dir      = $module-filepath.IO.dirname.Str;

    my @child-dirs = get-child-dirs( $type, $module-dir );
    
    mkdir( $_ ) for @child-dirs;

    my %contents = App::Miroku::Template::get-template(
        :module($module-name),
        :$!author, :$!email, :$!year,
        dist => $module-name.subst( '::', '-', :g )
    );

    my %key-by-path = get-key-by-path( $type, $module-filepath );

    for %key-by-path.kv -> $key, $path {
        spurt( $path, %contents{$key} );
    }

    self.perform( 'build' );

    git-init;
    git-add;

    note "Successfully created $main-dir";
}

multi method perform('build') {
    my ( $module, $module-file ) = guess-main-module;

    generate-read-me( $module-file );

    self!generate-meta-info( $module, $module-file );
    self.build;
}

multi method perform('test', @files, Bool :$verbose , Int :$jobs) {
    with-p6-lib {
        my @options = '-r';
        @options.push: '-v'        if $verbose;
        @options.push: '-j', $jobs if $jobs;

        if @files.elems == 0 {
            @files = <t xt>.grep( { .IO.d } );
        }

        my @command = 'prove', '-e', $*EXECUTABLE, |@options, |@files;

        note " ==> set PERL6LIB=%*ENV<PERL6LIB>";
        note " ==> @command[]";

        my $proc = run |@command;

        $proc.exitcode;
    }
}

method build($build-filename = 'Build.pm') {
    return unless $build-filename.IO.e;

    note " ==> Execute $build-filename";

    # my @command = 

    # my $exit-code = $proc.exitcode;

    # die "Failed with exitcode $exit-code" if $exit-code != 0;
}

method !generate-meta-info($module, $module-file) {
    my $meta-file = <META6.json META.info>.grep( { .IO ~~ :f & :!l } ).first;

    my %already   = do if $meta-file.defined {
        from-json( $meta-file.IO.slurp )
    } else {
        {}
    };
    
    my @authors = do if %already<authors>:exists {
        |%already<authors>
    } elsif %already<author>:exists {
        [ %already<author>:delete ]
    } else {
        [ $!author ]
    };

    my $perl6-version = %already<perl> || $*PERL.version.Str;

    $perl6-version ~~ s/^v//;

    my @command = $*EXECUTABLE, "-M$module", '-e', "$module.^ver.Str.say";
    my $proc    = with-p6-lib { run |@command, :out, :err };

    my $module-version = $proc.out.slurp-rest.chomp || %already<version>;

    $module-version = '0.0.1' if $module-version eq "*";

    my %new-meta = (
        name          => $module,
        perl          => $perl6-version,
        authors       => @authors,
        depends       => %already<depends>                || [],
        test-depends  => %already<test-depends>           || [],
        build-depends => %already<build-depends>          || [],
        description   => find-description( $module-file ) || %already<description> || '',
        provides      => find-provides(),
        source-url    => %already<source-url>             || find-source-url(),
        version       => $module-version,
        resources     => %already<resources>              || [],
        tags          => %already<tags>                   || [],
        license       => %already<license>                || guess-license()
    );

    for %already.keys -> $key {
        %new-meta{$key} = %already{$key} unless %new-meta{$key}:exists;
    }

    $meta-file = 'META6.json' unless $meta-file.defined;
    $meta-file.IO.spurt: to-json( %new-meta ) ~ "\n";
}

sub get-child-dirs(Str $type, $module-dir) {
    given $type {
        when 'app' {
            ( $module-dir, 't', 'bin' )
        }
        when 'lib' {
            ( $module-dir, 't' )
        }
        default {
            ( $module-dir )
        }
    }
}

sub get-key-by-path(Str $type, $module-filepath) {
    given $type {
        when 'app' {
            (
                module      => $module-filepath,
                test-case   => 't/01-basic.t',
                license     => 'LICENSE',
                'gitignore' => '.gitignore',
                travis      => '.travis.yml'
            )
        }
        when 'lib' {
            (
                module      => $module-filepath,
                test-case   => 't/01-basic.t',
                license     => 'LICENSE',
                'gitignore' => '.gitignore',
                travis      => '.travis.yml'
            )
        }
        default {
            (
                module      => $module-filepath,
                license     => 'LICENSE',
                'gitignore' => '.gitignore',
                travis      => '.travis.yml'
            )
        }
    }
}

sub git-init() {
    my $dev-null = open $*SPEC.devnull, :w;
    {
        run 'git', 'init', '.', :out($dev-null);

        $dev-null.close;
    }
}

sub git-add() {
    run 'git', 'add', '.';
}

sub with-p6-lib(&block) {
    temp %*ENV;

    %*ENV<PERL6LIB> = %*ENV<PERL6LIB>:exists ?? "$*CWD/lib,%*ENV<PERL6LIB>" !! "$*CWD/lib,";

    block;
}

sub generate-read-me($module-file, $document-type = 'Markdown') {
    my @command = $*EXECUTABLE, "--doc={$document-type}", $module-file;
    my $a-proc  = with-p6-lib { run |@command, :out };

    die "Failed: @command[]" if $a-proc.exitcode != 0;

    my $contents = $a-proc.out.slurp-rest;

    my ($user, $repository) = guess-user-and-repository;
    my $header = do if $user and '.travis.yml'.IO.e {
        "[![Build Status](https://travis-ci.org/$user/$repository.svg?branch=master)]"
        ~ "(https://travis-ci.org/$user/$repository)"
        ~ "\n\n";
    } else {
        '';
    }

    spurt 'README.md', $header ~ $contents;
}

sub find-description($module-file) {
    my $content = $module-file.IO.slurp;

    return do if $content ~~ /^^
    '=' head. \s+ NAME
    \s+
    \S+ \s+ '-' \s+ (\S<-[\n]>*)/ {
        $/[0].Str
    } else {
        ''
    };
}

sub find-source-url() {
    try my @lines = qx{git remote -v 2> /dev/null};

    return '' unless @lines;

    my $url = gather for @lines -> $line {
        my ($, $url) = $line.split( /\s+/ );

        if  $url {
            take $url;

            last;
        }
    }

    return '' unless $url;

    $url .= Str;

    $url ~~ s/^https?/git/;

    $url = do if $url ~~ m/'git@' $<host>=[.+] ':' $<repo>=[<-[:]>+] $/ {
        "git://$<host>/$<repo>";
    } elsif $url ~~ m/'ssh://git@' $<rest>=[.+] / {
        "git://$<rest>";
    }
    $url;
}

sub find-provides() {
    my %provides = find( dir => 'lib', name => /\.pm6?$/ ).list.map(
        -> $file {
            my $module = to-module( $file.Str );

            $module => normalize-path( $file.Str );
        } ).sort;

    %provides;
}

sub guess-user-and-repository() {
    my $source-url = find-source-url;

    return if $source-url eq '';

    if $source-url ~~ m{ ( 'git' | 'http' 's'? ) '://'
                         [<-[/]>+] '/'
                         $<user>=[<-[/]>+] '/'
                         $<repo>=[.+?] [\.git]?
                         $}
    {
        return $/<user>, $/<repo>;
    }

    return ;
}

sub guess-main-module($lib-dir = 'lib') {
    die 'Must run in the top directory' unless $lib-dir.IO ~~ :d;

    my @module-files       = find( :dir($lib-dir), :name(/ '.pm'  '6'? $ /) ).list;
    my $module-file-amount = @module-files.elems;
    given $module-file-amount {
        when 0 {
            die 'Could not determine main module file';
        }
        when 1 {
            my $first-module-file = @module-files.first;

            return ( to-module( $first-module-file ), $first-module-file )
        }
        default {
            my $base-dir = $*CWD.basename;

            $base-dir ~~ s/^ ('perl6' | 'p6') '-'//;

            my $module-name       = $base-dir.split( '-' ).join( '/' );
            my @found-module-files = @module-files.grep( -> $filepath { $filepath ~~ m:i/$module-name . pm6?$/ } );
            my $a-file = do if @found-module-files.elems == 0 {
                my @sorted-module-files = @module-files.sort: { $^a.chars <=> $^b.chars };

                @sorted-module-files.shift.Str;
            } elsif @found-module-files.elems == 1 {
                @found-module-files.first.Str;
            } else {
                my @sorted-module-files = @module-files.sort: { $^a.chars <=> $^b.chars };

                @sorted-module-files.shift.Str;
            }
            return ( to-module( $a-file ), $a-file );
        }
    }
}

sub guess-license() {
    my $license-file = 'LICENSE'.IO;

    return 'NOASSERTION' unless $license-file;

    my @lines = $license-file.lines;

    return do if @lines.elems == 201 && @lines.first.index( 'The Artistic License 2.0' ) {
        'Artistic-2.0'
    } else {
        'NOASSERTION'
    };
}

=begin pod

=head1 NAME

App::Miroku - Yet another minimal authoring tool for Perl6

=head1 SYNOPSIS

  > miroku new Foo::Bar  # create p6-Foo-Bar distribution
  > cd ./p6-Foo-Bar
  > miroku build         # generate README.md, META6.json
  > miroku test          # run tests
 
=head1 INSTALLATION

  > zef install App::Miroku

=head1 DESCRIPTION

=head1 FAQ

=head1 SEE ALSO

=item L<<https://github.com/tokuhirom/Minilla>>
=item L<<https://github.com/skaji/mi6>>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Ned Rihine

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
