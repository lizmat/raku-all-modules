use v6;
use ENIGMA::Machine;

# Build machine from key sheet's daily settings (day 31)
my $machine =  Machine.from-key-sheet(
    :rotors('I II III'),
    :ring-settings('9 5 17'),
    :reflector-setting('B'),
    :plugboard-setting('DC OM GI HB RN KJ LV XS YU WZ'),
);

# Take a look at 'encoded-message.txt' for the initial start 
# position and message indicator

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
    $plaintext.split('X')[2], '.';

