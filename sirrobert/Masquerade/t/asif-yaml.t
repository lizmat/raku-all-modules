use v6;
use Test;
plan 5;

# Load the module
use Masquerade;

class TestClass {
  has $.animal = "monkey";
  has $.money  = "dollar";
  has @.veggies;
  has %.cities;
};

my %test-data = {
  'simple hash' => {
    perl => {a => 1, b => 2, c => 3},
    yaml => "a: 1\nb: 2\nc: 3\n",
  },

  'simple array' => {
    perl => [1, 2, 3],
    yaml => "- 1\n- 2\n- 3\n",
  },

  'array of pairs' => {
    perl => [a=>1, b=>2, c=>3],
    yaml => "- a: 1\n- b: 2\n- c: 3\n",
  },
  

  'complex nested: hash array string int float' => {
    perl => {
      size        => "medium",
      damage      => "high",
      affects     => [<Houses Barns Cars Chickens Cows>],
      attributes  => {
        twistiness  => 100,
        color       => 'brown/grey',
        scariness   => 6.234,
        speed       => {
          velocity  => '92mph',
          direction => 'at YOU!',
        }
      },
    }, 

    yaml => 'size:       medium
damage:     high
affects:    
  - Houses
  - Barns
  - Cars
  - Chickens
  - Cows
attributes: 
  twistiness: 100
  color:      brown/grey
  scariness:  6.234
  speed:      
    velocity:  92mph
    direction: at YOU!
'
  },

  'custom Class-based object' => {
    perl => TestClass.new(
      veggies => <zucchini squash broccoli>,
      cities  => {
        London => 'England',
        Durham => 'The United States of America',
      }
    ),

    yaml => 'animal:  monkey
money:   dollar
veggies: 
  - zucchini
  - squash
  - broccoli
cities:  
  London: England
  Durham: The United States of America
'
  },

}

# Just run the above tests.
for %test-data.kv -> $k, $v {
  my $perl = $v<perl>;
  my $yaml = $v<yaml>;

  ok ($perl but AsIf::YAML eq $yaml), $k;
}
