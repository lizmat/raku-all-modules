use v6;

unit module Text::Caesar;

my @alphabet = 'A' .. 'Z';
# [A B C D E F G H I J K L M N O P Q R S T U V W X Y Z]

class Caesar {
    has Int $.key;
    submethod BUILD(:$!key) {
        die 'The key must be between 1 and 25.' unless 1 <= $!key <= 25;
    }
}

class Message is Caesar is export {
    has Str $.text;
    method encrypt() {
        return ($.text).uc.trans(@alphabet Z=> @alphabet.rotate($.key));
    }
}

class Secret is Caesar is export {
    has Str $.text;
    method decrypt() {
        return $.text.trans(@alphabet.rotate($.key) Z=> @alphabet);
    }
}

multi sub encrypt(Int $key, Str $text) is export  {
    my $message = Message.new(
        key => $key,
        text => $text
    );
    return $message.encrypt();
}

multi sub encrypt-from-file(Int $key, Str $orig, Str $dest) is export {
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

multi sub decrypt(Int $key, Str $text) is export {
    my $secret = Secret.new(
        key => $key,
        text => $text
    );
    return $secret.decrypt();
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
