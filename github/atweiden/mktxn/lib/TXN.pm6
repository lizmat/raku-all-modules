use v6;
use Config::TOML;
use File::Presence;
use TXN::Parser;
use TXN::Parser::ParseTree;
use TXN::Parser::Types;
use TXN::Remarshal;
unit class TXN;

constant $PROGRAM = 'mktxn';
constant $VERSION = v0.1.0;

# TXNBUILD {{{

# parse TXNBUILD with Config::TOML and store results
my class TXNBUILD
{
    has VarNameBare:D $.pkgname is required;
    has Version:D $.pkgver is required;
    has UInt:D $.pkgrel = 1;
    has Str:D $.pkgdesc = '';
    has Str:D $.source is required;
    has Int $.date-local-offset;
    has Str $.include-lib;

    submethod BUILD(
        Str:D :$file! where .so
        --> Nil
    )
    {
        my %toml = from-toml(:$file);
        $!date-local-offset =
            %toml<date-local-offset>.Int if %toml<date-local-offset>;
        $!include-lib =
            gen-include-lib($file, %toml<include-lib>) if %toml<include-lib>;
        $!pkgdesc = %toml<pkgdesc> if %toml<pkgdesc>;
        $!pkgname = %toml<pkgname>;
        $!pkgrel = %toml<pkgrel>.UInt if %toml<pkgrel>;
        $!pkgver = Version.new(%toml<pkgver>);
        $!source = %toml<source>;
    }

    method new(
        Str:D :$file! where .so
        --> TXNBUILD:D
    )
    {
        self.bless(:$file);
    }
}

# end TXNBUILD }}}
# TXN::Package {{{

# create package from accounting ledger with TXNBUILD
my class TXN::Package
{
    has Str:D $!compiler is required;
    has Ledger:D $!ledger is required;
    has UInt:D $!count is required;
    has VarName:D @!entities-seen is required;
    has VarNameBare:D $!pkgname is required;
    has Version:D $!pkgver is required;
    has UInt:D $!pkgrel is required;
    has Str:D $!pkgdesc is required;

    multi submethod BUILD(
        Str:D :$file! where .so,
        Bool :$verbose
        --> Nil
    )
    {
        my DateTime:D $dt = now.DateTime;
        $!compiler = "$PROGRAM v$VERSION $dt";
        my TXNBUILD $txnbuild .= new(:$file);
        $!pkgdesc = $txnbuild.pkgdesc if $txnbuild.pkgdesc;
        $!pkgname = $txnbuild.pkgname;
        $!pkgrel = $txnbuild.pkgrel;
        $!pkgver = $txnbuild.pkgver;
        my %opts;
        %opts<date-local-offset> =
            $txnbuild.date-local-offset if $txnbuild.date-local-offset.defined;
        %opts<include-lib> = $txnbuild.include-lib if $txnbuild.include-lib;
        my Str:D $message =
            sprintf(
                Q{Making txn pkg: %s %s-%s (%s)},
                $!pkgname,
                $!pkgver,
                $!pkgrel,
                $dt
            );
        say($message) if $verbose;
        $!ledger = from-txn(:file($txnbuild.source), |%opts);
        $!count = $!ledger.entry.elems;
        @!entities-seen = gen-entities-seen($!ledger.entry);
    }

    multi submethod BUILD(
        Str:D :$!pkgname!,
        Version:D :$!pkgver!,
        Str:D :$source!,
        UInt :$pkgrel,
        Str :$pkgdesc,
        Int :$date-local-offset,
        Str :$include-lib
        --> Nil
    )
    {
        my DateTime:D $dt = now.DateTime;
        $!compiler = "$PROGRAM v$VERSION $dt";
        $!pkgdesc = $pkgdesc ?? $pkgdesc !! '';
        $!pkgrel = $pkgrel ?? $pkgrel !! 1;
        my %opts;
        %opts<date-local-offset> =
            $date-local-offset if $date-local-offset.defined;
        %opts<include-lib> = $include-lib if $include-lib;
        $!ledger = from-txn(:file($source), |%opts);
        $!count = $!ledger.entry.elems;
        @!entities-seen = gen-entities-seen($!ledger.entry);
    }

    proto method new(|)
    {*}

    multi method new(
        *%opts (
            Str:D :$file! where .so,
            Bool :$verbose
        )
        --> TXN::Package:D
    )
    {
        self.bless(|%opts);
    }

    multi method new(
        *%opts (
            Str:D :$pkgname!,
            Version:D :$pkgver!,
            Str:D :$source!,
            UInt :$pkgrel,
            Str :$pkgdesc,
            Int :$date-local-offset,
            Str :$include-lib
        )
        --> TXN::Package:D
    )
    {
        self.bless(|%opts);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %txn-info =
            :$!compiler,
            :$!count,
            :@!entities-seen,
            :$!pkgdesc,
            :$!pkgname,
            :$!pkgrel,
            :$!pkgver;
        my %hash = :$!ledger, :%txn-info;
    }
}

