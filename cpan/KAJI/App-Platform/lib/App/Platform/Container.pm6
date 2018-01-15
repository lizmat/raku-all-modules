use v6;
use App::Platform::Output;
use App::Platform::Command;
use App::Platform::Util::OS;
use Terminal::ANSIColor;

class App::Platform::Container is App::Platform::Output {

    has Str $.name is rw;
    has Str $.hostname is rw;
    has Str $.network = 'acme';
    has Bool $.network-exists = False;
    has Str $.domain = 'localhost';
    has Str $.dns;
    has Int $.dns-port = 53;
    has Str $.data-path is rw;
    has Str $.projectdir;
    has Hash $.config-data;
    has %.last-result;
    has Str $.help-hint is rw;
    has Bool $.skip-dotfiles = False;

    submethod TWEAK {
        $!data-path .= subst(/\~/, $*HOME);
        my $resolv-conf = $!data-path ~ '/resolv.conf';
        if $resolv-conf.IO.e {
            my $found = $resolv-conf.IO.slurp ~~ / nameserver \s+ $<ip-address> = [ \d+\.\d+\.\d+\.\d+ ] /;
            $!dns = $found ?? $/.hash<ip-address>.Str !! '';
        }
        my $proc = run <docker network inspect>, $!network, :out, :err;
        my $out = $proc.out.slurp-rest(:close);
        # $!network-exists = $out.Str.trim ne '[]';
    }

    method result-as-hash($proc) {
        my $out = ($proc ~~ App::Platform::Command) ?? $proc.out !! $proc.out.slurp-rest(:close);
        my $err = ($proc ~~ App::Platform::Command) ?? $proc.err !! $proc.err.slurp-rest;
        $err = '' if $err ~~ / ^ "Unable to find image" /; # Normal fetch operation
        my %result =
            ret => $err.chars == 0,
            out => $out,
            err => $err
        ;
    }

    method last-command($proc?) {
        %.last-result = self.result-as-hash($proc) if $proc;
        self;
    }

    method as-string {
        my @lines;
        %.last-result<err> ||= '';
        my Bool $success = %.last-result<err>.chars == 0;
        if $success {
            @lines.push: " {self.after-prefix}" ~ color('green') ~ "{$.projectdir.IO.relative}"; 
        } else {
            @lines.push: " {self.after-prefix}" ~ color('red') ~ "{$.projectdir.IO.relative}"; 
        }
        if %.last-result<err>.chars > 0 {
            my $wrapped-err = App::Platform::Output.text(%.last-result<err>);
            my $sep = ($.help-hint && $.help-hint.chars > 0 
                )
                ?? self.box:<├> 
                !! self.box:<└>;
            @lines.push: "  {$sep}{self.box:<─>} " ~ join("\n  " ~ ($.help-hint ?? self.box:<│> !! '') ~ "  ", $wrapped-err.lines) if %.last-result<err>;
            @lines.push: "  {self.box:<└─>} " ~ color('yellow') ~ "hint: " ~ join("\n     ", App::Platform::Output.text($.help-hint).lines) if $.help-hint;
        }
        @lines[@lines.elems-1] ~= color('reset');
        @lines.join("\n");
    }

}
