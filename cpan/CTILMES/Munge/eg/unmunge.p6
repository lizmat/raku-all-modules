#!/usr/bin/env perl6

use Munge;

sub MAIN()
{
    my $m = Munge.new;

    my $payload = '';
    my $code = 0;
    my $status = 'Success';

    try $payload = $m.decode($*IN.slurp);

    if $!
    {
        if $!.code ~~ EMUNGE_BAD_CRED
        {
            say "Error: Failed to match armor prefix";
            exit $!.code;
        }

        $code = +$!.code;
        $status = $!.message;
    }

    my $name = $*USER == $m.uid ?? $*USER !! 'unknown';
    my $group = $*GROUP == $m.gid ?? $*GROUP !! 'unknown';

    print qq:to/END/;
STATUS:           $status ($code)
ENCODE_HOST:      ($m.addr4())
ENCODE_TIME:      $m.encode-time() ($m.encode-time.posix())
DECODE_TIME:      $m.decode-time() ($m.decode-time.posix())
TTL:              $m.ttl()
CIPHER:           $m.cipher() ({+$m.cipher()})
MAC:              $m.MAC() ({+$m.MAC()})
ZIP:              $m.zip() ({+$m.zip()})
UID:              $name ($m.uid())
GID:              $group ($m.gid())
LENGTH:           $payload.chars()

$payload.chomp()
END

    exit $code;
}
