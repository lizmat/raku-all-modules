use v6;
use ENIGMA::Machine;


sub create-from-args( $rotors, $ring-settings, $reflector, $plugboard ) {
    unless $rotors {
        die "Please specify 3 or 4 rotors, e.g. II IV V";
    }

    unless $rotors.split(/\s+/) == $ring-settings.split(/\s+/) {
        die "# of rotors must be equal to # of ring settings";
    }

    return Machine.from-key-sheet(
        :rotors($rotors),
        :ring-settings($ring-settings),
        :reflector-setting($reflector),
        :plugboard-setting($plugboard),
    );
}

# get text with or without replaced character.
sub get-text( $machine, $input, $dchar, $rchar ) {
    return $machine.process-text($input) if $dchar; # character deleted
    return $machine.process-text($input, $rchar);   # character replaced
}

# set up machine for encryption or decryption. It mutates
# the machine's state.
sub enc-or-dec( $machine, $message-key, $decryption ) {
    my ($enc-key, $dec-key);

    if $decryption {
        print Q:to/END/;
        Decryption Mode
        ---------------
        END

        $dec-key = $machine.process-text($message-key);
        $machine.set-display($dec-key);
    }
    else {
        print Q:to/END/;
        Encryption Mode
        ---------------
        END

        $enc-key = $machine.process-text($message-key);        
        $machine.set-display($message-key);
    }

    return $enc-key;
}

# get input depending on the source. If file, read it and return its content
# If text, return it. Else, read from standard input.
sub get-input( $source ) {
    if $source and $source.IO.e {
        my $text = $source.IO.slurp();
        return $text.subst(/\n+/, '');
    }
    elsif $source {
        return $source;
    }

    return prompt('--> ');
}

multi MAIN( 
    Str :r(:$rotors),
    Str :i(:$ring-settings) = 'A A A',
    Str :p(:$plugboard) = '',
    Str :e(:$reflector),
    Str :s(:$start),
    Str :m(:$message-key),
    Str :t(:$text) = '',
    Str :f(:$file) = '',
    Str :x(:$replace-char) = 'X',
    Bool :z(:$delete-char),
    Bool :y(:$decryption),
    Bool :v(:$verbose),
) { 
    
    if $text and $file {
        die "Please specify --text or --file, but not both.";
    }

    my $machine = create-from-args(
        $rotors, $ring-settings, $reflector, $plugboard
    );

    unless $start and $message-key {
        die "Please specify a start position and message key";
    }

    $machine.set-display($start);

    my $enc-key = enc-or-dec($machine, $message-key, $decryption);
 
    my $source = $text || $file;

    my $input = get-input($source);
    my $t = get-text($machine, $input, $delete-char, $replace-char);

    if not $decryption {
        print Q:s:to/END/;
        Start position: $start
        Encoded key: $enc-key
        Output: $t
        END
    }
    else {
        print Q:s:to/END/;
        Output: $t
        END
    }

    if $verbose {
        my %h = $machine.get-rotor-counts();
        print Q:s:h:to/END/;
        Final rotor positions: $machine.get-display()
        Rotor rotation counts: %h.values()
        END
    }
     
    exit 1;
}


multi MAIN(
   Str :k(:$key-file),
   Int :d(:$day),
   Str :s(:$start),
   Str :m(:$message-key),
   Str :t(:$text) = '',
   Str :f(:$file) = '',
   Str :x(:$replace-char) = 'X',
   Bool :z(:$delete-char),
   Bool :y(:$decryption),
   Bool :v(:$verbose),
) {

    my $k = $key-file.IO.slurp;
    my $machine = Machine.from-key-file($k, $day);
   
    $machine.set-display($start);

    my $enc-key = enc-or-dec($machine, $message-key, $decryption);
   
    my $source = $text || $file;

    my $input = get-input($source);
    my $t = get-text($machine, $input, $delete-char, $replace-char);

    if not $decryption {
        print Q:s:to/END/;
        Start position: $start
        Encoded key: $enc-key
        Output: $t
        END
    }
    else {
        say "Output: $t";
    }

    if $verbose {
        my %h = $machine.get-rotor-counts();
        print Q:s:h:to/END/;
        Final rotor positions: $machine.get-display()
        Rotor rotation counts: %h.values()
        END
    }
    
    exit 1;
}



