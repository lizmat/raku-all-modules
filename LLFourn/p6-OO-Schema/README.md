# OO::Schema [![Build Status](https://travis-ci.org/LLFourn/p6-OO-Schema.svg)](https://travis-ci.org/LLFourn/p6-OO-Schema)

Declare your class relationships separate from their implementation so
you can talk about them without loading them.

## Synopsis

```perl6
## example: declaring the relationships between different OS userlands
# lib/Userland.pm6
use OO::Schema;

schema Userland {

    node Windows {
       node XP { }
    }

    node POSIX {
        node BSD {
            node FreeBSD { }
            node OpenBSD { }
            node OSX is alias(<Darwin xnu>) { }
        }
        node GNU {
            node Debian {
                node Ubuntu { }
            }
            node RHEL  is load-from("Userland::RedHat") {
                node Fedora { }
                node CentOS { }
            }
        }
    }
}
```

```perl6
# lib/Userland/Ubuntu.pm6
use Userland :node;

unit class Userland::Ubuntu is schema-node;

```
and finally in
```perl6
# main.p6

use Userland;
# Don't have to load Userland::RHEL or Userland::Debian

proto install-package(Userland:D,Str:D $pkg) {*};

# 'Debian' and 'RHEL' are schema nodes -- not full classes
multi install-package(Debian $userland,$pkg) {
    run 'apt-get', 'install', $pkg;
}

multi install-package(RHEL $userland,$pkg) {
    run 'yum', 'install', $pkg;
}

# Now at runtime you load particular real class from a node ( or via require )
# The routines will accept them.
my $ubuntu =  Userland.load-class; # Userland::Ubuntu
# or
my $fedora =  Userland.new; # Userland::Fedora.new
# or
my $centos    =  ( require Userland::CentOS );

install-package($ubuntu,'ntp');
install-package($fedora,'ntp');
install-package($centos,'ntp');

#etc
```

## Description

**warning** this is module is experimental and subject to change

The main point of `OO::Schema` is to separate the the declaration of
class inheritance trees and class implementation at a compunit
level. It allows you to refer to classes by shortname aliases (schema
nodes) without loading them until you need the actual
implementation. The nodes contain inheritence information and any
other meta-information like roles or methods attached to the node.

There are two main use cases that I know of (but you may discover more):

1. Type introspection. You want to be able to see the relationships
between classes without loading them.

    ```perl6
    use Userland;
    # You can know that Ubuntu isa Debian without loading compunits implementing either one
    say Ubuntu.isa(Debian); #-> True
    # You can declare Typed parameters that accept a certain class without loading that class
    multi something(Debian $computer) { ... }
    ```
2. Dynamic loading. Depending on user input, your module may only need
to load a subset of the modules in your distribution.

    ```perl6
    use Userland;
    sub USAGE {
        say "pass me one of:\n" ~ Userland.children(:all)».^name.join("\n");
    }
    # check the arg is a userland without having to load them all
    sub MAIN($userland-name, *%opts ){
        my $userland = Userland.resolve($userland-name);
        die USAGE() if $userland === Any;
        $userland .= new(|%opts);
        # do further introspection on a "real" class instance
        given $userland {
            when Windows { ... }
            when RHEL    { ... }
            when Debian  { ... }
        }
    }
    ```

Without using `OO::Schema` you will write code like this:

``` perl6
need Userland::Ubuntu;
need Userland::Debian;
need Userland::RHEL;
need Userland::Fedora;

multi do-something(Userland::Fedora:D $ul) { ... }
multi do-something(Userland::RHEL:D $ul)   { ... }
...
```

or this when you are declaring inheritance

``` perl6
need Userland::Debain;
unit class Userland::Ubuntu is Userland::Debain
```




## Declaring a Schema

Inside a Perl6 module file, `use OO::Schema` and declare a
`schema`. If the schema name is not the same as the the directory
where the node definitions will be stored, use `is path` to set it.

```perl6
    # lib/OS/Userland.pm6
    use OO::Schema;
    # as opposed to just schema OS::Userland { }
    schema Userland is path('OS::Userland') {
    # now schema definitions should go in lib/OS/Userland/
}
```

Declare nodes with `node`. Node names shouldn't contain any `::`.  You
can give them methods, attributes and roles if you want. Whether you
do depends on whether you want to have them available without having
to load the underlying class.

