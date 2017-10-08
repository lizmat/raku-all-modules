unit module Lingua::EN::Conjugate;

my %irregs = awake => {'sp' => 'awoke','pp' => 'awoken'},bear => {'sp' => 'bore','pp' => 'born'},beat => {'sp' => 'beat','pp' => 'beaten'},become => {'sp' => 'became','pp' => 'become'},begin => {'sp' => 'began','pp' => 'begun'},bend => {'sp' => 'bent','pp' => 'bent'},beset => {'sp' => 'beset','pp' => 'beset'},bet => {'sp' => 'bet','pp' => 'bet'},
      bid => {'sp' => 'bade','pp' => 'bidden'},bind => {'sp' => 'bound','pp' => 'bound'},bite => {'sp' => 'bit','pp' => 'bitten'},bleed => {'sp' => 'bled','pp' => 'bled'},blow => {'sp' => 'blew','pp' => 'blown'},break => {'sp' => 'broke','pp' => 'broken'},breed => {'sp' => 'bred','pp' => 'bred'},bring => {'sp' => 'brought','pp' => 'brought'},
      broadcast => {'sp' => 'broadcast','pp' => 'broadcast'},build => {'sp' => 'built','pp' => 'built'},burn => {'sp' => 'burnt','pp' => 'burnt'},burst => {'sp' => 'burst','pp' => 'burst'},buy => {'sp' => 'bought','pp' => 'bought'},cast => {'sp' => 'cast','pp' => 'cast'},catch => {'sp' => 'caught','pp' => 'caught'},choose => {'sp' => 'chose','pp' => 'chosen'},
      cling => {'sp' => 'clung','pp' => 'clung'},come => {'sp' => 'came','pp' => 'come'},cost => {'sp' => 'cost','pp' => 'cost'},creep => {'sp' => 'crept','pp' => 'crept'},cut => {'sp' => 'cut','pp' => 'cut'},deal => {'sp' => 'dealt','pp' => 'dealt'},dig => {'sp' => 'dug','pp' => 'dug'},dive => {'sp' => 'dove','pp' => 'dived'},
      do => {'sp' => 'did','pp' => 'done'},draw => {'sp' => 'drew','pp' => 'drawn'},dream => {'sp' => 'dreamt','pp' => 'dreamt'},drive => {'sp' => 'drove','pp' => 'driven'},drink => {'sp' => 'drank','pp' => 'drunk'},eat => {'sp' => 'ate','pp' => 'eaten'},fall => {'sp' => 'fell','pp' => 'fallen'},feed => {'sp' => 'fed','pp' => 'fed'},
      feel => {'sp' => 'felt','pp' => 'felt'},fight => {'sp' => 'fought','pp' => 'fought'},find => {'sp' => 'found','pp' => 'found'},fit => {'sp' => 'fit','pp' => 'fit'},flee => {'sp' => 'fled','pp' => 'fled'},fling => {'sp' => 'flung','pp' => 'flung'},fly => {'sp' => 'flew','pp' => 'flown'},forbid => {'sp' => 'forbade','pp' => 'forbidden'},
      forget => {'sp' => 'forgot','pp' => 'forgotten'},forego => {'sp' => 'forewent','pp' => 'foregone'},forgive => {'sp' => 'forgave','pp' => 'forgiven'},forsake => {'sp' => 'forsook','pp' => 'forsaken'},freeze => {'sp' => 'froze','pp' => 'frozen'},get => {'sp' => 'got','pp' => 'gotten'},give => {'sp' => 'gave','pp' => 'given'},go => {'sp' => 'went','pp' => 'gone'},
      grind => {'sp' => 'ground','pp' => 'ground'},grow => {'sp' => 'grew','pp' => 'grown'},hang => {'sp' => 'hung','pp' => 'hung'},hear => {'sp' => 'heard','pp' => 'heard'},hide => {'sp' => 'hid','pp' => 'hidden'},hit => {'sp' => 'hit','pp' => 'hit'},hold => {'sp' => 'held','pp' => 'held'},hurt => {'sp' => 'hurt','pp' => 'hurt'},
      keep => {'sp' => 'kept','pp' => 'kept'},kneel => {'sp' => 'knelt','pp' => 'knelt'},knit => {'sp' => 'knit','pp' => 'knit'},know => {'sp' => 'knew','pp' => 'know'},lay => {'sp' => 'laid','pp' => 'laid'},lead => {'sp' => 'led','pp' => 'led'},leap => {'sp' => 'lept','pp' => 'lept'},learn => {'sp' => 'learnt','pp' => 'learnt'},
      leave => {'sp' => 'left','pp' => 'left'},lend => {'sp' => 'lent','pp' => 'lent'},let => {'sp' => 'let','pp' => 'let'},lie => {'sp' => 'lay','pp' => 'lain'},light => {'sp' => 'lit','pp' => 'lit'},lose => {'sp' => 'lost','pp' => 'lost'},make => {'sp' => 'made','pp' => 'made'},mean => {'sp' => 'meant','pp' => 'meant'},
      meet => {'sp' => 'met','pp' => 'met'},misspell => {'sp' => 'misspelt','pp' => 'misspelt'},mistake => {'sp' => 'mistook','pp' => 'mistaken'},mow => {'sp' => 'mowed','pp' => 'mown'},overcome => {'sp' => 'overcame','pp' => 'overcome'},overdo => {'sp' => 'overdid','pp' => 'overdone'},overtake => {'sp' => 'overtook','pp' => 'overtaken'},overthrow => {'sp' => 'overthrew','pp' => 'overthrown'},
      pay => {'sp' => 'paid','pp' => 'paid'},plead => {'sp' => 'pled','pp' => 'pled'},prove => {'sp' => 'proved','pp' => 'proven'},put => {'sp' => 'put','pp' => 'put'},quit => {'sp' => 'quit','pp' => 'quit'},read => {'sp' => 'read','pp' => 'read'},rid => {'sp' => 'rid','pp' => 'rid'},ride => {'sp' => 'rode','pp' => 'ridden'},
      ring => {'sp' => 'rang','pp' => 'rung'},rise => {'sp' => 'rose','pp' => 'risen'},run => {'sp' => 'ran','pp' => 'run'},saw => {'sp' => 'sawed','pp' => 'sawn'},say => {'sp' => 'said','pp' => 'said'},see => {'sp' => 'saw','pp' => 'seen'},seek => {'sp' => 'sought','pp' => 'sought'},sell => {'sp' => 'sold','pp' => 'sold'},
      send => {'sp' => 'sent','pp' => 'sent'},set => {'sp' => 'set','pp' => 'set'},sew => {'sp' => 'sewed','pp' => 'sewn'},shake => {'sp' => 'shook','pp' => 'shaken'},shave => {'sp' => 'shaved','pp' => 'shaven'},shear => {'sp' => 'shore','pp' => 'shorn'},shed => {'sp' => 'shed','pp' => 'shed'},shine => {'sp' => 'shone','pp' => 'shone'},
      shoe => {'sp' => 'shoed','pp' => 'shod'},shoot => {'sp' => 'shot','pp' => 'shot'},show => {'sp' => 'showed','pp' => 'shown'},shrink => {'sp' => 'shrank','pp' => 'shrunk'},shut => {'sp' => 'shut','pp' => 'shut'},sing => {'sp' => 'sang','pp' => 'sung'},sink => {'sp' => 'sank','pp' => 'sunk'},sit => {'sp' => 'sat','pp' => 'sat'},
      sleep => {'sp' => 'slept','pp' => 'slept'},slay => {'sp' => 'slew','pp' => 'slain'},slide => {'sp' => 'slid','pp' => 'slid'},sling => {'sp' => 'slung','pp' => 'slung'},slit => {'sp' => 'slit','pp' => 'slit'},smite => {'sp' => 'smote','pp' => 'smitten'},sow => {'sp' => 'sowed','pp' => 'sown'},speak => {'sp' => 'spoke','pp' => 'spoken'},
      speed => {'sp' => 'sped','pp' => 'sped'},spend => {'sp' => 'spent','pp' => 'spent'},spill => {'sp' => 'spilt','pp' => 'spilt'},spin => {'sp' => 'spun','pp' => 'spun'},spit => {'sp' => 'spat','pp' => 'spat'},split => {'sp' => 'split','pp' => 'split'},spread => {'sp' => 'spread','pp' => 'spread'},spring => {'sp' => 'sprang','pp' => 'sprung'},
      stand => {'sp' => 'stood','pp' => 'stood'},steal => {'sp' => 'stole','pp' => 'stolen'},stick => {'sp' => 'stuck','pp' => 'stuck'},sting => {'sp' => 'stung','pp' => 'stung'},stink => {'sp' => 'stank','pp' => 'stunk'},stride => {'sp' => 'strod','pp' => 'stridden'},strike => {'sp' => 'struck','pp' => 'struck'},string => {'sp' => 'strung','pp' => 'strung'},
      strive => {'sp' => 'strove','pp' => 'striven'},swear => {'sp' => 'swore','pp' => 'sworn'},sweep => {'sp' => 'swept','pp' => 'swept'},swell => {'sp' => 'swelled','pp' => 'swollen'},swim => {'sp' => 'swam','pp' => 'swum'},swing => {'sp' => 'swung','pp' => 'swung'},take => {'sp' => 'took','pp' => 'taken'},teach => {'sp' => 'taught','pp' => 'taught'},
      tear => {'sp' => 'tore','pp' => 'torn'},tell => {'sp' => 'told','pp' => 'told'},think => {'sp' => 'thought','pp' => 'thought'},thrive => {'sp' => 'throve','pp' => 'thrived'},throw => {'sp' => 'threw','pp' => 'thrown'},thrust => {'sp' => 'thrust','pp' => 'thrust'},tread => {'sp' => 'trod','pp' => 'trodden'},understand => {'sp' => 'understood','pp' => 'understood'},
      uphold => {'sp' => 'upheld','pp' => 'upheld'},upset => {'sp' => 'upset','pp' => 'upset'},wake => {'sp' => 'woke','pp' => 'woken'},wear => {'sp' => 'wore','pp' => 'worn'},weave => {'sp' => 'wove','pp' => 'woven'},wed => {'sp' => 'wed','pp' => 'wed'},weep => {'sp' => 'wept','pp' => 'wept'},wind => {'sp' => 'wound','pp' => 'wound'},
      win => {'sp' => 'won','pp' => 'won'},withhold => {'sp' => 'withheld','pp' => 'withheld'},withstand => {'sp' => 'withstood','pp' => 'withstood'},wring => {'sp' => 'wrung','pp' => 'wrung'},write => {'sp' => 'wrote','pp' => 'written'},
      have => {'sp' => 'had','pp' => 'had'},be => {'sp' => 'was','pp' => 'been'},forget => {'sp' => 'forgot','pp' => 'forgotten'}                    