sub USAGE() {
print Q:c:to/END/;
SYNOPSIS:
ENIGMA::Machine - Encrypt/decrypt text according to Enigma machine key settings.

USAGE:
  {$*PROGRAM} [-r|--rotors=<Str>] [-i|--ring-settings=<Str>] [-p|--plugboard=<Str>]
              [-e|--reflector=<Str>] [-s|--start=<Str>] [-m|--message-key=<Str>]
              [-t|--text=<Str>] [-f|--file=<Str>] [-x|--replace-char=<Str>]
              [-z|--delete-char] [-y|--decryption] [-v|--verbose] 

  {$*PROGRAM} [-k|--key-file=<Str>] [-d|--day=<Int>] [-s|--start=<Str>]
              [-y|--key=<Str>] [-t|--text=<Str>] [-f|--file=<Str>]
              [-x|--replace-char=<Str>] [-z|--delete-char] [-y|--decryption]
              [-v|--verbose] 

DESCRIPTION:
  -h, --help            show this help message and exit
  -k KEY_FILE, --key-file KEY_FILE
                        path to key file for daily settings
  -d DAY, --day DAY     use the settings for day DAY when reading key file
  -r ROTOR, --rotors ROTOR
                        rotor string ordered from left to right,
                        e.g 'III IV I'
  -i RING_SETTING, --ring-settings RING_SETTING
                        ring setting string from left to right, 
                        e.g. 'A B C'/'1 2 3'
  -p PLUGBOARD, --plugboard PLUGBOARD
                        plugboard settings string, e.g. 'EX MA CH IN AS'
  -e REFLECTOR, --reflector REFLECTOR
                        reflector name string, e.g. 'C'
  -s START_KEY, --start START_KEY
                        starting position for rotors
  -m MESSAGE_KEY, --message-key MESSAGE_KEY
                        this is the random message key chosen by the operator
                        when encrypting a message after choosing the random
                        start position.

                        if encrypting, message key is used for encryption. A 
                        new encoded key will print out which will be needed
                        for decryption.
                        if decrypting, message key is used to generate the 
                        original message key to decrypt the message.

                        this message key and the start key can be 
                        the same. They both can also be used to encriypt and 
                        decrypt a message in which decryption doesn't have 
                        to be specified.

  -t TEXT, --text TEXT  text to process
  -f FILE, --file FILE  input file to process
  -x REPLACE_CHAR, --replace-char REPLACE_CHAR
                        if the input text contains chars not found on the
                        enigma keyboard, replace with this char [default: X]
FLAGS:

  -z, --delete-char     if the input text contains chars not found on the
                        enigma keyboard, delete them from the input
  -y, --decryption      if the encoded key (instead of the original message key)
                        is used, then this flag must be used.
  -v, --verbose         provide verbose output; include final rotor positions

Examples:
    $ perl6 {$*PROGRAM-NAME} -r='I II III' -e='B' -p='1/5 6/8' -s='GHA' -m='SUN' -t='HELLO'
    $ perl6 {$*PROGRAM-NAME} -r='I II III' -e='B' -p='1/5 6/8' -s='GHA' -m='SUN' -t='AKURB'
    $ perl6 {$*PROGRAM-NAME} -r='I II III' -e='B' -p='A/E F/H' -s='GHA' -m='TMG' -t='AKURB' -y
    $ perl6 {$*PROGRAM-NAME} -k='keysheet-text.txt' -s='ABC' -m='XYZ' -t='ENJUNBKSHZBE'
END
}
