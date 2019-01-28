use v6;
use ENIGMA::Machine;
use ENIGMA::Machine::Rotor;
use ENIGMA::Machine::Plugboard;

########################
# Assembling the machine
########################

my $r1 = Rotor.new(
    :wiring('EKMFLGDQVZNTOWYHXUSPAIBRCJ'),
    :ring-setting(8),
    :turnover('Q'),
    :model('I'),
);

my $r2 = Rotor.new(
    :wiring('AJDKSIRUXBLHWTMCQGZNPYFVOE'),
    :ring-setting(4),
    :turnover('E'),
    :model('II'),
);

my $r3 = Rotor.new(
    :wiring('BDFHJLCPRTXVZNYEIWGAKMUSQO'),
    :ring-setting(16),
    :turnover('V'),
    :model('III'),
);


my $reflector = Rotor.new(
    :wiring('YRUHQSLDPXNGOKMIEBFZCWVJAT'),
    :model('B'),
);

my $plugboard = Plugboard.from-key-sheet('DC OM GI HB RN KJ LV XS YU WZ');

my $machine = Machine.new(
    :rotors([$r1, $r2, $r3]),
    :reflector($reflector),
    :plugboard($plugboard),
);

#######################
# Decoding the message
#######################

# set machine initial star position
$machine.set-display('WMD');

# decrypt the message key
my $msg-key = $machine.process-text('BDH');

# set machine to decoded message key
$machine.set-display($msg-key);

# decode sent message
my $plaintext = $machine.process-text('EBBVDRWEZRVHAFJL', 'X');

say "And the message was: $plaintext\n";

say "By the way, ",
    $plaintext.split('X')[0].lc.tc,
    " is a great song by ",
    $plaintext.split('X').[2], ".";



