#
# a Perl 6 port of ruby facter
# http://github.com/cosimo/perl6-facter/
#

# Original facter copyright statement:
# from http://github.com/puppetlabs/facter/
#
#--
# Copyright 2006 Luke Kanies <luke@madstop.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
#--

use v6;

class Facter;

use Facter::Util::Fact;
use Facter::Util::Collection;

our $VERSION = '0.04';
our $LAST_OBJECT;

# TODO: RT#77906
#%*ENV<LANG> = 'C';

# Static variables (@@debug)
our $debug = 0;
our $timing = 0;
our $collection;

# Private members
has @!search_path is rw = ();

method collection {
    $collection //= Facter::Util::Collection.new
}

method version {
    $VERSION
}

method BUILD {
    $LAST_OBJECT = self;
}

multi method debugging {
    return $debug != 0
}

# Set debugging on or off (1/0)
multi method debugging($bit) {
    if $bit {
        $debug = 1;
    }
    else {
        $debug = 0;
    }
}

method debug($string) {
    if ! defined $string {
        return
    }
    if self.debugging {
        say $string;
    }
    return;
}

method show_time($string) {
    if $string and self.timing {
        say $string
    }
    return;
}

multi method timing {
    return $timing != 0;
}

# Set timing on or off.
multi method timing($bit) {
    if $bit {
        $timing = 1;
    } else {
        $timing = 0;
    }
}

# Return a fact object by name.  If you use this, you still have to call
# 'value' on it to retrieve the actual value.
method get_fact($name) {
    self.collection.fact($name);
}

method fact(*@args) {
    my $fact = self.collection.fact(@args);
    Facter.debug("Facter.fact returns $fact");
    return $fact;
}

method flush(*@args) {
    self.collection.flush(@args);
}

method value (*@args) {
    self.collection.value(@args);
}

#for 'fact', 'flush', 'value' -> $name {
#    Facter.^add_method($name, method (*@args) {
#        self.collection.$name.(@args);
#    });
#}

#for 'list', 'to_hash' -> $name {
#    Facter.^add_method($name, method (*@args) {
#        self.collection.load_all();
#        self.collection.$name.(@args);
#    });
#}

method list {
    self.collection.load_all();
    self.collection.list();
}

method to_hash {
    self.collection.load_all();
    self.collection.to_hash();
}

# Add a resolution mechanism for a named fact.  This does not distinguish
# between adding a new fact and adding a new way to resolve a fact.
method add ($name, Sub $block) {
    Facter.debug("Facter: adding fact $name as " ~ $block.perl);
    my $instance = self // Facter.get_instance;
    $instance.collection.add($name, $block);
}

method get_instance {
    if self { return self }
    $LAST_OBJECT //= Facter.new;
}

method each {
    self.collection.load_all();
    gather for self.collection -> $fact {
        take $fact;
    }
}

# Clear all facts.  Mostly used for testing.
method clear {
    self.flush;
    self.reset;
    return;
}

method warn ($msg) {
    if self.debugging and $msg and $msg != "" {
        $msg = [ $msg ] unless $msg.^can('each');
        for $msg -> $line {
            warn $line;
        }
    }
}

method reset {
    $collection = ();
}

# Load all of the default facts, and then everything from disk.
method loadfacts {
    self.collection.load_all();
}

# Register a directory to search through.
method search(@dirs) {
    @!search_path.push(@dirs);
}

# Return our registered search directories.
method search_path {
    return @!search_path;
}

