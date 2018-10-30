use Test;
use Crypt::RC4;
# port of test.pl from the original Crypt-RC4 Perl 5 distribution
my uint8 @passphrase = 0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef;
my uint8 @plaintext  = 0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef;
my uint8 @encrypted = RC4( @passphrase, @plaintext );
my uint8 @decrypted = RC4( @passphrase, @encrypted );
my uint8 @expected-enc = 0x75,0xb7,0x87,0x80,0x99,0xe0,0xc5,0x96;

is-deeply @encrypted, @expected-enc, 'array encryption';
is-deeply @decrypted, @plaintext, 'array decryption';

my Blob $passphrase = Blob.new: @passphrase;
my Blob $plaintext = Blob.new: @plaintext;
my Blob $encrypted = RC4( $passphrase, $plaintext );
my Blob $decrypted = RC4( $passphrase, $encrypted );
my Blob $expected-enc = Blob.new: @expected-enc;

is-deeply $encrypted, $expected-enc, 'blob encryption';
is-deeply $decrypted, $plaintext, 'blob decryption';

$passphrase = Blob.new(0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef);
$plaintext = Blob.new(0x68,0x65,0x20,0x74,0x69,0x6d,0x65,0x20);
$encrypted = RC4( $passphrase, $plaintext );
$decrypted = RC4( $passphrase, $encrypted );

is-deeply $encrypted, Blob.new(0x1c,0xf1,0xe2,0x93,0x79,0x26,0x6d,0x59), 'encryption';
is-deeply $decrypted, $plaintext, 'decryption';

$passphrase = Blob.new(0xef,0x01,0x23,0x45);
$plaintext = Blob.new(0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00);
$encrypted = RC4( $passphrase, $plaintext );
$decrypted = RC4( $passphrase, $encrypted );

is-deeply $encrypted, Blob.new(0xd6,0xa1,0x41,0xa7,0xec,0x3c,0x38,0xdf,0xbd,0x61), 'encryption';
is-deeply $decrypted, $plaintext, 'decryption';

{
    # Test code by Tom Phoenix <rootbeer@redcat.com>
    my Blob $pass1 = "This is my passphrase".encode;
    my Blob $pass2 = "This is not my passphrase".encode;
    my Blob $message = RC4($pass1, "looks good".encode);
    my $one = Crypt::RC4.new( :key($pass1));
    my $two = Crypt::RC4.new( :key($pass2));
    is-deeply $one.RC4("looks good".encode), $message, 'separate states';
}

{
    # Checking that state is properly maintained
    my $one = Crypt::RC4.new(:key("This is my passphrase".encode));
    # These two must be the same number of bytes
    my $message_one = $one.RC4("This is a message of precise length".encode);
    my $message_two = $one.RC4("This is also a known-length message".encode);
    my $two = Crypt::RC4.new(:key("This is my passphrase".encode));
    isnt $message_two, $two.RC4("This is also a known-length message".encode), "non matching message";
    is $message_two, $two.RC4("This is also a known-length message".encode), "matching message";
}

{
    # Ensure that RC4 is not sensitive to chunking.
    my $message = "This is a message which may be encrypted in
    chunks, but which should give the same result nonetheless.";
    my Blob $key = "It's just a passphrase".encode;
    my Str $encrypted = do {
        my $k = Crypt::RC4.new(:$key);
        my @pieces = split /<!ww>/, $message; 
        join "", map { $k.RC4(.encode("latin-1")).decode("latin-1") }, @pieces;
    };
    my $failed;
    # Merely some various chunking sizes.
    for (1, 4, 5, 10, 30, 9999) -> $split_size {
        my $k = Crypt::RC4.new(:$key);
       	$message ~~ /(.**{1..$split_size})*/;
	my @pieces = @0.map( *.Str );
        my $trial = join "", map { $k.RC4(.encode("latin-1")).decode("latin-1") }, @pieces;
        if ($trial ne $encrypted) {
	    diag { :$trial, :$encrypted }.perl;
            $failed = $split_size;
            last;
        }
    }

    my $this-test = 'chunking';

    if $failed {
      flunk($this-test);
      diag "Failed at split=$failed";
    }
    else {
        pass($this-test);
    }
}

done-testing;
