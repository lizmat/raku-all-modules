
use Getopt::Advance::Utils;

unit module Getopt::Advance::Helper;

constant HELPOPTSUPPORT = 5; #| option number can display in usage
constant HELPPOSSUPPORT = 2;
constant HELPFRONTSUPPORT = 1;
constant HELPNOCOMMAND  = 'NOCOMMAND';

role Helper is export {
    has Str $.program is rw;    #| program name
    has Str $.main is rw;       #| main usage
    has @.cmd;                  #| all cmd
    has %.pos;                  #| key is position, value is POS
    has %.option;               #| key is usage, value is option
    has @.multi;                #| multi group
    has @.radio;                #| radio group
    has @.usage-cache;
    has @.full-usage-cache;
    has @.annotation-cache;
    has @.cmdusage-cache;
    has @.posusage-cache;
    has $.maxopt is rw = HELPOPTSUPPORT;
    has $.maxpos is rw = HELPPOSSUPPORT;
    has $.maxfront is rw = HELPFRONTSUPPORT;
    has $!group-usage-cache;
    has $.commandhit is rw  = 'COMMAND';
    has $.optionhit  is rw  = 'OPTIONs';
    has $.positionhit is rw = 'POSITIONs';
    has $.usagehit is rw    = 'Usage:';

    method reset-cache() {
        @!usage-cache = [];
        @!full-usage-cache = [];
        @!annotation-cache = [];
        @!cmdusage-cache = [];
        @!posusage-cache = [];
        $!group-usage-cache = "";
    }

    method merge-group-usage() {
        unless $!group-usage-cache ne "" {
            my ($usage, %optionref) = ("", %!option);
            my @t;

            for @!multi -> $multi {
                @t = [];
                @t.push(.optref.usage()) for $multi.infos;
                $usage ~= ( $multi.optional ?? '[' !! '<' );
                $usage ~= @t.join(",");
                $usage ~= ( $multi.optional ?? ']' !! '>' );
                $usage ~= ' ';
                %optionref{@t}:delete;
            }
            for @!radio -> $radio {
                @t = [];
                @t.push(.optref.usage()) for $radio.infos;
                $usage ~= ( $radio.optional ?? '[' !! '<' );
                $usage ~= @t.join(",");
                $usage ~= ( $radio.optional ?? ']' !! '>' );
                $usage ~= ' ';
                %optionref{@t}:delete;
            }
            for %optionref -> $item {
                $usage ~= ( $item.value.optional ?? '[' !! '<' );
                $usage ~= $item.key;
                $usage ~= ( $item.value.optional ?? ']' !! '>' );
                $usage ~= ' ';
            }
            $!group-usage-cache = $usage;
        }
        $!group-usage-cache;
    }

    method concatopt($optcnt, $preusage, @pos, :$merge-group, :$full = False) {
        my $usage = $preusage;
        if +@pos > $!maxpos && !$full {
            $usage ~= "[{$!positionhit}] ";
        } else {
            $usage ~= .Str ~ " " for @pos;
        }
        if $optcnt > 0 {
            if $full || ($optcnt <= $!maxopt && +@pos <= $!maxpos) {
                if ! $merge-group {
                    for %!option.sort(*.key) {
                        $usage ~= (.value.optional ?? '[' !! '<');
                        $usage ~= .key;
                        $usage ~= (.value.optional ?? ']' !! '>');
                        $usage ~= ' ';
                    }
                } else {
                    $usage ~= self.merge-group-usage();
                }
            } else {
                $usage ~= "[{$!optionhit}] ";
            }
        }
        $usage ~= $!main;
        $usage;
    }

    method usage(:$merge-group) {
        unless +@!usage-cache > 0 {
            my ($front, @pos);
            my $optcnt = %!option.keys.elems;

            # front is CMDs and POSs@0
            $front = +@!cmd;
            $front += +@(%!pos{0}) if (%!pos{0}:exists) && (+@!cmd > 0);
            for %!pos.sort(*.key) -> $item {
                given $item.value {
                    @pos.push('[' ~ @($_)>>.usage.join("|") ~ ']');
                }
            }
            @pos.shift() if (%!pos{0}:exists) && (+@!cmd > 0);
            if $front > 0 {
                @!usage-cache.push(self.concatopt($optcnt, "<{$!commandhit}> ", @pos, :$merge-group))
            } else {
                @!usage-cache.push(self.concatopt($optcnt, "", @pos, :$merge-group));
            }
        }
        @!usage-cache;
    }

    method full-usage(:$merge-group) {
        unless +@!full-usage-cache > 0 {
            my (@front, @pos);

            @front = [ .usage() for @!cmd ];
            if (%!pos{0}:exists) && (+@!cmd > 0) {
                for @(%!pos{0}) -> $pos {
                    @front.push($pos.usage());
                }
            }
            for %!pos.sort(*.key) -> $item {
                given $item.value {
                    @pos.push('[' ~ @($_)>>.usage.join("|") ~ ']');
                }
            }
            @pos.shift() if (%!pos{0}:exists) && (+@!cmd > 0);
            if +@front > 0 {
                my $refusage = self.concatopt(1, "", @pos, :$merge-group, :full);
                for @front -> $front {
                    @!full-usage-cache.push([
                        $front,
                        $refusage,
                    ]);
                }
            } else {
                @!full-usage-cache.push([
                    HELPNOCOMMAND,
                    self.concatopt(1, "", @pos, :$merge-group, :full)
                ]);
            }
        }
        @!full-usage-cache;
    }

    method annotation() {
        unless +@!annotation-cache > 0 {
            my @annotation;

            for %!option.sort(*.key) -> $item {
                @annotation.push(
                    [
                        $item.key,
                        do given $item.value {
                            .annotation ~ do {
                                if .has-default-value {
                                    "[" ~ .default-value ~ "]";
                                } else {
                                    "";
                                }
                            }
                        }
                    ]
                )
            }

            @!annotation-cache = @annotation.sort(*.[0]);
        }
        @!annotation-cache;
    }

    method cmdusage() {
        unless +@!cmdusage-cache > 0 {
            for @!cmd -> $cmd {
                @!cmdusage-cache.push(
                    [$cmd.usage(), $cmd.annotation]
                );
            }
            if (+@!cmd > 0) && (%!pos{0}:exists) {
                for @(%!pos{0}) -> $item {
                    given $item {
                        @!cmdusage-cache.push(
                            [ .usage(), .annotation]
                        );
                    }
                }
            }
        }
        @!cmdusage-cache;
    }

    method posusage() {
        unless +@!posusage-cache > 0 {
            for %!pos.sort(*.key) -> $posarray {
                next if (+@!cmd > 0) && ($posarray.key == 0);
                for @($posarray.value) -> $pos {
                    given $pos {
                        @!posusage-cache.push(
                            [.usage(), .annotation()]
                        );
                    }
                }
            }
        }
        @!posusage-cache;
    }
}

