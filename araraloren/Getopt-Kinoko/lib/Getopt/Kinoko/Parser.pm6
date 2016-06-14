
use v6;

use Getopt::Kinoko::Argument;
use Getopt::Kinoko::OptionSet;
use Getopt::Kinoko::Exception;

multi sub kinoko-parser(@args is copy, OptionSet \optset) is export returns Array {
    my Argument @noa = [];
    my $opt;
    my Str $optname;
    my $index = 0;

    my regex lprefix { '--' }
    my regex sprefix { '-'  }
    my regex optname { .*   { $optname = ~$/; } }

    while +@args > 0 {
        my \arg = @args.shift;

        given arg {
            when /^ [<lprefix> || <sprefix>] <.&optname> / {
                if optset.has-option($optname, long => $<lprefix>.defined, short => $<sprefix>.defined) {
                    $opt := optset.get-option($optname, long => $<lprefix>.defined, short => $<sprefix>.defined);

                    if +@args > 0 || $opt.is-boolean {
                        $opt.set-value-callback($opt.is-boolean ?? True !! @args.shift);
                    }
                    else {
                        X::Kinoko.new(msg => $optname ~ ": Need a value.").throw;
                    }
                }
                else {
                    X::Kinoko::Fail.new(msg => "$optname: Invalid option.").throw;
                }
            }
            default {
                @noa.push: Argument.new(value => arg, :$index);

                if +@noa > 0 {
                    if @noa.elems == 1 && optset.has-front() {
                        optset.get-front().process(@noa[0]);
                    }
                    if optset.has-each {
                        optset.get-each().process(@noa[@noa.end]);
                    }
                }
            }
        }

        $index++;
    }
    if optset.has-all {
        optset.get-all().process(@noa);
    }
    to-noa(@noa);
}

multi sub kinoko-parser(@args is copy, OptionSet \optset, $gnu-style) is export returns Array {
    my Argument @noa = [];
    my $opt;
    my $optname;
    my $optvalue;
    my $index = 0;

    my regex lprefix    { '--' }
    my regex sprefix    { '-'  }
    my regex optname    { <-[\=]>* { $optname = ~$/; } }
    my regex optvalue   { .*   }

    while +@args > 0 {
        my \arg = @args.shift;

        given arg {
            when /^ [<lprefix> || <sprefix>]  <.&optname> \= <optvalue> / {
                if optset.has-option($optname, long => $<lprefix>.defined, short => $<sprefix>.defined) {
                    $opt := optset.get-option($optname, long => $<lprefix>.defined, short => $<sprefix>.defined);
                    X::Kinoko.new(msg => $optname ~ ": Need a value.").throw 
                        if !$<optvalue>.defined && !$opt.is-boolean;
                    $opt.set-value-callback($opt.is-boolean ?? True !! $<optvalue>.Str);
                }
                elsif $<sprefix>.defined {
                    @args.unshift: | ( '-' X~ $optname.split("", :skip-empty) );
                }
                else {
                    X::Kinoko::Fail.new(msg => "$optname: Invalid option.").throw;
                }
            }
            when /^ [<lprefix> || <sprefix>] <.&optname> / {
                if optset.has-option($optname, long => $<lprefix>.defined, short => $<sprefix>.defined) {
                    $opt := optset.get-option($optname, long => $<lprefix>.defined, short => $<sprefix>.defined);
                    #$last-is-boolean = $opt.is-boolean;
                    if +@args > 0 || $opt.is-boolean {
                        $opt.set-value-callback($opt.is-boolean ?? True !! @args.shift);
                    }
                    else {
                        X::Kinoko.new(msg => $optname ~ ": Need a value.").throw;
                    }
                }
                else {
                    X::Kinoko::Fail.new(msg => "$optname: Invalid option.").throw;
                }
            }
            default {
                #W::Kinoko.new("Argument behind boolean option.").warn if $last-is-boolean;
                #| argument behind boolean option also be a noa
                @noa.push: Argument.new(value => arg, :$index);

                if +@noa > 0 {
                    if @noa.elems == 1 && optset.has-front() {
                        optset.get-front().process(@noa[0]);
                    }
                    if optset.has-each {
                        optset.get-each().process(@noa[@noa.end]);
                    }
                }
            }
        }

        $index++;
    }
    if optset.has-all {
        optset.get-all().process(@noa);
    }
    to-noa(@noa);
}

sub to-noa(@noa-argument) {
    Array.new(@noa-argument.map: { .value });
}