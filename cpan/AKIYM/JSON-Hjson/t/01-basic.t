use v6;
use Test;
use JSON::Hjson;

my $text = q:to'...';
// for your config
// use #, // or /**/ comments,
// omit quotes for keys
key: 1
// omit quotes for strings
string: contains everything until LF
// omit commas at the end of a line
cool: {
  foo: 1
  bar: 2
}
// allow trailing commas
list: [
  1,
  2,
]
// and use multiline strings
realist:
  '''
  My half empty glass,
  I will fill your empty half.
  Now you are half full.
  '''
...

is-deeply from-hjson($text), {
    key => 1,
    string => 'contains everything until LF',
    cool => {
        foo => 1,
        bar => 2,
    },
    list => [1, 2],
    realist => q:to'...'.trim-trailing,
My half empty glass,
I will fill your empty half.
Now you are half full.
...
};

done-testing;
