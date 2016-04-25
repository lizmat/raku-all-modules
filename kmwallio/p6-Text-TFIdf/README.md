# Text::TFIdf

Given a set of documents, generates [TF-IDF Vectors](https://en.wikipedia.org/wiki/Tf%E2%80%93idf) for them. [![Build Status](https://travis-ci.org/kmwallio/p6-Text-TFIdf.svg?branch=master)](https://travis-ci.org/kmwallio/p6-Text-TFIdf)

## Installation

```
panda install Text::TFIdf
```

## Usage

``` perl6
use Text::TFIdf;

my %stop-words;

my $doc-store = TFIdf.new(:trim(True), :stop-list(%stop-words));

$doc-store.add('perl is cool');
$doc-store.add('i like node');
$doc-store.add('java is okay');
$doc-store.add('perl and node are interesting meh about java');

sub results($id, $score) {
  say $id ~ " got " ~ $score;
}

$doc-store.tfids('node perl java', &results);
```

Output:

```
0 got 0.858454714967854
1 got 0.858454714967854
2 got 0.858454714967854
3 got 2.17296349726238
```

## Acknowledgements

 * [Lingua::EN::Stem::Porter](https://github.com/johnspurr/Lingua-EN-Stem-Porter)
 * [NaturalNode](https://github.com/NaturalNode/natural) for heavy inspiration?
