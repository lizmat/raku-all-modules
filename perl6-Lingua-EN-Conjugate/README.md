# perl6-Lingua-EN-Conjugate

##### A Perl6 module that conjugates English verbs

### Usage

     use Lingua::EN::Conjugate;

     my $verb = englishverb.new(bare => 'code', forms => <BeIng HaveEn>);
     for < I you he she it we you they > -> $s {
       for < p sp > -> $t {
         $verb.tense = $t;
         say $verb.conjugate( subject => $s );
       }
     }
     
     my @sentence = conjugate( bare => 'be', subject => 'it', interrogative => True );
     say @sentence ~ ' a function ?';
     
### Object, Methods and details

Object **englishverb** must be created first with one only conmpulsory parameter 
- **bare**          : String required, Bare form of the verb without the "to"
  
The object also accepts named parameters for method "conjugate at creation.

Method **conjugate** returns Array: accepts named parameters :
- **subject**       : String any of *I , he , she , it , we , you , they* , default self init
- **alias**         : Replace the subject in the ouput array , default self init
- **mod**           : String, any of *will , shall , may , can* , default self init
- **tense**         : String, any of *p,sp* ; *"p" = Present, "sp" = Past* , default self init
- **forms**         : Array of String, many of = *BeIng BeEn HaveEn*;   *BeIng=continuous,  BeEn=Passive, HaveEn=Perfect* , default self init
- **negation**      : Bool default False;
- **shortneg**      : Bool default False, use the short negation ( ex: [will not] => [won't] );
- **interrogative** : Bool default False, Use interrogative form


Method **is-irreg** returns Bool, accepts string default self bare
- Tells if passed verb is irregular


### Function usage
- **Subroutine "conjugate"** accepts named parameter "bare" and all named parameters of the object method
- **Subroutine "is-irreg"** behaves the as object method


### Purpose And Notes

 **Warning, this is not a direct port of the Perl5 "Lingua-EN-Conjugate" module !**

 Instead of using fixed tense blocks to conjugate an English verb, this module uses notions of "forms" which can be combined.
 IE: The "Past Perfect Continuous/Progressive" of a verb is in this case, The "Perfect" and "Continuous" forms conbined and evaluated with the "Past Tense"

#### The notions used by the module:
 
 **SUBJECT:**
 
 The sentence's actor, any of *I he she it we you they*
 
 
 
 **TENSE:**
 
 The grammatical time of the action. "Time" is a physical notion, "Tense" a grammatical one. English has only 2 "Tense": Past and Present; The "Future" tense is a modality.
 Two Tenses are aviable: p = Present, sp = Past
 
 
 
 **MODALITY:**
 
 Allows speakers to evaluate a proposition relative to a set of other propositions (Necessity or Possibility). The "future" (will) stands for a Possibility.
 Modality is any of *will shall may can*.
 
 
 
 **VERB:**
 
 Conveys an action (bring, read, walk, run, learn), or a state of being (be, exist, stand).
 
 
 
 **VERBAL FORM:**
 
 Way in which a verb is structured in relation to time, BE+ING = Continuity, non-finite. HAVE+EN: Past event linked to the present, BE+EN: Passive verbal form
 Modality can be many of *HaveEn BeIng BeEn*



#### Speculative Todo List

- Short forms for: "I am" "will" "would" etc ...
- "be able to"
- "used to"
- "ought to"
- "Explain" method for educational purpose
- Multi method with pure grammatical arguments ex: conjugate( tense => "Past Perfect Continuous" )

#### Copyright

Copyright © 2015 Nuguet Romuald under the Artistic License 2.0.

