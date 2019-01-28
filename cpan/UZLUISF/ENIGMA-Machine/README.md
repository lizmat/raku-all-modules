
## ENIGMA::Machine

`ENIGMA::Machine` is a (simple) Perl 6 module to implement an Enigma machine.


## Quick example

**Daily key sheet sample:**

```
#----------------------------------------------------------------------------------------
#Tag |   Walzenlage    |  Ringstellung  |     Steckerverbindungen      |   Umkehrwalze   |
#----------------------------------------------------------------------------------------
31    I      II     III     09 05 17      DC OM GI HB RN KJ LV XS YU WZ      B
30    Gamma  III    VI      U  L  O       AE CM DX GV HO IP KQ LW NY RT      B-Thin
...
```

[Entire key sheet](/examples/keysheet-text.txt)

**Received (fictitious) message:**
```
NYZ DE WAS 2300 = 16 = WMD BDH =

FRUTA EBBVD RWEZR 
VHAFJ L=
```
This message was encrypted on day 31. In the original messages, `FRUTA` would
be the block that contained the message indicator which was used to verify the
settings for the day and ignored during the decryption. Our key sheet doesn't
have it so we cannot verify anything. Furthermore, it's not really needed to decode
the actual message (which is anything that follows it).


**Information gathered from the key sheet and the received message:**
```
Enigma: I
Umkehrwalze (reflector): B
Walzenlage (wheel order): I II III
Ringstellung (ring setting): 9 5 17
Steckern (plugs): DC OM GI HB RN KJ LV XS YU WZ
Grundstellung (start position): WMD
Message key: BDH
Encoded message: EBBVDRWEZRVHAFJL
```

**Using the module to decrypt the encrypted message:**
```perl
use ENIGMA::Machine;

# set up machine according to the daily key sheet:
my $machine =  Machine.from-key-sheet(
    rotors => 'I II III',
    ring-settings => '9 5 17',
    reflector-setting => 'B',
    plugboard-setting => 'DC OM GI HB RN KJ LV XS YU WZ',
);

# set machine initial star position
$machine.set-display('WMD');

# decrypt the message key
my $msg-key = $machine.process-text('BDH');

# set machine to decoded message key
$machine.set-display($msg-key);

# decrypt the ciphertext
my $plaintext = $machine.process-text('EBBVDRWEZRVHAFJL');

say $plaintext;
```

## Installation and Info

To install:
* By cloning (or downloading) this repo:
    1. `$ git clone git@gitlab.com:uzluisf/enigma.git`
    2. `$ zef install ./enigma`

* From [Perl 6 Modules Directory](https://modules.perl6.org/):
    * `$ zef install ENIGMA::Machine`

To uninstall:

```
$ zef uninstall ENIGMA::Machine
```

To get information (after installation) about the module's components:

```
$ p6doc ENIGMA::Machine
$ p6doc ENIGMA::Machine::Rotor
...
$ p6doc ENIGMA::Machine::Factory
```

## Documentation

For more information about the module, head over to
[ENIGMA::Machine's wiki](https://gitlab.com/uzluisf/enigma/wikis/home).

## Credits

The source code is available under the **MIT License**.

See [LICENSE](https://gitlab.com/uzluisf/enigma/raw/master/LICENSE) for further details.
