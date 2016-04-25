use v6;

unit module Text::Caesar;

my @alphabet = 'A' .. 'Z';

multi sub encrypt(Int $key where 1..25, Str $message) is export {
    return ($message).uc.trans(@alphabet Z=> @alphabet.rotate($key));
}

multi sub encrypt-from-file(Int $key where 1..25, Str $orig, Str $dest) is export {
    die "Can't locate $orig" unless $orig.IO ~~ :e;
    if $orig eq $dest {
      warn 'Your origin file will be erased !';
    }
    my Str $message = slurp($orig);
    my Str $encrypted = encrypt($key, $message);

    my $fh = open($dest, :w);
    $fh.say($encrypted);
    $fh.close();
}

multi sub decrypt(Int $key where 1..25, Str $message) is export {
    return $message.trans(@alphabet.rotate($key) Z=> @alphabet);
}

multi sub decrypt-from-file(Int $key where 1..25, Str $orig, Str $dest) is export {
    die "Can't locate $orig !" unless $orig.IO ~~ :e;
    if $orig eq $dest {
      warn 'Your origin file will be erased !';
    }
    my Str $message = slurp($orig);
    my Str $decrypted = decrypt($key, $message);

    my $fh = open($dest, :w);
    $fh.say($decrypted);
    $fh.close();
}