# end TXN::Package }}}

# method gen-txn-pkg-file {{{

method gen-txn-pkg-file(
    Str:D $pkgname,
    Version:D $pkgver,
    UInt:D $pkgrel
    --> Str:D
)
{
    my Str:D $txn-pkg-file-ext = TXN.gen-txn-pkg-file-ext;
    my Str:D $txn-pkg-file =
        sprintf(Q{%s-%s-%s%s}, $pkgname, $pkgver, $pkgrel, $txn-pkg-file-ext);
}

# end method gen-txn-pkg-file }}}
# method gen-txn-pkg-file-ext {{{

method gen-txn-pkg-file-ext(--> Str:D)
{
    my Str:D $txn-pkg-file-ext = '.txn.pkg.tar.xz';
}

# end method gen-txn-pkg-file-ext }}}
# sub gen-entities-seen {{{

sub gen-entities-seen(Entry:D @entry --> Array:D)
{
    my VarName:D @entities-seen =
        @entry
        .map({
            .posting
            .map({ .account.entity })
        })
        .flat
        .unique
        .sort;
}

# end sub gen-entities-seen }}}
# sub gen-include-lib {{{

# resolve C<include-lib> path relative to TXNBUILD file
multi sub gen-include-lib(
    Str:D $txnbuild,
    Str:D $include-lib where .IO.is-relative
    --> Str:D
)
{
    my Str:D $gen-include-lib = join('/', $txnbuild.IO.dirname, $include-lib);
}

# absolute path for C<include-lib> given, use it directly
multi sub gen-include-lib(
    Str:D $txnbuild,
    Str:D $include-lib
    --> Str:D
)
{
    my Str:D $gen-include-lib = $include-lib;
}

# end sub gen-include-lib }}}
# sub mktxn {{{

multi sub mktxn(
    Str:D :$file! where .so,
    Bool:D :$release! where .so
    --> Nil
) is export
{
    my %pkg = TXN::Package.new(:$file, :verbose).hash;
    makepkg(%pkg, :verbose);
}

multi sub mktxn(
    Str:D :$file! where .so,
    Bool :release($)
    --> Hash:D
) is export
{
    my %pkg = TXN::Package.new(:$file).hash;
}

multi sub mktxn(
    Bool:D :$release! where .so,
    *%opts (
        Str:D :$pkgname!,
        Version:D :$pkgver!,
        Str:D :$source!,
        UInt :$pkgrel,
        Str :$pkgdesc,
        Int :$date-local-offset,
        Str :$include-lib
    )
    --> Nil
) is export
{
    my %pkg = TXN::Package.new(|%opts).hash;
    makepkg(%pkg);
}

multi sub mktxn(
    *%opts (
        Str:D :$pkgname!,
        Version:D :$pkgver!,
        Str:D :$source!,
        UInt :$pkgrel,
        Str :$pkgdesc,
        Int :$date-local-offset,
        Str :$include-lib
    )
    --> Hash:D
) is export
{
    my %pkg = TXN::Package.new(|%opts).hash;
}

