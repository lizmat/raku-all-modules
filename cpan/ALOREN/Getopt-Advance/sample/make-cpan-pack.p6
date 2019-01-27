#!/usr/bin/env perl6

use JSON::Fast;
use Getopt::Advance;
use File::Directory::Tree;

my $json = Q:to/OPTION/;
{
    "option": [
        {
            "short": "ver",
            "type" : "s",
            "annotation": "Using ver instead of version info in META6.json"
        },
        {
            "short": "out",
            "type" : "s",
            "value": ".",
            "annotation": "Set the pack output directory"
        },
        {
            "short": "md",
            "type" : "b",
            "annotation": "Convert the asciidoc(README) to markdown"
        }
    ]
}
OPTION

sub load-from-json($os, $json) {
    my @json := (from-json $json)<option>;

    for @json -> $info {
        my $optstr = "{$info<short>}|={$info<type>}";
        my $annotation = $info<annotation>;

        $os.push(my $opt = $os.create( $optstr, :$annotation));
        if $info<value>:exists {
            $opt.set-default-value($info<value>);
            $opt.reset-value;
        }
    }
    $os;
}

my OptionSet $os .= new;

$os.append(
    "h|help=b"      => 'Print the help message',
    "v|version=b"   => 'Print the version info',
    "d|debug=b"     => 'Print debug message',
);
$os.insert-pos(
    "module",
    sub ($os, $dir) {
        my ($ver, $debug) = ($os<ver> // "", $os<debug>);

        my ($in, $out) = ($dir.value.IO, ($os<out> // "").IO);

        die "Not a valid directory: $in"  if $in !~~ :d;
        die "Not a valid directory: $out" if $out !~~ :d;

        note ">> Get module directory: [{$dir.value}]" if $debug;

        my $meta = $in.add("META6.json");

        die "Can not found the META6.json in {$dir.value}!" if $meta !~~ :f;

        note ">> Check META6.json ok" if $debug;

        my %meta = from-json $meta.IO.slurp;

        if (%meta<name>:!exists) || ((%meta<version>:!exists) && $ver eq "") {
            die "Please make sure your META6.json is valid";
        }

        my ($name, $version) = (%meta<name>, %meta<version>);

        note ">> Get name: [$name]" if $debug;
        note ">> Get version: [$version]" if $debug;

        my @file = $in.dir(test => /^<-[\.]>/);

        my $packname = $name.subst("::", "-") ~ "-{$version}";

        note ">> Create pack directory {$packname}" if $debug;

        $out.add($packname).mkdir;

        note ">> Move the file to pack directory" if $debug;

        for @file -> $file {
            shell("cp -rf {$file.basename} {$out.add($packname)}");
        }
        note ">> Clean the precomp cache" if $debug;

        rmtree $out.add($packname).add('lib').add('.precomp').path;

        my $olddir = $*CWD;
        chdir($out.add($packname));
        if $os<md> {
            note ">> Conver the README" if $debug;
            shell(
                Q:to/CONVERT/
                asciidoctor -b docbook README.adoc;
                iconv -t utf8 README.xml > README.xml2;
                rm -f README.xml;
                pandoc -f docbook -t gfm README.xml2 -o README.md;
                rm -f README.xml2;
                rm -f README.adoc;
                CONVERT
            );
        }
        chdir($olddir);

        note ">> Make package" if $debug;

        shell("tar -zcvf $packname.tar.gz $packname");

        note ">> Remove pack directory {$packname}" if $debug;

        rmtree $out.add($packname).path;
    },
    :last,
);
&getopt(
    :autohv,
    &load-from-json($os, $json),
    version => Q:to/VERSION/,
    make-cpan-pack 0.1.
    Make cpan package according the module META6.json.
    Create by loren.
    VERSION
);
