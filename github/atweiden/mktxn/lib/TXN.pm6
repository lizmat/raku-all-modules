use v6;
use Config::TOML;
use File::Presence;
use TXN::Parser;
use TXN::Parser::Types;
use TXN::Remarshal;
unit module TXN;

constant $PROGRAM = 'mktxn';
constant $VERSION = v0.0.7;

# TXN::Package::Prepare {{{

my class TXN::Package::Prepare
{
    # --- class attributes {{{

    has VarNameBare:D $.pkgname is required;
    has Version:D $.pkgver is required;
    has UInt:D $.pkgrel = 1;
    has Str $.pkgdesc;
    has Int $.date-local-offset;
    has Str $.txn-dir;

    # --- end class attributes }}}

    # --- submethod BUILD {{{

    submethod BUILD(
        Str:D :$pkgname! where *.so,
        Str:D :$pkgver! where *.so,
        Int :$pkgrel,
        Str :$pkgdesc,
        Int :$date-local-offset,
        Str :$txn-dir
    )
    {
        $!pkgname = $pkgname;
        $!pkgver = Version.new($pkgver);
        $!pkgrel = $pkgrel.UInt if $pkgrel;
        $!pkgdesc = $pkgdesc if $pkgdesc;
        $!date-local-offset = $date-local-offset if $date-local-offset;
        $!txn-dir = $txn-dir if $txn-dir;
    }

    # --- end submethod BUILD }}}
    # --- method new {{{

    # merge build settings from TOML template if one is provided
    multi method new(
        Str:D :$template! where *.so,
        Str :$pkgname,
        Str :$pkgver,
        Int :$pkgrel,
        Str :$pkgdesc,
        Int :$date-local-offset,
        Str :$txn-dir
    )
    {
        my %prepare;
        my %template = do {
            my %h;
            %h<date-local-offset> = $date-local-offset if $date-local-offset;
            from-toml(:file($template), |%h);
        }

        %prepare<pkgname> = %template<pkgname> if %template<pkgname>;
        %prepare<pkgver> = %template<pkgver> if %template<pkgver>;
        %prepare<pkgrel> = %template<pkgrel>.UInt if %template<pkgrel>;
        %prepare<pkgdesc> = %template<pkgdesc> if %template<pkgdesc>;

        if %template<txn-dir>
        {
            %prepare<txn-dir> = %template<txn-dir>.IO.is-relative
                # resolve C<txn-dir> path relative to template file
                ?? join('/', $template.IO.dirname, %template<txn-dir>)
                # absolute path for C<txn-dir> given, use it directly
                !! %template<txn-dir>;
        }

        if %template<date-local-offset>
        {
            %prepare<date-local-offset> = Int(%template<date-local-offset>);
        }

        # overwrite template options if conflicts arise
        %prepare<pkgname> = $pkgname if $pkgname;
        %prepare<pkgver> = $pkgver if $pkgver;
        %prepare<pkgrel> = $pkgrel.UInt if $pkgrel;
        %prepare<pkgdesc> = $pkgdesc if $pkgdesc;
        %prepare<date-local-offset> = $date-local-offset if $date-local-offset;
        %prepare<txn-dir> = $txn-dir if $txn-dir;

        self.bless(|%prepare);
    }

    multi method new(
        Str :$pkgname,
        Str :$pkgver,
        Int :$pkgrel,
        Str :$pkgdesc,
        Int :$date-local-offset,
        Str :$txn-dir,
        Str :$template
    )
    {
        my %prepare;
        %prepare<pkgname> = $pkgname if $pkgname;
        %prepare<pkgver> = $pkgver if $pkgver;
        %prepare<pkgrel> = $pkgrel.UInt if $pkgrel;
        %prepare<pkgdesc> = $pkgdesc if $pkgdesc;
        %prepare<date-local-offset> = $date-local-offset if $date-local-offset;
        %prepare<txn-dir> = $txn-dir if $txn-dir;
        self.bless(|%prepare);
    }

    # --- end method new }}}
}

