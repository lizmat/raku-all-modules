use v6;
use ABC::Header;
use ABC::Pitched;

class ABC::Tune {
    has $.header;
    has @.music;
    
    multi method new(ABC::Header $header, @music) {
        self.bless(:$header, :@music);
    }
    
    method transpose(Int $steps-up) {
        sub transpose-element($element) {
            $element.key => ($element.value ~~ ABC::Pitched) ?? $element.transpose($steps-up) 
                                                             !! $element.value;
        }
        
        ABC::Tune.new($.header, @.music.map({ transpose-element($_); }));
    }
}