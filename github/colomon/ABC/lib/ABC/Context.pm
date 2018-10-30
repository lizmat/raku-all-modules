use ABC::KeyInfo;

class ABC::Context {
    has $.key-name;
    has $.key-info;
    has $.meter;
    has $.length;
    has %.accidentals;
    
    multi method new($key-name, $meter, $length, :$current-key-info) {
        self.bless(:$key-name, 
                   :key-info(ABC::KeyInfo.new($key-name, :$current-key-info)), 
                   :$meter, 
                   :$length);
    }
    
    multi method new(ABC::Context $other) {
        self.bless(:key-name($other.key-name),
                   :key-info(ABC::KeyInfo.new($other.key-name)),
                   :meter($other.meter),
                   :length($other.length));
    }
    
    method bar-line () {
        %.accidentals = ();
    }

    method working-accidental($abc-pitch) {
        if $abc-pitch.accidental {
            %.accidentals{$abc-pitch.basenote.uc} = $abc-pitch.accidental;
        }
        
        %.accidentals{$abc-pitch.basenote.uc} || ($.key-info.key{$abc-pitch.basenote.uc} // "");
    }

}

