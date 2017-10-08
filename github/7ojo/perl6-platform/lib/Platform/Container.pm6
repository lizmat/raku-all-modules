use v6;
use Text::Wrap;
use Platform::Util::OS;

class Platform::Container {

    has Str $.name is rw;
    has Str $.hostname is rw;
    has Str $.network = 'acme';
    has Bool $.network-exists = False;
    has Str $.domain = 'localhost';
    has Str $.dns;
    has Str $.data-path is rw;
    has Str $.projectdir;
    has Hash $.config-data;
    has %.last-result;
    has Str $.help-hint is rw;

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
        my $out = $proc.out.slurp-rest(:close);
        my $err = $proc.err.slurp-rest;
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
        my Str %strings = ( 'OK' => "\c[CHECK MARK]", 'FAIL' => "\c[HEAVY MULTIPLICATION X]" );
        %strings<OK FAIL> Z= <OK FAIL> if Platform::Util::OS.detect() eq 'windows';
        @lines.push: sprintf("+ %-12s     [%s]",
            $.name,
            %.last-result<err>.chars == 0 ?? %strings<OK> !! %strings<FAIL>
            );
        if %.last-result<err>.chars > 0 {
            my $sep = $.help-hint && $.help-hint.chars > 0 ?? '├' !! '└';
            @lines.push: "  $sep─ " ~ join("\n│     ", wrap-text(%.last-result<err>).lines) if %.last-result<err>;
            @lines.push: "  └─ hint: " ~ join("\n     ", wrap-text($.help-hint).lines) if $.help-hint;
        }
        @lines.join("\n");
    }

}
