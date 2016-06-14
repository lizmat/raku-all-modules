use v6;
use Config::TOML;
use TXN::Parser;
unit module TXN;

constant $PROGRAM = 'mktxn';
constant $VERSION = v0.0.3;

# emit {{{

multi sub emit(
    Str $content,
    Bool :$json,
    *%opts (
        Str :$txndir,
        Int :$date-local-offset
    )
)
{
    my @txn = TXN::Parser.parse($content, |%opts).made;
    emit(:@txn, :$json);
}

multi sub emit(
    Str :$file!,
    Bool :$json,
    *%opts (
        Str :$txndir,
        Int :$date-local-offset
    )
)
{
    my @txn = TXN::Parser.parsefile($file, |%opts).made;
    emit(:@txn, :$json);
}

multi sub emit(:@txn!, Bool :$json! where *.so)
{
    # stringify DateTimes in preparation for JSON serialization
    loop (my Int $i = 0; $i < @txn.elems; $i++)
    {
        @txn[$i]<header><date> = ~@txn[$i]<header><date>;
    }

    Rakudo::Internals::JSON.to-json(@txn);
}

multi sub emit(:@txn!, Bool :$json)
{
    @txn;
}

# end emit }}}

# from-txn {{{

multi sub from-txn(
    Str $content,
    *%opts (
        Bool :$json,
        Str :$txndir,
        Int :$date-local-offset
    )
) is export
{
    emit($content, |%opts);
}

multi sub from-txn(
    Str :$file!,
    *%opts (
        Bool :$json,
        Str :$txndir,
        Int :$date-local-offset
    )
) is export
{
    emit(:$file, |%opts);
}

# end from-txn }}}

# mktxn {{{

multi sub mktxn(
    Str :$file!,
    Bool :$release! where *.so,
    *%opts (
        Str :$pkgname,
        Str :$pkgver,
        Int :$pkgrel,
        Str :$pkgdesc,
        Str :$txndir,
        Int :$date-local-offset,
        Str :$template
    )
) is export
{
    my %prepare = prepare(|%opts);

    say "Making txn pkg: %prepare<pkgname> ",
        "%prepare<pkgver>-%prepare<pkgrel> (%prepare<dt>)";

    my %build = build(:$file, |%prepare);
    package(%build);
}

multi sub mktxn(
    Str :$file!,
    *%opts (
        Str :$pkgname,
        Str :$pkgver,
        Int :$pkgrel,
        Str :$pkgdesc,
        Str :$txndir,
        Int :$date-local-offset,
        Str :$template
    )
) is export returns Hash
{
    my %prepare = prepare(|%opts);
    my %build = build(:$file, |%prepare);
}

multi sub mktxn(
    Str $content,
    *%opts (
        Str :$pkgname,
        Str :$pkgver,
        Int :$pkgrel,
        Str :$pkgdesc,
        Str :$txndir,
        Int :$date-local-offset,
        Str :$template
    )
) is export returns Hash
{
    my %prepare = prepare(|%opts);
    my %build = build($content, |%prepare);
}

# end mktxn }}}

# prepare {{{

sub prepare(
    Str :$pkgname,
    Str :$pkgver,
    Int :$pkgrel,
    Str :$pkgdesc,
    Str :$txndir,
    Int :$date-local-offset,
    Str :$template
) returns Hash
{
    my %prepare = :dt(~DateTime.now);
    if $template
    {
        my %h; %h<date-local-offset> =
            Int($date-local-offset) if $date-local-offset;
        my %template = from-toml(:file($template), |%h);
        %prepare<pkgname> = %template<pkgname> if %template<pkgname>;
        %prepare<pkgver> = %template<pkgver> if %template<pkgver>;
        %prepare<pkgrel> = Int(%template<pkgrel>) if %template<pkgrel>;
        %prepare<pkgdesc> = %template<pkgdesc> if %template<pkgdesc>;
        if %template<txndir>
        {
            %prepare<txndir> = %template<txndir>.IO.is-relative
                # resolve txndir path relative to template file
                ?? ~join('/', $template.IO.dirname, %template<txndir>).IO.resolve
                # absolute txndir path given, use it directly
                !! %template<txndir>;
        }
        %prepare<date-local-offset> =
            Int(%template<date-local-offset>) if %template<date-local-offset>;
    }

    # cmdline flags overwrite template options if conflicts arise
    %prepare<pkgname> = $pkgname if $pkgname;
    %prepare<pkgver> = $pkgver if $pkgver;
    %prepare<pkgrel> = Int($pkgrel) if $pkgrel;
    %prepare<pkgdesc> = $pkgdesc if $pkgdesc;
    %prepare<txndir> = ~$txndir.IO.resolve if $txndir;
    %prepare<date-local-offset> = Int($date-local-offset) if $date-local-offset;

    # check for existence of pkgname, pkgver, and pkgrel
    die unless has-pkgname-pkgver-pkgrel(%prepare);

    %prepare;
}