# end TXN::Package::Prepare }}}
# TXN::Package {{{

my class TXN::Package
{
    # --- attributes {{{

    # e.g. "mktxn v0.0.2 2016-05-10T10:22:44.054586-07:00"
    has Str:D $!compiler is required;

    # accounting ledger AST
    has TXN::Parser::AST::Entry @!entry is required;

    # number of entries in @!entry
    has UInt:D $!count is required;

    # entities seen in @!entry
    has VarName:D @!entities-seen is required;

    # package info
    has VarNameBare:D $!pkgname is required;
    has Version:D $!pkgver is required;
    has UInt:D $!pkgrel is required;
    has Str $!pkgdesc;

    # --- end attributes }}}

    # --- submethod BUILD {{{

    submethod BUILD(
        Str:D :$!compiler! where *.so,
        TXN::Parser::AST::Entry :@!entry!,
        UInt:D :$!count!,
        Str:D :@!entities-seen! where *.so,
        VarNameBare:D :$!pkgname!,
        Version:D :$!pkgver!,
        UInt:D :$!pkgrel!,
        Str :$pkgdesc
    )
    {
        $!pkgdesc = $pkgdesc if $pkgdesc;
    }

    # --- end submethod BUILD }}}
    # --- method new {{{

    method new(
        # whether C<$cf> is content of a file, or is a file path
        #
        # if file path, we pass as arg C<:file> to C<from-txn> to get
        # proper include directive handling
        Str:D $content-or-file where /CONTENT|FILE/,

        # the content of a file, or file path
        Str:D $cf,

        # whether to print console progress messages
        Bool:D :$verbose = False,

        *%opts (
            Str :pkgname($),
            Str :pkgver($),
            Int :pkgrel($),
            Str :pkgdesc($),
            Int :date-local-offset($),
            Str :txn-dir($),
            Str :template($)
        )
    )
    {
        my %bless;

        my TXN::Package::Prepare:D $prepare = TXN::Package::Prepare.new(|%opts);

        my VarNameBare:D $pkgname = $prepare.pkgname;
        my Version:D $pkgver = $prepare.pkgver;
        my UInt:D $pkgrel = $prepare.pkgrel;
        my Str:D $pkgdesc = $prepare.pkgdesc if $prepare.pkgdesc;

        my DateTime:D $dt = now.DateTime;

        say("Making txn pkg: $pkgname $pkgver-$pkgrel ($dt)") if $verbose;

        my Str:D $compiler = "$PROGRAM v$VERSION $dt";

        # parse the accounting ledger
        my %h;
        %h<date-local-offset> = $prepare.date-local-offset
            if $prepare.date-local-offset.defined;
        %h<txn-dir> = $prepare.txn-dir if $prepare.txn-dir;
        my TXN::Parser::AST::Entry @entry = do given $content-or-file
        {
            when 'CONTENT' { from-txn($cf, |%h) }
            when 'FILE' { from-txn(:file($cf), |%h) }
        }

        # compute basic stats about the accounting ledger
        my UInt:D $count = @entry.elems;
        my VarName:D @entities-seen = get-entities-seen(@entry);

        %bless<compiler> = $compiler;
        %bless<entry> = @entry;
        %bless<count> = $count;
        %bless<entities-seen> = @entities-seen;
        %bless<pkgname> = $pkgname;
        %bless<pkgver> = $pkgver;
        %bless<pkgrel> = $pkgrel;
        %bless<pkgdesc> = $pkgdesc if $pkgdesc;

        self.bless(|%bless);
    }

    # --- end method new }}}

    # --- method hash {{{

    method hash(::?CLASS:D: --> Hash:D)
    {
        %(
            :@!entry,
            :txn-info(%(
                :$!compiler,
                :$!count,
                :@!entities-seen,
                :$!pkgdesc,
                :$!pkgname,
                :$!pkgrel,
                :$!pkgver
            ))
        );
    }

    # --- end method hash }}}

    # --- sub get-entities-seen {{{

    sub get-entities-seen(TXN::Parser::AST::Entry:D @entry --> Array:D)
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

    # --- end sub get-entities-seen }}}
}