;
my %mods    = will => { p => "will", sp => "would" } , shall => { p => "shall", sp => "should" } ,may => { p => "may", sp => "might" }, can => { p => "can", sp => "could"  };

my %aux =
      have => { p => { I => 'have',he => 'has',she => 'has',it => 'has',we => 'have',you => 'have',they => 'have'}, sp => { I => 'had',he => 'had',she => 'had',it => 'had',we => 'had',you => 'had',they => 'had'} },
      be   => { p => { I=>'am',he=>'is',she=>'is',it=>'is',we=>'are',you=>'are',they=>'are'}, sp => { I=>'was',he=>'was',she=>'was',it=>'was',we=>'were',you=>'were',they=>'were'} }      
    ;
my %forms  = HaveEn => { v => 'have', t => 'pp' } , BeIng => { v => 'be' , t => 'ing' }, BeEn => { v => 'be' , t => 'pp' }; 

my %shortnegs = "will" => "won't" , "shall" => "shan't" , "can" => "can't" , "may" => "may not", "might" => "might not", "am" => "am not";

#my @tenses    = < bi in ing p sp pp >;
#my @subjects = < I you he she it we they >;



# ---- -----
# ---- ----- Object Oriented Things
# ---- -----

class englishverb is export {
  
  has $.subject       is rw = '';
  has $.alias         is rw = '';  
  has $.bare          is rw is required;
  has $.mod           is rw = '';
  has $.tense         is rw = '';
  has @.forms         is rw = [];
  has $.negation      is rw = False;
  has $.shortneg      is rw = False;
  has $.interrogative is rw = False;
  
