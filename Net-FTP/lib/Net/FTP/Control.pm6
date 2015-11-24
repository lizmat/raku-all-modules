
use Net::FTP::Buffer;
use Net::FTP::Config;
use Net::FTP::Conn;

unit class Net::FTP::Control is Net::FTP::Conn;

has $.debug;
has @!lines;
has Buf $!buff;

#   %args
#   host port family encoding debug
method new (*%args is copy) { 
    callsame(|%args);
}

method cmd_conn() {
    note '+connect' if $!debug;
}

method cmd_user(Str $user) {
    self.sendcmd('USER', $user);
}

method cmd_pass(Str $pass) {
    self.sendcmd('PASS', $pass);
}

method cmd_acct(Str $account) {
    self.sendcmd('ACCT', $account);
}

method cmd_cwd(Str $path) {
    self.sendcmd('CWD', $path);
}

method cmd_cdup() {
    self.sendcmd('CDUP');
}

method cmd_smnt(Str $drive) {
    self.sendcmd('SMNT', $drive);
}

method cmd_rein() {
    self.sendcmd('REIN');
}

method cmd_quit() {
    self.sendcmd('QUIT');
}

method cmd_pwd() {
    self.sendcmd('PWD');
}

method cmd_port(Str $info) {
    self.sendcmd('PORT', $info);
}

method cmd_pasv() {
    self.sendcmd('PASV');
}

method cmd_type(Str $type) {
    self.sendcmd('TYPE', $type);
}

multi method cmd_rest(Str $pos) {
    self.sendcmd('REST', $pos);
}

multi method cmd_rest(Int $pos) {
    self.sendcmd('REST', ~$pos);
}

multi method cmd_list(Str $path) {
    self.sendcmd('LIST', $path);
}

multi method cmd_list() {
    self.sendcmd('LIST');
}

multi method cmd_nlist(Str $path) {
    self.sendcmd('NLIST', $path);
}

multi method cmd_nlist() {
    self.sendcmd('NLIST');
}

method cmd_stor(Str $path) {
    self.sendcmd('STOR', $path);
}

multi method cmd_stou(Str $path) {
    self.sendcmd('STOU', $path);
}

multi method cmd_stou() {
    self.sendcmd('STOU');
}

method cmd_appe(Str $path) {
    self.sendcmd('APPE', $path);
}

method cmd_retr(Str $path) {
    self.sendcmd('RETR', $path);
}

method cmd_mkd(Str $path) {
    self.sendcmd('MKD', $path);
}

method cmd_rmd(Str $path) {
    self.sendcmd('RMD', $path);
}

method cmd_rnfr(Str $path) {
    self.sendcmd('RNFR', $path);
}

method cmd_rnto(Str $path) {
    self.sendcmd('RNTO', $path);
}

method cmd_abor() {
    self.sendcmd('ABOR');
}

method cmd_dele(Str $path) {
    self.sendcmd('DELE', $path);
}

method cmd_syst() {
    self.sendcmd('SYST');
}

method cmd_stat() {
    self.sendcmd('STAT');
}

method cmd_help(Str $cmd) {
    self.sendcmd('HELP', $cmd);
}

method cmd_noop() {
    self.sendcmd('NOOP');
}

method cmd_close() {
    self.close();
}

method get() {
    my ($code, $msg, $line);

    loop (;;) {
        if +@!lines {
            $line = @!lines.shift;

            if $line ~~ /^(\d ** 3)\s(.*)/ {
                ($code, $msg) = ($0, $1); last;
            } elsif $line ~~ /^$code\s(.*)/ {
                $msg = $msg ~ $0; last;
            } elsif $line ~~ /^(\d ** 3)\-(.*)/ {
                ($code, $msg) = ($0, $1);
            } elsif $line ~~ /\s+(.*)/ {
                $msg = $msg ~ $0;
            } else {
                ($code, $msg) = (-1, $line);
            }
        } else {
            $!buff = $!buff ??
                    merge($!buff, self.recv(:bin)) !!
                    self.recv(:bin);

            for split($!buff, Buf.new(0x0d, 0x0a)) {
                $line = $_.unpack("A*");
                note '+' ~ $line if $!debug;
                @!lines.push: $line;
            }
        }
    }

    return (~$code, ~$msg);
}

method dispatch($code) {
    unless $code ~~ Int || $code ~~ Str {
        return FTP::FAIL;
    }
    given $code {
        when -1 {
            return FTP::FAIL;
        }
        when 220 |
             230 | 332 | 331 | 202 |
             221 |
             250 | 200 |
             257 |
             227 |
             350 |
             150 | 125 | 226 {
            return FTP::OK;
        }
        # 120 is not a error
        # 421 service closing ftpc
        when 120 | 421 |
             530 | 500 | 501 | 503 | 421 |
             502 | 550 |
             504 |
             425 | 426 | 451 | 450 |
             551 | 552 | 553 | 532 | 452 {
            return FTP::FAIL;
        }
    }
}

# vim: ft=perl6

