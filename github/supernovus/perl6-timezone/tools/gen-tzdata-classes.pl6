#!/usr/bin/env perl6
use v6;
#use Grammar::Tracer;

grammar TZData {
    token TOP {
        ^ [ <comment> | <rule> | <zone> | <link> ] * $
    }
    token comment {
        \s*'#'\N*\s*
    }
    token rule {
        Rule\s+<name>\s+<from>\s+<to>\s+<type>\s+<in>\s+<on>\s+<at>\s+<save>\s+<letter> <comment>? \s*
    }
    token zone {
        Zone\s+<name> <zonedata>+
    }
    token zonedata {
        \h*<!before Rule><!before Link><!before Zone><!before '#'><gmtoff>\s+<rules>\s+<format>[\h+<until>]? <comment>* \s*
    }
    token link {
        Link\s+<new-tz>\s+<old-tz> <comment>? \s*
    }
    token name { \S+ }
    token from { \S+ }
    token to { \S+ }
    token type { \S+ }
    token in { \S+ }
    token on { \S+ }
    token at { \S+ }
    token save { \S+ }
    token letter { \S+ }
    token gmtoff { \S+ }
    token rules { \S+ }
    token format { \S+ }
    token until { <-[#\n]>+ }
    token new-tz { \S+ }
    token old-tz { \S+ }
}

my %month-to-num = (
    Jan => 1,
    Feb => 2,
    Mar => 3,
    Apr => 4,
    May => 5,
    Jun => 6,
    Jul => 7,
    Aug => 8,
    Sep => 9,
    Oct => 10,
    Nov => 11,
    Dec => 12
);

my %day-to-num = (
    Mon => 1,
    Tue => 2,
    Wed => 3,
    Thu => 4,
    Fri => 5,
    Sat => 6,
    Sun => 7
);

sub MAIN($tzdata-file, $output-dir) {
    say "Outputting to $output-dir";
    say "Reading file $tzdata-file";
    my $text = slurp $tzdata-file;
    my $parsed = TZData.parse($text);

    if $parsed {
        say "parsed";
        my %ruledata;
        my @rules := $parsed<rule>;
        my @zones := $parsed<zone>;
        my @links := $parsed<link>;
        my $x = 0;
        say +@rules ~ " rules";
        say +@zones ~ " zones";
        say +@links ~ " links";
        for @rules -> $rule {
            my $yfrom = +$rule<from>;
            my $yto = ~$rule<to>;
            if $yto eq 'only' { $yto = $yfrom; }
            elsif $yto eq 'max' { $yto = Inf; }
            else { $yto = +$yto; }
            my $years = $yfrom..$yto;
            my $month = %month-to-num{$rule<in>};

            my %data = (years => $years, month => $month, time => ~$rule<at>, adjust => ~$rule<save>, letter => ~$rule<letter>);
            if $rule<on> ~~ /^\d+$/ {
                %data<date> = ~$rule<on>;
            } elsif $rule<on> ~~ /^last/ {
                my $tmp = ~$rule<on>;
                $tmp ~~ s/^last//;
                %data<lastdow> = %day-to-num{$tmp};
            } else {
                my @tmp = split(/\>\=/, ~$rule<on>);
                %data<dow> = ( dow => %day-to-num{@tmp[0]}, mindate => @tmp[1] ).hash;
            }
            my $tmp = %data;
            %ruledata{$rule<name>}.push($tmp);
        }

        for @zones -> $zone {
            my @dirs_to_make;
            my $name = ~$zone<name>;
            $name ~~ s:g/\+/_plus_/;
            $name ~~ s:g/\-/_minus_/;
            my $dir = ($output-dir ~ $name ~ ".pm6").IO.dirname;
            while !($dir.IO ~~ :d) {
                @dirs_to_make.unshift($dir);
                $dir = $dir.path.parent;
            }
            for @dirs_to_make -> $dir {
                mkdir($dir);
            }

            my $fh = open($output-dir ~ $name ~ ".pm6", :w);
            my $classname = $name;
            $classname ~~ s:g/\//::/;
            $fh.say("use v6;");
            $fh.say("use DateTime::TimeZone::Zone;");
            $fh.say("unit class DateTime::TimeZone::Zone::" ~ $classname ~ " does DateTime::TimeZone::Zone;");

            my @rules;
            my @zoneentries := $zone<zonedata>;
            my @zonedata;
            for @zoneentries -> $zoneentry {
                my $rule = "";
                if $zoneentry<rules> ne "-" {
                    $rule = ~$zoneentry<rules>;
                    if $rule ~~ /^\d+\:\d+/ {
                    } else {
                        @rules.push(~$zoneentry<rules>);
                    }
                }
                my $until = $zoneentry<until>;
                if $until {
                    $until = ~$until;
                    my @tmp = split(/\s+/, $until);
                    my @tmp_t;
                    if @tmp[3] {
                        @tmp_t = split(/\:/, @tmp[3]);
                        # TODO: I don't know what these characters represent.
                        # TODO: I should find out, since they're probably important...
                        @tmp_t[1] ~~ s/u$//;
                        @tmp_t[1] ~~ s/s$//;
                    }
                    if @tmp[1] {
                        @tmp[1] = %month-to-num{@tmp[1]};
                    }
                    my $until_dt;
                    # TODO: handle lastSun (we ignore it for now simply because I don't want to deal
                    # with it yet)
                    if @tmp[3] && @tmp[2] ne 'lastSat' && @tmp[2] ne 'lastSun' && @tmp[2] ne 'Sun>=1' {
                        $until_dt = DateTime.new(:year(+@tmp[0]), :month(+@tmp[1]), :day(+@tmp[2]), :hour(+@tmp_t[0]), :minute(+@tmp_t[1]));
                    } elsif @tmp[2] && @tmp[2] ne 'lastSat' && @tmp[2] ne 'lastSun' && @tmp[2] ne 'Sun>=1' {
                        $until_dt = DateTime.new(:year(+@tmp[0]), :month(+@tmp[1]), :day(+@tmp[2]));
                    } else {
                        $until_dt = DateTime.new(:year(+@tmp[0]));
                    }
                    $until = $until_dt.posix;
                } else {
                    $until = Inf;
                }
                my $data;
                if $rule ~~ /^\d+\:\d+/ {
                    my @rule = split(/\:/, $rule);
                    my @gmtoff = split(/\:/, ~$zoneentry<gmtoff>);
                    @gmtoff[0] += @rule[0];

                    my $gmt_final = @gmtoff[0] ~ ':' ~ sprintf('%02d', @gmtoff[1]);
                    if @gmtoff[2] {
                        $gmt_final ~= ':' ~ sprintf('%02d', @gmtoff[2]);
                    }

                    $data = ( until => $until, baseoffset => @gmtoff[0] ~ ':' ~ @gmtoff[1], rules => "" ).hash;
                } else {
                    $data = ( until => $until, baseoffset => ~$zoneentry<gmtoff>, rules => $rule ).hash;
                }
                @zonedata.push($data);
            }
            @rules = unique sort @rules;
            $fh.say('has %.rules = ( ');
            for @rules -> $rule {
                $fh.say(" $rule => " ~ %ruledata{$rule}.perl ~ ",");
            }
            $fh.say(");");
            $fh.say('has @.zonedata = ' ~ @zonedata.perl ~ ';');
            $fh.close();
        }

        for @links -> $link {
            my $old-tz = ~$link<old-tz>;
            $old-tz ~~ s:g/\+/_plus_/;
            $old-tz ~~ s:g/\-/_minus_/;
            my $new-tz = ~$link<new-tz>;
            $new-tz ~~ s:g/\+/_plus_/;
            $new-tz ~~ s:g/\-/_minus_/;

            my @dirs_to_make;
            my $dir = ($output-dir ~ $old-tz ~ ".pm6").IO.dirname;
            while !($dir.IO ~~ :d) {
                @dirs_to_make.unshift($dir);
                $dir = $dir.path.parent;
            }
            for @dirs_to_make -> $dir {
                mkdir($dir);
            }
            my $fh = open($output-dir ~ $old-tz ~ ".pm6", :w);

            $old-tz ~~ s:g/\//::/;
            $new-tz ~~ s:g/\//::/;

            $fh.say("use v6;");
            $fh.say("use DateTime::TimeZone::Zone::$new-tz;");
            $fh.say("unit class DateTime::TimeZone::Zone::$old-tz is DateTime::TimeZone::Zone::$new-tz;");
            $fh.close();
        }

        say "done";
    } else {
        say "Unable to parse."
    }
}