# end sub mktxn }}}
# sub makepkg {{{

# serialize to JSON files on disk and compress
multi sub makepkg(
    %pkg (
        Ledger:D :ledger($)!,
        :%txn-info!
    ),
    Bool :$verbose
    --> Nil
)
{
    makepkg('message', 'creating', %txn-info) if $verbose;
    my Str:D $build-dir = sprintf(Q{%s/build}, $*CWD);
    my Str:D $txn-info-file = sprintf(Q{%s/.TXNINFO}, $build-dir);
    my Str:D $txn-json-file = sprintf(Q{%s/txn.json}, $build-dir);
    mkdir($build-dir);
    makepkg('serialize', %pkg, $txn-info-file, $txn-json-file);
    makepkg('compress', %txn-info, $build-dir, $txn-info-file, $txn-json-file);
    makepkg('message', 'finished', %txn-info) if $verbose;
    makepkg('message', 'cleaning') if $verbose;
    makepkg('clean', $build-dir);
}

multi sub makepkg(
    'message',
    'creating',
    % (
        Str:D :$pkgname!,
        *%
    )
    --> Nil
)
{
    my Str:D $message-creating = sprintf(Q{Creating txn pkg "%s"…}, $pkgname);
    say($message-creating);
}

multi sub makepkg(
    'serialize',
    % (
        Ledger:D :$ledger!,
        :%txn-info
    ),
    Str:D $txn-info-file,
    Str:D $txn-json-file
    --> Nil
)
{
    # serialize .TXNINFO to JSON
    my Str:D $txn-info = Rakudo::Internals::JSON.to-json(%txn-info);
    spurt($txn-info-file, $txn-info ~ "\n");

    # serialize accounting ledger to JSON
    my Str:D $txn-json = remarshal($ledger, :if<ledger>, :of<json>);
    spurt($txn-json-file, $txn-json ~ "\n");
}

multi sub makepkg(
    'compress',
    %txn-info,
    Str:D $build-dir,
    Str:D $txn-info-file,
    Str:D $txn-json-file
)
{
    my Str:D $tar-cmdline =
        build-tar-cmdline(
            %txn-info,
            $build-dir,
            $txn-info-file,
            $txn-json-file
        );
    shell($tar-cmdline);
}

multi sub makepkg(
    'message',
    'finished',
    % (
        Str:D :$compiler!,
        Str:D :$pkgname!,
        Version:D :$pkgver!,
        UInt:D :$pkgrel!,
        *%
    )
    --> Nil
)
{
    my Str:D $dt = $compiler.split(' ').tail;
    my Str:D $message-finish =
        sprintf(
            Q{Finished making: %s %s-%s (%s)},
            $pkgname,
            $pkgver,
            $pkgrel,
            $dt
        );
    say($message-finish);
}

multi sub makepkg(
    'message',
    'cleaning'
    --> Nil
)
{
    say('Cleaning up…');
}

multi sub makepkg(
    'clean',
    Str:D $build-dir
    --> Nil
)
{
    dir($build-dir).race.map({ .unlink });
    rmdir($build-dir);
}

sub build-tar-cmdline(
    % (
        Str:D :$pkgname!,
        Version:D :$pkgver!,
        UInt:D :$pkgrel!,
        *%
    ),
    Str:D $build-dir,
    Str:D $txn-info-file,
    Str:D $txn-json-file
    --> Str:D
)
{
    my Str:D $txn-pkg-file = TXN.gen-txn-pkg-file($pkgname, $pkgver, $pkgrel);
    my Str:D $tar-cmdline =
        sprintf(
            Q{tar -C %s --xz -cvf %s %s %s},
            $build-dir,
            $txn-pkg-file,
            $txn-info-file.IO.basename,
            $txn-json-file.IO.basename
        );
}

# end sub makepkg }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
