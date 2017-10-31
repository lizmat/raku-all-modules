#!/usr/bin/env perl6

use v6;
use Getopt::Advance;
use Getopt::Advance::Exception;

my OptionSet $os .= new();

$os.append(
    "h|help=b" => 'print this help message.',
    "v|version=b" => 'print program version.',
    :multi
);
$os.push(
    "s|static=s",
    "set static directory name.",
    value => "static"
);
$os.push(
    "d|dynamic=s",
    "set dynamic directory name.",
    value => "dynamic"
);
$os.push(
    "o|output=s",
    "set output directory.",
    value => "output",
    callback => sub check($, $dir) {
        given $dir.IO {
            if not .e && not .d {
                "Erro: directory $dir not valid".say;
                &ga-want-helper();
            }
        }
    }
);
$os.insert-cmd("simple");

constant DYNAMIC = q:to/DYNAMIC/;
[images]
force_sprites=YES

[sprite]
ftime=2 fps
atime=3000000
DYNAMIC

constant STATIC = q:to/STATIC/;
[images]
force_sprites=YES

[sprite]
ftime=2 fps
atime=3000000
STATIC

constant NONE = q:to/NONE/;
[images]
force_sprites=YES

[sprite]
id=SYMBOL_NONE
ftime=2 fps
NONE

# insert a pos 
$os.insert-pos(
    "directory",
    sub make-symbol ($os, $dira) {
        return if $os<h> || $os<v>; # maybe add a help function check autohv 
        my ($dir, $out) = ($dira.value.IO, $os<output>.IO);

        $dir.add("reel.png").copy($out.add("reel.png"));
        $out.add("settings.ini").open(:w).spurt(:close, NONE);
        for $dir.dir -> $fh {
            if $fh.d {
                my @subf = $fh.dir();

                if +@subf == 1 && @subf[0].basename ~~ /.*png$/ {
                    my $symbol = $out.add($fh.basename).mkdir;
                    my $name   = $fh.basename;

                    $symbol.add($os<static>).mkdir;
                    $symbol.add($os<dynamic>).mkdir;

                    # copy dynamic png
                    @subf[0].copy($symbol.add($os<dynamic>).add($name ~ ".png"));
                    # create settings.ini
                    $symbol.add($os<dynamic>).add("settings.ini").open(:w).spurt(
                        :close,
                        DYNAMIC
                    );

                    # create link of reel and *.png
                    $symbol.add($os<static>).add("{$name}_000.png.link").open(:w).spurt(
                        Q :c !"/symbols/{$name}/{$os<dynamic>}/{$name}.png"!
                    );
                    $symbol.add($os<static>).add("{$name}_001.png.link").open(:w).spurt(
                        Q !"/symbols/reel.png"!
                    );
                    # create settings.ini
                    $symbol.add($os<static>).add("settings.ini").open(:w).spurt(
                        :close,
                        STATIC
                    );
                }
            }
        }
    },
    :last,
);

&getopt($os, :autohv, version => "Version 0.0.1."); # autohv will handle <help> or <version>
