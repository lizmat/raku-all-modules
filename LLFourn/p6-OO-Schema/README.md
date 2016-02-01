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

        node FreeBSD { }
        node OpenBSD { }

        node GNU {
            node Debian {
                node Ubuntu { }
            }
            node RHEL  {
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
# That's enough - I don't have to load Userland::RHEL or Userland::Debian

proto install-package(Userland:D,Str:D $pkg) {*};

# but you can still talk about things inheriting from them
# with these magical short names like 'Debian' and 'RHEL'
multi install-package(Debian $userland,$pkg) {
    run 'apt-get', 'install', $pkg;
}

multi install-package(RHEL $userland,$pkg) {
    run 'yum', 'install', $pkg;
}

# now at runtime you load particular real class and make
# an instance. It just works!
my $ubuntu = (require Userland::Ubuntu).new;
my $fedora = (require Userland::Fedora).new;

install-package($ubuntu,'ntp');
install-package($fedora,'ntp');

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
# You can know that Ubuntu isa debian without loading compunits implementing either one
say Ubuntu.isa(Debian); #-> True
```
2. Dynamic loading. Depending on user input, your module may only need
   to load a subset of the modules in your distribution.

```perl6
use Userland;
# check the arg is a userland without having to load them all
sub MAIN($userland-name where { ::($_) ~~ Userland}, *%opts ){
    my $userland = ::($userland-name).load-node-class().new(|%opts);

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

Declare nodes with `node`. Node names shouldn't contain any `::` (for
now).  You can give them methods, attributes and roles if you
want. Whether you do depends on whether you want to have them
available without having to load the underlying class.

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

Each node has `new` and `load-class` installed as
submethods. `load-class` will load the underlying class while `.new`
is just shorthand for:

``` perl6
Fedora.load-class.new( fancy => 'arg' )
```


## Traits

### is path

```perl6
schema userland {
    node RHEL is path is path('OS::Userland') {
        # Fedora, and Centos will now be loaded from
        # Userland::RHEL::Fedora, instead of Userland::Fedora
        node Fedora { }
        node CentOS { }
    }
}
```

```perl6
schema userland is path('OS::Userland') {
    node RHEL is path('RedHat') {
        # Fedora, and Centos will now be loaded from
        # Userland::RedHat::Fedora, instead of Userland::Fedora
        node Fedora { }
        node CentOS { }
    }
}
```
By default the underlying classes for nodes are all searched for under the `schema`'s namespace.
`is path` indicates that the node represents a subnamespace as well as a class. `schema`s can
use it to change the default namepsace but they are already represented by a directory.

### loaded-from
```perl6
schema userland is path('OS::Userland') {
    node RHEL is loaded-from('OS::Userland::RedHat') {
        # Fedora, and Centos will now be loaded from
        # Userland::RedHat::Fedora, instead of Userland::Fedora
        node Fedora { }
        node CentOS { }
    }
}
```
Sets the name to load the node's underlying class from.

### schema-node

```perl6
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

1.`is abstract` for when you don't want a node that doesn't have an underlying class
2. It's tricky to apply roles with required methods to nodes because you probably want to implement them in the underlying class not the node. Maybe the nodes should be more like roles which don't do that.
3. I might make it possible to put `::` in the names of nodes things.
