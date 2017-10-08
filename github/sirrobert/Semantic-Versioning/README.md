Semantic Versioning
===================

Overview
--------

Allows an object to take on versioning attributes in accordance with [the
Semantic Versioning specification (2.0.0)](http://semver.org/).  The module
provides a class and a role.

Role:  does Semantic::Versioning
-------------------------
The `Semantic::Versioning` role enables any object to be versioned.  Four
properties are added: `.version`, `.major-version`, `.minor-version`, and
`.patch-version`.  

### Example use
```perl6

class Document does Semantic::Versioning { }

my $doc = Document.new;
$doc.version = '1.6.23';
say $doc.major-version; #  1
say $doc.minor-version; #  6
say $doc.patch-version; # 23

$doc.minor-version = 7;
say $doc.version; # '1.7.23';
```

Class:  has Semantic::Version
---------------------
The class version allows for multiple versioning attributes in an object.

### Example use

```perl6
class Document {
  has Semantic::Version $.described-in;
  has Semantic::Version $.planned-for;
  has Semantic::Version $.implemented-in;
}

my $doc = Document.new;
$doc.described-in.version = '1.6.23';
say $doc.described-in.major-version; #  1
say $doc.described-in.minor-version; #  6
say $doc.described-in.patch-version; # 23

$doc.planned-for.version = '2.0.0';
$doc.implemented-in.version = '2.0.0';

# Woops, made a mistake-- got implemented in the next minor version;
$doc.implemented-in.minor-version++;
say $doc.implemented-in; # '2.1.0';
```


