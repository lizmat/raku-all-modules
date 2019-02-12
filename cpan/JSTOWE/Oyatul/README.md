# Oyatul

Abstract representation of a filesystem layout

[![Build Status](https://travis-ci.org/jonathanstowe/Oyatul.svg?branch=master)](https://travis-ci.org/jonathanstowe/Oyatul)

## Synopsis

This runs the tests identified by 'purpose' test which can be in any
location in the layout with the library directory identified by the
purpose 'lib' :

```perl6
use Oyatul;

my $description = q:to/LAY/;
{
   "type" : "layout",
   "children" : [
      {
         "name" : "t",
         "purpose" : "tests",
         "type" : "directory",
         "children" : [
            {
               "type" : "file",
               "purpose" : "test",
               "template" : true
            }
         ]
      },
      {
         "type" : "directory",
         "purpose" : "lib",
         "name" : "lib",
         "children" : []
      }
   ]
}
LAY

# the :real adverb causes instance nodes to be inserted
# for any templates if they exist.
my $layout = Oyatul::Layout.from-json($description, root => $*CWD.Str, :real);

# get the directory that stands in for 'lib'
my $lib = $layout.nodes-for-purpose('lib').first.path;

# get all the instances for 'test' excluding the template
for $layout.nodes-for-purpose('test', :real) -> $test {
	run($*EXECUTABLE, '-I', $lib, $test.path);
}

```

## Description

This provides a method of describing a filesystem layout in an abstract
manner.

It can be used in the deployment of applications which might need
the creation of a directory tree for data or configuration, or for
applications which may need to locate files and directory that it needs
but can allow the user to define their own .

The file layout descriptions can be stored as JSON or they can be built
programmatically (thus allowing other forms of storage.)

The description can define directories and files in an aribitrary tree
structure, each can optionally define a 'purpose' which can be used to
locate a node irrespective of its location in the tree and name, a node
object can also be given a role with the 'does' key which can give the
node additional behaviours (e.g. create a file of a specific format,
create an object based on a file or directory etc.) Template nodes can
be defined which can stand in for real files or directories which can
be discovered at run-time.

This is based on a design that I used in a large application that relied
heavily on file storage for its data, but is somewhat more simplified
and abstracted as well as preferring JSON over the original XML for the
storage of the layout description. The features are designed to allow
[Sofa](https://github.com/jonathanstowe/Sofa) to load a CouchDB design
document from an arbitrary (possibly user defined) file hierarchy unlike
```couchapp``` which requires a fixed directory structure. However
hopefully it will be useful in other applications.

## Installation

Assuming you have a working Rakudo Perl 6 installation you should be able to
install this with *zef* :

    # From the source directory
   
    zef install .

    # Remote installation

    zef install Oyatul

## Support

Suggestions and patches that may make it more useful in your software
are welcomed via github at:

https://github.com/jonathanstowe/Oyatul/issues

## Licence

This is free software.

Please see the [LICENCE](LICENCE) file in the distribution

© Jonathan Stowe 2016 - 2019