# end prepare }}}

# build {{{

multi sub build(
    Str $content,
    Str :$dt!,
    Str :$txndir,
    Int :$date-local-offset,
    *%opts (
        Str :$pkgname,
        Str :$pkgver,
        Int :$pkgrel,
        Str :$pkgdesc,
    )
) returns Hash
{
    my %txninfo = gen-txninfo($dt, |%opts);

    my %h;
    %h<txndir> = $txndir if $txndir;
    %h<date-local-offset> = Int($date-local-offset) if $date-local-offset;
    my @txn = from-txn($content, |%h);

    # compute basic stats about the transaction journal
    %txninfo<count> = @txn.elems;
    %txninfo<entities-seen> = get-entities-seen(@txn);

    my %build = :$dt, :@txn, :%txninfo;
}

multi sub build(
    Str :$file!,
    Str :$dt!,
    Str :$txndir,
    Int :$date-local-offset,
    *%opts (
        Str :$pkgname,
        Str :$pkgver,
        Int :$pkgrel,
        Str :$pkgdesc,
    )
) returns Hash
{
    my Str $f = resolve-txn-file-path($file);

    my %txninfo = gen-txninfo($dt, |%opts);

    my %h;
    %h<txndir> = $txndir if $txndir;
    %h<date-local-offset> = Int($date-local-offset) if $date-local-offset;
    my @txn = from-txn(:file($f), |%h);

    # compute basic stats about the transaction journal
    %txninfo<count> = @txn.elems;
    %txninfo<entities-seen> = get-entities-seen(@txn);

    my %build = :$dt, :@txn, :%txninfo;
}

# end build }}}

# package {{{

sub package(%build (Str :$dt!, :@txn!, :%txninfo!))
{
    # make build directory
    my Str $build-dir = $*CWD ~ '/build';
    my Str $txninfo-file = "$build-dir/.TXNINFO";
    my Str $txnjson-file = "$build-dir/txn.json";
    mkdir $build-dir;

    # serialize .TXNINFO to JSON
    spurt $txninfo-file, Rakudo::Internals::JSON.to-json(%txninfo) ~ "\n";

    say "Creating txn pkg \"%txninfo<pkgname>\"…";

    # stringify DateTimes in preparation for JSON serialization
    loop (my Int $i = 0; $i < @txn.elems; $i++)
    {
        @txn[$i]<header><date> = ~@txn[$i]<header><date>;
    }

    # serialize transactions to JSON
    spurt $txnjson-file, Rakudo::Internals::JSON.to-json(@txn) ~ "\n";

    # compress
    my Str $tarball =
        "%txninfo<pkgname>-%txninfo<pkgver>-%txninfo<pkgrel>\.txn.tar.xz";
    shell "tar \\
             -C $build-dir \\
             --xz \\
             -cvf $tarball \\
             {$txninfo-file.IO.basename} {$txnjson-file.IO.basename}";

    say "Finished making: %txninfo<pkgname> ",
        "%txninfo<pkgver>-%txninfo<pkgrel> ($dt)";

    say "Cleaning up…";

    # clean up build directory
    dir($build-dir)».unlink;
    rmdir $build-dir;
}

# end package }}}

# gen-txninfo {{{

sub gen-txninfo(
    Str $dt,
    Str :$pkgname!,
    Str :$pkgver!,
    Int :$pkgrel!,
    Str :$pkgdesc
) returns Hash
{
    my %txninfo;
    %txninfo<pkgname> = $pkgname;
    %txninfo<pkgver> = $pkgver;
    %txninfo<pkgrel> = Int($pkgrel);
    %txninfo<pkgdesc> = $pkgdesc if $pkgdesc;

    # note the compiler name and version, and time of compile
    %txninfo<compiler> = $PROGRAM ~ ' v' ~ $VERSION ~ " $dt";

    %txninfo;
}