  method is-erregular {
    return %irregs{$!bare}.defined;
  }
  
  # --
  # Private verb conjugate method, returns string.
  method !conj ( 
    Str :$subject = $!subject , 
    Str :$verb    = $!bare , 
    Str :$tense   = $!tense ){
      
    my token consonant  { <-[aeiouy]>  } 
    my token vowel      { <+[aeiou]>   } 
    my token stressedw  { <+[aeiouy]>   } 
    my token sibilant   { ss || ox || sh || ch } 
    
    given $tense {
      when 'ing' {
        return $/[0] ~ $/[1] ~ $/[1] ~ 'ing'  if $verb ~~ / (.+ <consonant> <stressedw>) (<consonant>) $$/ ;
        return $/[0] ~ 'ing'                  if $verb ~~ / (.+ <vowel> <consonant>) e $$/ ;
        return $/[0] ~ 'ying'                 if $verb ~~ / (.+) ie  $$/ ;
        return $verb ~ 'ing';
      } 
      when 'i'  {
        return 'to' ~ $verb;
      }
      when 'p'   {
        return %aux{$verb}{$tense}{$subject}    if $verb eq %aux.keys.any;
        if $subject eq < he she it >.any {
          return $/[0] ~ 'ies'                  if $verb ~~ / ( .+ <consonant> ) y $$ /; 
          return $/[0] ~ 'oes'                  if $verb ~~ / ( .+ ) o $$ /; 
          return $/[0] ~ 'es'                   if $verb ~~ / ( .+ <sibilant> ) $$ /;          
          return $verb ~ 's';
        }
        return $verb;
      }
      when 'sp'  {
        return %aux{$verb}{$tense}{$subject} if $verb eq 'be';
        return %irregs{$verb}{$tense}        if $verb eq %irregs.keys.any;
        return $/[0] ~ 'd'                   if $verb ~~ / ( .+ e) $$ /; 
        return $/[0] ~ 'ied'                 if $verb ~~ / ( .+ <consonant> ) y $$ /; 
        return $/[0] ~ $/[1] ~ $/[1] ~ 'ed'  if $verb ~~ / (.+ <consonant> <stressedw>) (<consonant>) $$/ ;
        return $verb ~ 'ed';
      }
      when 'pp'  {
        return %irregs{$verb}{$tense} if $verb eq %irregs.keys.any;
        return $/[0] ~ 'd'            if $verb ~~ / ( .+ e) $$ /; 
        return $verb ~ 'ed';
      }
      default  {
        return $verb;
      }
    }    
  }

