use v6;
use Text::Wrap;

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

    submethod TWEAK {
        $!data-path .= subst(/\~/, $*HOME);
        my $resolv-conf = $!data-path ~ '/resolv.conf';
        if $resolv-conf.IO.e {
            my $found = $resolv-conf.IO.slurp ~~ / nameserver \s+ $<ip-address> = [ \d+\.\d+\.\d+\.\d+ ] /;
            $!dns = $found ?? $/.hash<ip-address>.Str !! '';
        }
        my $proc = run <docker network inspect>, $!network, :out, :err;
        my $out = $proc.out.slurp-rest;
        $!network-exists = $out.Str.trim ne '[]';
    }

    method result-as-hash($proc) {
        my $out = $proc.out.slurp-rest;
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
        @lines.push: sprintf("+ %-12s     [%s]",
            $.name,
            %.last-result<err>.chars == 0 ?? "\c[CHECK MARK]" !! "\c[HEAVY MULTIPLICATION X]"
            );
        @lines.push: "  └─ " ~ join("\n│     ", wrap-text(%.last-result<err>).lines) if %.last-result<err>.chars > 0;
        @lines.join("\n");
    }

}
