# RDF::Turtle

[![Build Status](https://travis-ci.org/bduggan/p6-rdf-turtle.svg)](https://travis-ci.org/bduggan/p6-rdf-turtle)

# Description

This is a parser for the Terse RDF Triple Language.

See [https://www.w3.org/TeamSubmission/turtle/](https://www.w3.org/TeamSubmission/turtle/).

Sample usage of RDF::Turtle:

```p6
my $parsed = parse-turtle('file.ttl'.IO.slurp);
my $triples = $parsed.made;
for @$triples -> ($subject, $predicate, $object) {
    say "$subject $predicate $object .";
}
```

Also included is a sample command line parser, [eg/parse.p6](https://github.com/bduggan/p6-rdf-turtle/blob/master/eg/parse.p6).

Sample usage:

Parse a TTL file:

    ./eg/parse.p6 input.ttl

Convert to N-triples format:

    ./eg/parse.p6 input.ttl --triples

The spec tests are included in [t/tests](https://github.com/bduggan/p6-rdf-turtle/tree/master/t/tests).  As of this
writing, all of the good tests are parsed, and some of the correct
outputs are generated.