  # --
  # Main conjugate method, returns Array.
  method conjugate ( 
    Str   :$subject = $!subject, 
    Str   :$alias = $!alias,
    Bool  :$interrogative is copy = $!interrogative, 
    Bool  :$negation is copy = $!negation, 
    Bool  :$shortneg = $!shortneg, 
    Str   :$tense is copy = $!tense, 
    Str   :$mod = $!mod, 
    
          :@forms =@!forms ){

    # Fast-Return if no subject or tense
    return [$!bare] if $subject ne < I you he she it we they >.any || $tense ne < p sp >.any;
      
    my @returned;
    my $neg_idx     = 0;                             # Trace the real "!"
    my $verbal_idx  = $interrogative ?? 0 !! 1;      # Trace the position of the verbal candidate for "?" and "!" 
        
    # Subject or alias
    @returned.push( $alias eq '' ?? $subject !! $alias ) if ! $interrogative;
    
    # Left To Right allocation of "tense" in compulsory order:  Modal -- Perfect -- Continuious -- Passive
    # "?" and "-" Flaged on/off at first encounter
    if $mod ne '' {
      @returned.push( %mods{$mod}{$tense} );
      $neg_idx  = @returned.push('not').end                 if $negation;
      @returned.push( $alias eq '' ?? $subject !! $alias )  if $interrogative;
      $tense = 'bi';
      $negation = False;
      $interrogative = False;
    }
    if 'HaveEn' eq @forms.any {
      @returned.push( self!conj( subject => $subject, verb => 'have', tense => $tense ) ); 
      @returned.push( $alias eq '' ?? $subject !! $alias )  if $interrogative;
      $neg_idx = @returned.push('not').end                  if $negation;
      $tense = 'pp';
      $negation = False;
      $interrogative = False;
    }
    if 'BeIng' eq @forms.any {
      @returned.push( self!conj( subject => $subject, verb => 'be', tense => $tense ) ); 
      $neg_idx = @returned.push('not').end                  if $negation;      
      @returned.push( $alias eq '' ?? $subject !! $alias ) if $interrogative; 
      $tense = 'ing';
      $negation = False;
      $interrogative = False;
    }
    if 'BeEn' eq @forms.any {
      @returned.push( self!conj( subject => $subject, verb => 'be', tense => $tense ) );
      $neg_idx = @returned.push('not').end                 if $negation;      
      @returned.push( $alias eq '' ?? $subject !! $alias ) if $interrogative;   
      $tense = 'pp';
      $negation = False;
      $interrogative = False;
    }

    # Use of "do" for non-auxiliary verbs in interrogative and/or negative form if no previous "tense" allocation
    if $interrogative || $negation {
      if $!bare eq %aux.keys.any {
        @returned.push( self!conj( subject => $subject, verb => $!bare, tense => $tense ) );
        @returned.push( $alias eq '' ?? $subject !! $alias )  if $interrogative;    
        $neg_idx = @returned.push('not').end                  if $negation;    
      }
      else {
        @returned.push( self!conj( subject => $subject, verb => 'do', tense => $tense ) );
        $neg_idx  = @returned.push('not').end                 if $negation;    
        @returned.push( $alias eq '' ?? $subject !! $alias )  if $interrogative;    
        @returned.push( self!conj( subject => $subject, verb => $!bare, tense => 'bi' ) );
      }
    }
    else {
      @returned.push( self!conj( subject => $subject, verb => $!bare, tense => $tense ) );
    }
    
    # Handle short negation by splicing "not" and short-negating "verbal candidate"
    if $shortneg && $neg_idx > 0 {
      my $sneg = @returned[$verbal_idx] eq %shortnegs.keys.any ?? %shortnegs{ @returned[$verbal_idx] } !! @returned[$verbal_idx] ~ "n't";      
      @returned[$verbal_idx] = $sneg;
      @returned.splice($neg_idx,1,[]);
    }
    
    
    return @returned;
  }  
}


# ---- -----
# ---- ----- Functional Things
# ---- -----

sub conjugate (
  Str   :$bare, 
  Str   :$subject = '', 
  Str   :$alias = '', 
  Bool  :$interrogative = False, 
  Bool  :$negation = False, 
  Bool  :$shortneg = False, 
  Str   :$tense = 'p', 
  Str   :$mod = '', 
        :@forms = [] ) is export {
  
  my $v = englishverb.new( bare => $bare, alias => $alias, subject => $subject, interrogative => $interrogative , negation => $negation, shortneg => $shortneg, tense => $tense, mod => $mod, forms => @forms );
  return $v.conjugate;
  
}

sub is-erregular( Str $bare ){
  return %irregs{$bare}.defined;
}