```perl6
# lib/OS/Userland.pm6
use OO::Schema;

role APT { }

schema Userland is path('OS::Userland') {
    node Debian does APT {

        method default-gui { 'GNOME' }

        node Ubuntu {
            node Kubuntu {
                method default-gui { 'KDE' }
            }
        }
    }
    node RHEL {
        ...
    }
}
```

## Declaring an Underlying Class
In the appropriate directory, `use` your schema with `:node` and declare a class
with `is schema-node`.

```perl6
# lib/OS/Userland/Ubuntu.pm6
use OS::Userland :node;

unit class OS::Userland::Ubuntu is schema-node;
```

## How is this achieved

When the schema module is loaded the relationship of the nodes looks like:

```perl6
use Userland;
```

```
             Userland
               /
      .---->POSIX
     /       /
   RHEL   Debian
   /       /
Fedora  Ubuntu

```

When a node-backing class is loaded marking itself with `is
schema-node`, it attaches itself to the node class and
recursively loads and inherits from its parent. Afterwards the inheritance tree
will look like:

```perl6
use Userland;
use Userland::Ubuntu;
```

```
             Userland
               /
      .---->POSIX <-- Userland::POSIX
     /       /              /
   RHEL   Debian <-- Userland::Debian
   /       /              /
Fedora  Ubuntu  <-- Userland::Ubuntu

```

## Node Methods

### load-class

Loads the class associated with the node.

``` perl6
say Fedora.load-class.^name # Userland::Fedora
```

### new

Loads the class associated with the node and calls `.new` with the
arguments passed.

``` perl6
Fedora.new(foo => "bar");
# short for
Fedora.load-class.new(foo => "bar");
```

### matches

Does the node loosely match a string.

``` perl6
Debian.matches(Debian)   # True
Debian.matches("Debian") # True
Debian.matches("debian") # True
Debian.matches("Userland::Debian") # True
Debian.matches(Userland::Debian) # True

# OSX is alias ('Darwin')
OSX.matches("darwin") # True
```

### resolve

``` perl6
Userland.resolve("centos") # CentOS
```

Walks the schema calling `matches` on each node with the argument. It
returns the first node it finds. Although node's have it too this is
usually called on the schema.

### children

``` perl6
Userland.children # Windows, POSIX
POSIX.children # BSD, GNU
GNU.children(:all) # Debian, Ubuntu, RHEL, Fedora, CentOS
```

Returns the node's direct child nodes. if `:all` is passed, returns
all descendants.

## Traits

### is alias

``` perl6
node OSX is alias('Darwin','xnu') { }

OSX.matches("darwin") # True
OSX.matches("xnu");   # True
```

Tells the node it should also match against the arguments to `is alias`.

### is path

```perl6
# Everything under Userland is now loaded from OS::Userland
schema Userland is path('OS::Userland') {
    # Everything under RHEL is loaded from OS::Userland::RedHat
    # (RHEL is still loaded from OS::Userland::RHEL
    node RHEL is path('RedHat') {
        # Fedora, and Centos will now be loaded from:
        node Fedora { } # OS::Userland::RedHat::Fedora
        node CentOS { } # OS::Userland::RedHat::CentOS
    }
}

```

By default the underlying classes for nodes are all searched for under
the `schema`'s namespace.  `is path` means "prepend this to the load
name of any child node". `schema`s can use it to change the default
namepsace.

### load-from
```perl6
schema Userland is path('OS::Userland') {
    # RHEL.load-class will not load OS::Userland::RedHat
    node RHEL is load-from('OS::Userland::RedHat') {
        node Fedora { } # still loaded from OS::Userland::Fedora
        node CentOS { }
    }
}
```

Overrides the name of the load path ie CompUnit short-name to load
from. It doesn't affect child nodes.

### schema-node

```perl6
#lib/OS/Userland/RHEL.pm
use OS::Userland;

unit class OS::Userland::RHEL is schema-node;
```
```perl6
use OS::Userland;

unit class OS::Userland::RedHat is schema-node('RHEL');
```

Sets the node the class should attach to when loaded. By default it uses the shortname of
the class itself.

## potential changes

1. `is abstract` for when you don't want a node that doesn't have an underlying class.
2. It's tricky to apply roles with required methods to nodes because you probably want to
implement them in the underlying class not the node. Maybe the nodes should be more like roles which don't do that.