multi sub ga-helper($optset, $outfh, *%args) is export {
    my $helper = &ga-helper-impl($optset);
    my $newline= %args<compact-help> ?? "" !! "\n";

    $outfh.say($helper.usagehit);
    $outfh.say("  {$helper.program} " ~ .Str ~ $newline) for $helper.usage(|%args);

    require Terminal::Table <&array-to-table>;

    my @cmdu = $helper.cmdusage();
    my @posu = $helper.posusage();
    my @annotation = $helper.annotation();
    my ($cmd, $pos, $opt) = (+@cmdu, +@posu, +@annotation);
    my @all = |@cmdu, |@posu, |@annotation;

    if +@all > 0 {
        @all = &array-to-table(@all, style => 'none');
    }
    if $cmd > 0 && (! %args<disable-cmd-help>) {
        $outfh.say($helper.commandhit ~ ($cmd > 1 ?? "s" !! ""));
        $outfh.say("  " ~ .join(" ") ~ $newline) for @all[^$cmd];
    }
    if $pos > 0 && (! %args<disable-pos-help>) {
        $outfh.say($helper.positionhit);
        $outfh.say("  " ~ .join(" ") ~ $newline) for @all[$cmd .. ($cmd + $pos) - 1];
    }
    if $opt > 0 {
        $outfh.say($helper.optionhit);
        $outfh.say("  " ~ .join(" ") ~ $newline) for @all[($cmd + $pos) .. * - 1];
    }
}