# end TXN::Package }}}

# sub mktxn {{{

multi sub mktxn(
    Str:D :$file! where *.so,
    Bool:D :$release! where *.so,
    *%opts (
        Str :pkgname($),
        Str :pkgver($),
        Int :pkgrel($),
        Str :pkgdesc($),
        Str :txn-dir($),
        Int :date-local-offset($),
        Str :template($)
    )
) is export
{
    my Str:D $f = resolve-txn-file-path($file);
    my %txn-package = TXN::Package.new('FILE', $f, :verbose, |%opts).hash;
    package(%txn-package);
}

multi sub mktxn(
    Str:D $content,
    Bool:D :$release! where *.so,
    *%opts (
        Str :pkgname($),
        Str :pkgver($),
        Int :pkgrel($),
        Str :pkgdesc($),
        Str :txn-dir($),
        Int :date-local-offset($),
        Str :template($)
    )
) is export
{
    my %txn-package =
        TXN::Package.new('CONTENT', $content, :verbose, |%opts).hash;
    package(%txn-package);
}

multi sub mktxn(
    Str:D :$file! where *.so,
    *%opts (
        Str :pkgname($),
        Str :pkgver($),
        Int :pkgrel($),
        Str :pkgdesc($),
        Str :txn-dir($),
        Int :date-local-offset($),
        Str :template($)
    )
    --> Hash:D
) is export
{
    TXN::Package.new('FILE', $file, |%opts).hash;
}

multi sub mktxn(
    Str:D $content,
    *%opts (
        Str :pkgname($),
        Str :pkgver($),
        Int :pkgrel($),
        Str :pkgdesc($),
        Str :txn-dir($),
        Int :date-local-offset($),
        Str :template($)
    )
    --> Hash:D
) is export
{
    TXN::Package.new('CONTENT', $content, |%opts).hash;
}

# end sub mktxn }}}
# sub package {{{

# serialize to JSON files on disk
sub package(% (TXN::Parser::AST::Entry :@entry!, :%txn-info!))
{
    say("Creating txn pkg \"%txn-info<pkgname>\"…");

    # make build directory
    my Str:D $build-dir = "$*CWD/build";
    my Str:D $txn-info-file = "$build-dir/.TXNINFO";
    my Str:D $txn-json-file = "$build-dir/txn.json";
    mkdir($build-dir);

    # serialize .TXNINFO to JSON
    spurt($txn-info-file, Rakudo::Internals::JSON.to-json(%txn-info) ~ "\n");

    # serialize ledger AST to JSON
    spurt(
        $txn-json-file,
        Rakudo::Internals::JSON.to-json(
            remarshal(@entry, :if<entry>, :of<hash>)
        ) ~ "\n"
    );

    # compress
    my Str:D $tarball =
        "%txn-info<pkgname>-%txn-info<pkgver>-%txn-info<pkgrel>\.txn.tar.xz";
    shell("tar \\
             -C $build-dir \\
             --xz \\
             -cvf $tarball \\
             {$txn-info-file.IO.basename} {$txn-json-file.IO.basename}");

    my Str:D $dt = %txn-info<compiler>.split(' ')[*-1];
    say("Finished making: %txn-info<pkgname> ",
        "%txn-info<pkgver>-%txn-info<pkgrel> ($dt)");

    # clean up build directory
    say('Cleaning up…');
    dir($build-dir).race.map({ .unlink });
    rmdir($build-dir);
}

# end sub package }}}
# sub resolve-txn-file-path {{{

multi sub resolve-txn-file-path(
    Str:D $file where *.IO.extension eq 'txn'
    --> Str:D
)
{
    exists-readable-file($file)
        or die;
    $file;
}

multi sub resolve-txn-file-path(Str:D $file where *.so --> Str:D)
{
    exists-readable-file("$file.txn")
        or die;
    "$file.txn";
}

# end sub resolve-txn-file-path }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
