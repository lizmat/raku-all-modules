unit module ENIGMA::Machine::Data;

# Wiring for rotors and reflectors used in Enigma I, M3 and M4.

# For more details and wiring for the different
# enigma machines, see: http://www.cryptomuseum.com/crypto/enigma/wiring.htm

our @ENTRY_WHEEL is export = 'A'..'Z';

constant %ROTORS is export = %(
    'I' =>  %(
        wiring   =>  'EKMFLGDQVZNTOWYHXUSPAIBRCJ',
        turnover =>  'Q',
    ),
    'II' =>  %(
         wiring   =>  'AJDKSIRUXBLHWTMCQGZNPYFVOE',
         turnover =>  'E',
    ),
    'III' =>  %(
         wiring    =>  'BDFHJLCPRTXVZNYEIWGAKMUSQO',
         turnover  =>  'V',
    ),
    'IV' =>  %(
        wiring =>  'ESOVPZJAYQUIRHXLNFTGKDCMWB',
        turnover =>  'J',
    ),
    'V' =>  %(
        wiring =>  'VZBRGITYUPSDNHLXAWMJQOFECK',
        turnover =>  'Z',
    ),
    'VI' =>  %(
        wiring =>  'JPGVOUMFYQBENHZRDKASXLICTW',
        turnover =>  'ZM',
    ),
    'VII' =>  %(
        wiring =>  'NZJHGRCXMYSWBOUFAIVLPEKQDT',
        turnover =>  'ZM',
    ),
    'VIII' =>  %(
        wiring =>  'FKQHTLXOCBJSPDZRAMEWNIUYGV',
        turnover =>  'ZM',
    ),
    'Beta' =>  %(
        wiring =>  'LEYJVCNIXWPBQMDRTAKZGFUHOS',
        turnover =>  Nil,
    ),
    'Gamma' =>  %(
        wiring =>  'FSOKANUERHMBTIYCWLQPZXVGJD',
        turnover =>  Nil,
    ),
);

constant %REFLECTORS is export = %(
    B =>  'YRUHQSLDPXNGOKMIEBFZCWVJAT',
    C =>  'FVPJIAOYEDRZXWGCTKUQSBNMHL',
    'B-Thin' =>  'ENKQAUYWJICOPBLMDXZVFTHRGS',
    'C-Thin' =>  'RDOBJNTKVEHMLFCWZAXGYIPSUQ',
);