multi sub ga-helper(@optset, $outfh, *%args) is export {
    if +@optset == 1 {
        # Using a detailed format
        &ga-helper(@optset[0], $outfh, |%args);
    } else {
        # Using a rough format
        my @helpers = [ &ga-helper-impl($_) for @optset ];
        my $newline = %args<compact-help> ?? "" !! "\n";
        my ($cmd, $pos, $opt) = (0, 0, 0);

        for @helpers -> $helper {
            $cmd += $helper.cmd().elems();
            {
                my %pos := $helper.pos();
                my $front= 0;

                if (%pos{0}:exists) && ($helper.cmd().elems() > 0) {
                    $front = %pos{0}.elems();
                }
                for %pos.values -> $posarray {
                    $pos += $posarray.elems();
                }
                $pos -= $front;
                $cmd += $front;
            }
            $opt += $helper.option().elems();
        }
        $outfh.say(@helpers[0].usagehit);
        $outfh.say(
            "  " ~
            "{@helpers[0].program} " ~
            "{$cmd > 0 ?? "<{@helpers[0].commandhit}> " !! ""}" ~
            "{$pos > 0 ?? "[{@helpers[0].positionhit}] "!! ""}" ~
            "{$opt > 0 ?? "[{@helpers[0].optionhit}] "  !! ""}" ~
            @helpers[0].main ~
            $newline
        );

        require Terminal::Table <&array-to-table>;

        if $cmd > 0 {
            $outfh.say(@helpers[0].commandhit);
            my @allcmd;
            @allcmd.append(.cmdusage()) for @helpers;
            @allcmd = &array-to-table(@allcmd, style => 'none');
            for @allcmd -> $cmd {
                $outfh.say("  " ~ $cmd.join(" ") ~ $newline);
            }
        }
        if $opt > 0 {
            $outfh.say(@helpers[0].optionhit);
            if %args<one-section-cmd> {
                my @allfullusage;

                for @helpers -> $helper {
                    my @fullusage = $helper.full-usage(|%args);

                    if +@fullusage > 0 && $helper.option.elems > 0 {
                        @allfullusage.append(@fullusage);
                    }
                }
                @allfullusage = &array-to-table(@allfullusage, style => 'none');
                for @allfullusage -> $array {
                    $outfh.say("  " ~ $array.join(" ") ~ $newline);
                }
            } else {
                for @helpers -> $helper {
                    my @fullusage = $helper.full-usage(|%args);

                    if +@fullusage > 0 && $helper.option.elems > 0 {
                        $outfh.say("  " ~ @fullusage>>.[0].join(", "));
                        if +@fullusage > 1 {
                            $outfh.say("    <{@helpers[0].commandhit}> {@fullusage[0][1]}{$newline}");
                        } else {
                            if @fullusage[0][0] eq HELPNOCOMMAND {
                                $outfh.say("    {@fullusage[0][1]}{$newline}");
                            } else {
                                $outfh.say("    {@fullusage[0][0]} {@fullusage[0][1]}{$newline}");
                            }
                        }
                    }
                }
            }
        }
    }
}

constant &ga-helper2 is export = &ga-helper;

sub ga-helper-impl($optset) is export {
    my @cmd = $optset.get-cmd().values;
    my %pos;

    Debug::debug("Call ga-helper-impl generate Helper object.");
    for $optset.get-pos().values -> $pos {
        %pos{
            $pos.index ~~ WhateverCode ??
                $pos.index.(MAXPOSSUPPORT) !!
                $pos.index
        }.push($pos);
    }

    my %option;

    for $optset.options -> $opt {
        %option{$opt.usage()} = $opt;
    }

    return Helper.new(
        program => $*PROGRAM-NAME,
        cmd     => @cmd,
        pos     => %pos,
        main    => "",
        option  => %option,
        multi   => $optset.multi,
        radio   => $optset.radio,
    );
}

sub ga-version($version, $outfh) is export {
    $outfh.print($version) if $version ne "";
}
