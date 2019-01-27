unit    class KHPH:ver<0.0.4>:auth<Mark Devine (mark@markdevine.com)>;

use     Base64::Native;
use     Compress::Bzip2;
use     NativeCall;
use     Terminal::Readsecret;

constant HOST_NAME_MAX = 64;
sub gethostname(utf8, size_t) returns int32 is native { * };

my utf8 $hostnameB .= allocate(HOST_NAME_MAX);
gethostname($hostnameB, HOST_NAME_MAX);
my Str $hn-nulls = $hostnameB.decode('utf-8');
my Str $hostname = substr($hn-nulls, 0, index($hn-nulls, "\0"));

constant LOGIN_NAME_MAX = 256;
sub getlogin_r(utf8, size_t) returns int32 is native is export { * };

my utf8 $loginB .= allocate(LOGIN_NAME_MAX);
getlogin_r($loginB, LOGIN_NAME_MAX);
my Str $login-nulls = $loginB.decode('utf-8');
my Str $login = substr($login-nulls, 0, index($login-nulls, "\0"));

has buf8 $.encoded-secret;
has Str  $.stash-path is required;
has Str  $.herald;
has Str  $.secret;

submethod TWEAK {
    my $directory-name = "$!stash-path".IO.dirname;
    mkdir $directory-name unless "$directory-name".IO.e;
    $directory-name.IO.chmod(0o700);
    if "$!stash-path".IO.e {
        $!encoded-secret = slurp $!stash-path, :bin;
    }
    else {
        unless $!secret {
            die "Run interactively to stash the password for the first time." unless $*IN.t && $*OUT.t;
            say $!herald if self.herald;
            my $secret1 = -1;
            my $secret2 = -2;
            while $secret1 ne $secret2 {
                $secret1 = $secret2 = '';
                while not $secret1 { $secret1 = getsecret('Input secret> '); }
                while not $secret2 { $secret2 = getsecret('Repeat secret> '); }
            }
            $!secret = $secret2;
        }
        my @s = base64-encode($hostname ~ $!secret ~ $login ~ ~(+$*USER)).decode.comb;
        my @o = @s.keys.map({ @s[$_] if $_ % 2 }).reverse;
        my @e = @s.keys.map: { @s[$_] if $_ %% 2 };
        my $s = flat(@o Z @e).join;
        my buf8 $b64 = base64-encode($s);
        $!encoded-secret = compressToBlob($b64);
        spurt $!stash-path, $!encoded-secret;
        $!stash-path.IO.chmod(0o600);
        $!secret = 'vanished';
    }
}

method expose {
    my buf8 $b64 = decompressToBlob(self.encoded-secret);
    my @s        = base64-decode($b64).decode.comb;
    my @o        = @s.keys.map: { @s[$_] if $_ % 2 };
    my @e        = @s.keys.map({ @s[$_] if $_ %% 2 }).reverse;
    my $s        = flat(@o Z @e).join;
    $s           = base64-decode($s).decode;
    my $uid      = +$*USER;
    return ~$/[0] if $s ~~ /^ "$hostname" (.*?) "$login" "$uid" $/;
}

=finish
