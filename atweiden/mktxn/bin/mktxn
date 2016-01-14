#!/usr/bin/perl6




use v6;
constant $PROGRAM = 'mktxn';
constant $VERSION = '0.0.1';



# -----------------------------------------------------------------------------
# helper functions
# -----------------------------------------------------------------------------

sub get_entities_seen(@txn) returns Array[Str]
{
    my Str @entities_seen;

    for @txn -> $entry
    {
        for $entry<postings>.Array -> $posting
        {
            push @entities_seen, $posting<account><entity>;
        }
    }

    @entities_seen .= unique;
    @entities_seen .= sort;
}


# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------

# release
multi sub MAIN(
    Str:D $file,
    Str :D(:$description),
    Str :N(:$name),
    Int :R(:$release),
    Str :T(:$template),
    Str :V(:$version)
)
{
    my Str $dt = ~DateTime.now;

    # make build directory
    my Str $build_dir = $*CWD ~ '/build';
    my Str $txn_file = "$build_dir/txn.json";
    my Str $txninfo_file = "$build_dir/.TXNINFO";
    mkdir $build_dir;

    # parse build template into .TXNINFO
    my %txninfo;

    if $template
    {
        use Config::TOML;
        my %template = from-toml(slurp $template);
        %txninfo<name> = %template<name> if %template<name>;
        %txninfo<version> = %template<version> if %template<version>;
        %txninfo<release> = Int(%template<release>) if %template<release>;
        %txninfo<description> = %template<description> if %template<description>;
    }

    # cmdline options override values defined in template
    %txninfo<name> = $name if $name;
    %txninfo<version> = $version if $version;
    %txninfo<release> = Int($release) if $release;
    %txninfo<description> = $description if $description;

    # note the compiler name and version, and time of compile
    %txninfo<compiler> = "$PROGRAM $VERSION $dt";

    say "Making txn: %txninfo<name> %txninfo<version>-%txninfo<release> ($dt)";

    # parse transactions from journal
    use TXN::Parser;
    my Str:D $journal = TXN::Parser.preprocess(:$file);
    my @txn = TXN::Parser.parse($journal, :json).made;

    # compute basic stats about the transaction journal
    %txninfo<count> = @txn.elems;
    %txninfo<entities_seen> = get_entities_seen(@txn);

    # serialize .TXNINFO to JSON
    use JSON::Tiny;
    spurt $txninfo_file, to-json(%txninfo) ~ "\n";

    say "Creating txn \"%txninfo<name>\"...";

    # serialize transactions to JSON
    spurt $txn_file, to-json(@txn) ~ "\n";

    # compress
    my Str $tarball =
        "%txninfo<name>-%txninfo<version>-%txninfo<release>\.txn.tar.xz";
    shell "tar \\
             -C $build_dir \\
             --xz \\
             -cvf $tarball \\
             {$txninfo_file.IO.basename} {$txn_file.IO.basename}";

    say "Finished making: %txninfo<name> ",
        "%txninfo<version>-%txninfo<release> ($dt)";

    say "Cleaning up...";

    # clean up build directory
    dir($build_dir)».unlink;
    rmdir $build_dir;
}

# serialize
multi sub MAIN('serialize', Str:D $file, Str:D :m(:$mode) = 'perl', *%opts)
{
    use TXN;
    given $mode
    {
        when /:i perl/
        {
            say from-txn(:$file).perl;
        }
        when /:i json/
        {
            say from-txn(:$file, :json);
        }
        default
        {
            say "Sorry, invalid mode.\n";
            USAGE();
            exit;
        }
    }
}




# -----------------------------------------------------------------------------
# usage
# -----------------------------------------------------------------------------

sub USAGE()
{
    my Str:D $help_text = q:to/EOF/;
    Usage:
      mktxn [--name=NAME]
            [--version=VERSION]
            [--release=RELEASE]
            [--description=DESCRIPTION]
            [--template=TEMPLATE]
            FILE                            Make release build from file
      mktxn [--mode=MODE] serialize FILE    Serialize transaction journal

    optional arguments:
      -D, --description=DESCRIPTION
        the description of release build
      -N, --name=NAME
        the name of release build
      -R, --release=RELEASE
        the release number of release build
      -T, --template=TEMPLATE
        the location of the config template for release build
      -V, --version=VERSION
        the version number of release build
      -m, --mode=MODE
        the serialization format (json, perl)
    EOF
    say $help_text.trim;
}

# vim: ft=perl6