# end gen-txninfo }}}

# get-entities-seen {{{

sub get-entities-seen(@txn) returns Array
{
    my Str @entities-seen;

    for @txn -> $entry
    {
        for $entry<postings>.Array -> $posting
        {
            push @entities-seen, $posting<account><entity>;
        }
    }

    @entities-seen .= unique;
    @entities-seen .= sort;
}

# end get-entities-seen }}}

# resolve-txn-file-path {{{

multi sub exists-readable-file(
    Str $file,
    :@checks! where *.elems == 1
) returns Array
{
    exists-readable-file($file, :checks[|@checks, $file.IO.r]);
}

multi sub exists-readable-file(
    Str $file,
    :@checks! where *.elems == 2
) returns Array
{
    exists-readable-file($file, :checks[|@checks, $file.IO.f]);
}

multi sub exists-readable-file(
    Str $file,
    :@checks! where *.elems == 3
) returns Array
{
    @checks;
}

# you passed a direct-file-name.txn
multi sub exists-readable-file(
    Str $file where *.chars > 0 && *.IO.extension eq 'txn'
) returns Bool
{
    given exists-readable-file($file, :checks[$file.IO.e])
    {
        when $_[0] eqv False
        {
            die "Sorry, determined path 「$file」 does not exist";
        }
        when [True, True, True]
        {
            True;
        }
        when [True, True, False]
        {
            die "Sorry, determined path 「$file」 was not to file";
        }
        when [True, False, True]
        {
            die "Sorry, determined path 「$file」 was not readable";
        }
        when [True, False, False]
        {
            die "Sorry, determined path 「$file」 was not readable";
        }
    }
}

# you used a shortcut by leaving off the trailing chars '.txn'
multi sub exists-readable-file(Str $file where *.chars > 0) returns Bool
{
    # append .txn to bare file path
    given exists-readable-file("$file.txn", :checks["$file.txn".IO.e])
    {
        when $_[0] eqv False
        {
            die "Sorry, could not find txn file at path 「$file.txn」";
        }
        when [True, True, True]
        {
            True;
        }
        when [True, True, False]
        {
            die "Sorry, determined path 「$file.txn」 was not to file";
        }
        when [True, False, True]
        {
            die "Sorry, determined txn file at 「$file.txn」 was not readable";
        }
        when [True, False, False]
        {
            die "Sorry, determined path 「$file.txn」 was not readable";
        }
    }
}

# you didn't pass a filename
multi sub exists-readable-file(Str $file)
{
    die "txn file must exist";
}

sub resolve-txn-file-path(Str $file) returns Str
{
    die unless exists-readable-file($file);
    $file.IO.extension eq 'txn' ?? $file !! "$file.txn";
}

# end resolve-txn-file-path }}}

# has-pkgname-pkgver-pkgrel {{{

multi sub pkgname-pkgver-pkgrel(
    %txninfo,
    :@checks! where *.elems == 1
) returns Array
{
    pkgname-pkgver-pkgrel(%txninfo, :checks[|@checks, %txninfo<pkgver>:exists]);
}

multi sub pkgname-pkgver-pkgrel(
    %txninfo,
    :@checks! where *.elems == 2
) returns Array
{
    pkgname-pkgver-pkgrel(%txninfo, :checks[|@checks, %txninfo<pkgrel>:exists]);
}

multi sub pkgname-pkgver-pkgrel(
    %txninfo,
    :@checks! where *.elems == 3
) returns Array
{
    @checks;
}

sub has-pkgname-pkgver-pkgrel(%txninfo) returns Bool
{
    given pkgname-pkgver-pkgrel(%txninfo, :checks[%txninfo<pkgname>:exists])
    {
        when .grep(*.so).elems == .elems
        {
            True;
        }
        default
        {
            my Str $message = 'Sorry, ';
            my Str @missing;
            if $_[0] eqv False
            {
                push @missing, 'pkgname';
            }
            if $_[1] eqv False
            {
                push @missing, 'pkgver';
            }
            if $_[2] eqv False
            {
                push @missing, 'pkgrel';
            }
            $message ~= @missing.join(', ');
            $message ~= ' missing from %txninfo. Got:' ~ "\n";
            $message ~= %txninfo.perl;
            die $message;
        }
    }
}

# end has-pkgname-pkgver-pkgrel }}}

# vim: ft=perl6 fdm=marker fdl=0
