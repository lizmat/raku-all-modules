use v6.c;

=begin pod

=head1 NAME 

Oyatul - Abstract representation of filesystem layout

=head1 SYNOPSIS

This runs the tests identified by 'purpose' test which can be in any
location in the layout with the library directory identified by the
purpose 'lib' :

=begin code

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

=end code

=head1 DESCRIPTION

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
L<Sofa|https://github.com/jonathanstowe/Sofa> to load a CouchDB design
document from an arbitrary (possibly user defined) file hierarchy unlike
C<couchapp> which requires a fixed directory structure. However
hopefully it will be useful in other applications.

=head2 class Oyatul::Layout

    class Oyatul::Layout does Oyatul::Parent

This is the top level description of the layout.

=head3 method new

    method new(Oyatul::Layout:U: -> Oyatul::Layout);

This is the constructor for the class, typically one would prefer one
of the C<generate> or C<from-json>, but this may be used if one is
creating a layout programmatically from some other form of configuration.

=head3 method generate

    method generate (Oyatul::Layout: Str :$root = '.' --> Oyatul::Layout)
    method generate (Oyatul::Layout: IO::Path:D :$root!)

This will create a new L<Oyatul::Layout> based on the directory structure
found in C<$root> (which defaults to the current directory,) it will by
default skip any files or directories who's name begins with '.'

=head3 method from-json

    method from-json (Oyatul::Layout:U: IO::Path :$path!, |c is raw --> Oyatul::Layout)
    method from-json (Oyatul::Layout:U: Str :$path!, |c is raw --> Oyatul::Layout)
    method from-json (Oyatul::Layout:U: Str $json, Str :$root = '.', Bool :$real --> Oyatul::Layout)

This returns a new L<Oyatul::Layout> based on the JSON that can be passed as a string, or (with C<path>)
as the path to a file containing JSON.  If C<root> is supplied this will be the path where the
layout is anchored (this defaults to the current directory.)  If the C<:real> adverb is supplied 
any templates found in the layout will have File or Directory instances created for the files or
directories that are in the position of the template.

The format of the JSON is described below.

=head3 method from-hash

    method from-hash (Oyatul::Layout: %h, :$root)

This returns a new L<Oyatul::Layout> based on a Hash containing data of the same format as the JSON.

=head3 method to-json

    method to-json (Oyatul::Layout:)

This returns a JSON string that describes the layout, it can be round-tripped through C<from-json>,
but is primarily intended to get a layout discovered by C<generate> which may be edited to suit
the application.

=head3 method path-parts

    method path-parts (Oyatul::Layout:)

This returns a list containing the value of C<root>, it will be used to create the paths of
the child nodes.

=head3 method create

    method create (Oyatul::Layout: Str :$root --> Bool)

This causes all the 'real' (i.e. non-template) nodes in the layout to be created starting
at the top-level by calling the C<create> methods in turn. It returns a Bool to indicate
whether all the creations were successfull.

=head3 method IO

    method IO (Oyatul::Layout: --> IO::Path)

This returns an L<IO::Path> object for the C<root> of the layout.

=head2 class Oyatul::File

    class Oyatul::File does Oyatul::Node

This represents a 'file' leaf-node in the layout. 

=head3 method to-hash

    method to-hash (Oyatul::File:D:)

Returns a representation of the File object as a Hash, which will be used
by its parent to get its Hash and eventually that for the whole layout.

=head3 method from-hash

    method from-hash (Oyatul::File: %h, Oyatul::Parent:D :$parent)

Creates a new L<Oyatul::File> object from the supplied Hash, if it is
to be inserted into a layout then C<parent> should be supplied (this
will be done by a L<Oyatul::Parent> when it is creating its children
from a hash using this method.)

=head3 method create

    method create (Oyatul::File: --> Bool)

This will attempt to create an empty file with the name of this L<File>
in the appropriate location, returning a Bool to indicate whether this
was successful, if something other than an empty file is to be created
then this can be over-ridden from a role specified in the C<does> key
in the layout.

=head3 method delete

    method delete (Oyatul::File: --> Bool)

This will attempt to delete the physical file that this File object
represents in the layout, returning a Bool indicating success.

=head3 method accepts-path

    method accepts-path (Oyatul::File: IO::Path:D $path --> Bool)

This returns a Bool to indicate whether the supplied L<IO::Path>
represents a file, it will be called by C<realise-template> with
the IO::Path object representing a directory entry to determine
whether it is suitable match for the template.  If some more
detailed check is required this can be over-ridden in a role
specified by the C<does> key for the template.


=head2 class Oyatul::Directory

    class Oyatul::Directory does Oyatul::Node does Oyatul::Parent

This represents a directory node in the layout, it can have file or
directory children.

=head3 method generate

    method generate (Oyatul::Directory: IO::Path:D :$root!, Oyatul::Parent :$parent!)

This will return a new L<Oyatul::Directory> with the name of the
basename of the supplied C<root> and with all the child nodes populated
iteratively from those found in the filesystem,  C<parent> should be
either a L<Oyatul::Layout> or another L<Oyatul::Directory>.  This will
typically be called via the L<Oyatul::Layout> C<generate> method.

=head3 method from-hash

    method from-hash (Oyatul::Directory:U: %h, Oyatul::Parent:D :$parent)

This creates a new L<Oyatul::Directory> based on the supplied Hash.  If
it is to be inserted into a layout then C<parent> should be supplied, this
will be done when it is being called via the L<Oyatul::Layout> C<from-hash>.

=head3 method create

    method create (Oyatul::Directory: --> Bool)

This will attempt to create the filesystem structure this directory 
represents by creating itself (with C<mkdir>) and iteratively calling
C<create> on all of the children. It returns a Bool indicating
whether all creation was successful.

=head3 method accepts-path

    method accepts-path (Oyatul::Directory: IO::Path:D $path --> Bool)

This returns a Bool to indicate whether the supplied L<IO::Path>
represents a directory, it will be called by C<realise-template> with
the IO::Path object representing a directory entry to determine
whether it is suitable match for the template.  If some more
detailed check is required this can be over-ridden in a role
specified by the C<does> key for the template.


=head2 role Oyatul::Parent

This is a role for classes that can contain child objects, typically
L<Oyatul::Layout> and L<Oyatul::Directory>.

=head3 attribute @.children

    has Oyatul::Node @.children

This is the collection of the child nodes of this object.

=head3 method all-children

    method all-children (Oyatul::Parent: Bool :$real)

This returns a list of all the child objects of the object. If this is
a Layout object then it will be *all* the nodesi.

=head3 method template-for-purpose

    method template-for-purpose (Oyatul::Parent: Str $purpose --> Oyatul::Template)

This returns the L<Oyatul::Template> that has the specified purpose if one exists.

If more than one template exists for the same purpose then only the first found
will be returned, this implies that having more than one should be avoided.

=head3 method nodes-for-purpose

    method nodes-for-purpose (Oyatul::Parent: Str $purpose, Bool :$real)

This returns a list of all the L<Oyatul::Node> objects that have the specified
purpose. If the C<real> adverb is supplied only the non-template nodes are
returned.

=head3 method gather-children

    method gather-children (Oyatul::Parent: IO::Path:D $root)

This is used by the C<generate> method to discover the nodes in
the directory tree, returning a list of L<Oyatul::Node> objects
which will be created by calling C<generate> on them for each
file or directory in C<$root>

=head3 method child-by-name

    method child-by-name (Oyatul::Parent: Str $name --> Oyatul::Node)

Returns the L<Oyatul::Node> (a L<Oyatul::File> or L<Oyatul::Directory>)
that has the specified name.

=head3 method delete

    method delete (Oyatul::Parent: --> Bool)

This will attempt to delete the entire tree starting at this node, by
calling C<delete> on each node depth-first. It returns a Bool indicating
whether all the deletions were successful.  Care should be taken when
using this on an existing structure which may be shared with another
application as whilst it will only attempt to delete those nodes described
by the layout, it will attempt to delete the C<root> if this is a Layout
object.

=head3 method realise-templates

    method realise-templates (Oyatul::Parent:)

This will attempt to create 'real' L<Oyatul::Node> objects for all nodes
that are found in the place of a template in the layout, that is if
the template is a file and a file is found in the enclosing directory
then a L<Oyatul::File> with the name of the file will be created and
inserted into the layout instance.

This returns a list of all the instances that were created.

=head2 role Oyatul::Template

    role Oyatul::Template[Mu:U $real-type]

This role is applied to a node in the layout which has a True value
for the C<template> key, it is a placeholder for any number of 
named real nodes that may not be known until an instance of the
layout is applied to the filesystem.

The role is parameterised with the real (original type) of the
node (i.e. L<Oyatul::File> or L<Oyatul::Directory>) which will
be used to instantiate the 'real' object with C<make-real>.

=head3 method create

    method create ($?CLASS:)

A Template cannot actually exist so this is a stub that returns
true without doing anything.

=head3 method delete

    method delete ($?CLASS:)

A Template cannot actually exist so this is a stub that returns
true without doing anything.

=head3 method make-real

    method make-real ($?CLASS: Str $name)

This is called on the template object by C<gather-instances> with
the name of each matching node that is found. It returns a 'real'
L<Oyatul::Node> (that is one without the Template role,) that has
been inserted into the layout (i.e added to the C<children> of
the parent of the Template and C<parent> populated appropriately.

=head3 method gather-instances

    method gather-instances ($?CLASS:)

This will be called by C<realise-templates> for each template in the
tree. For each filesystem node in the same location as the template
for which accepts-path returns true, C<make-real> will be called with
the name of the node.  This returns a list of the 'real' instances that
were created.

=head3 method is-template

    method is-template ($?CLASS:)

This returns True for any object that does this role.

=head2 role Oyatul::Node

This is role for items in the Layout, (i.e. File, Directory)

=head3 attribute name

    has Str $.name;

This is the basename of the filesystem node in layout, it is
required for all objects that are not templates.

=head3 attribute parent

    has Oyatul::Parent $.parent;

This is the parent object of the node. This will typically be
populated by the parent object itself when the object is being
added to the layout.

=head3 attribute purpose

    has Str $.purpose

This is the 'purpose' as defined by the same named key in the
layout description.  It is an arbitrary string that will be
matched by the C<nodes-for-purpose> method of L<Oyatul::Parent>.

=head3 method IO

    method IO (Oyatul::Node: --> IO::Path)

Returns the L<IO::Path> object representing the C<path> in the layout.

=head3 method path

    method path (Oyatul::Node: --> Str)

Returns the full path of the node in the layout, it will be anchored at
the C<root> of the layout instance.

=head3 method path-parts

    method path-parts (Oyatul::Node:)

This returns a list of the individual parts of the path of the node, the
first element will be the C<root> of the layout.

=head3 method is-template

    method is-template (Oyatul::Node: --> Bool)

This will return a Bool indicating if this C<Node> is infact a C<Template>
(that is it does the L<Oyatul::Template> role,)

=head3 method create

    method create ($?CLASS: --> Bool)

This is an "abstract" method that must be defined by the composing class.

=head3 method delete

    method delete ($?CLASS: --> Bool)

This is an "abstract" method that must be defined by the composing class.

=head3 method accepts-path

    method accepts-path ($?CLASS: IO::Path:D $ --> Bool)

This is an "abstract" method that must be defined by the composing class.

=head1 DESCRIPTION FORMAT

The layout description will typically be stored as a JSON formatted file,
but could be stored in any format that can be de-serialised to a similarly
structured Hash.  Alternatively the description could be stored in any
medium and the layout objects created individually based on the data.

The top level item should be a Hash (or JSON Object,) with the key C<type>
with the value 'layout', and C<children> which will be an Array of 
Objects describing the child nodes.

=head2 NODE KEYS

=head3 name

=head3 type

This is mandatory and must be either C<file> or C<directory> (except at
the top level where it must be C<layout>.)  If any other value is found
in traversing the description an exception will be thrown.

If the type is C<file> it will result in a L<Oyatul::File>, if C<directory>
then L<Oyatul::Directory>.

=head3 purpose

This is an optional key, that can be an arbitrary string, that will be
matched by C<nodes-for-purpose>.

=head3 children

This is mandatory for nodes of C<type> 'directory' or 'layout' type and
must be an Array of node objects (or an empty Array,) that represent the
child objects.

=head3 does

This is optional and if present will be the short name of a role that
will be required (if it isn't already loaded,) and mixed in to the
L<Oyatul::Node> that is instantiated from the description. If it 
cannot be loaded or the name doesn't specify a composable type then
an exception will be thrown.

The role can supply behaviour that is specific to the application
or over-ride the methods of L<Oyatul::Node> (e.g. a C<create> that
will populate a data file in a certain way.)

=head3 template

This is an optional boolean that indicates whether the node is
a template or not, if it is true then the role L<Oyatul::Template>
will be applied to the node object when it is being added to the
layout.

=end pod

use JSON::Fast;

module Oyatul:ver<0.0.4>:auth<github:jonathanstowe> {

    my Regex $exclude = /^<-[.]>/;

    role Node { ... }
    class File { ... }
    class Directory { ... }

    role Template[$real-type] {
        method create() {
            True;
        }

        method delete() {
            True;
        }

        method make-real(Str $name) {
            my %h = self.to-hash();
            %h<name> = $name;
            my $real = $real-type.from-hash(parent => self.parent, %h);
            self.parent.children.append: $real;
            $real;
        }

        method gather-instances() {
            my @reals;
            if self.parent.defined {
                for self.parent.IO.dir(test => $exclude) -> $node {
                    if self.accepts-path($node) {
                        my $name = $node.basename;
                        if not self.parent.child-by-name($name) {
                            @reals.append: self.make-real($name);
                        }
                    }
                }
            }
            @reals;
        }

        method is-template() {
            True;
        }
        
    }

    my role Parent {
        has Node @.children;

        has Node %!children-by-name;

        method child-by-name(Str $name ) returns Node {
            if %!children-by-name.elems != @!children.elems {
                %!children-by-name = @!children.grep({$_.name.defined }).map({ $_.name => $_ });
            }
            %!children-by-name{$name};
        }

        method gather-children(IO::Path:D $root) {
            for $root.dir(test => $exclude) -> $child {
                my $node;
                if $child.d {
                    $node = Directory.generate(root => $child, parent => self);
                }
                else {
                    $node = File.new(name => $child.basename, parent => self);
                }
                self.children.append: $node;
            }
        }

        method to-hash(Parent:D:) {
            my %h = type => self.what, children => [];
            %h<name> = self.name if self.can('name');
            %h<purpose> = self.purpose if self.can('purpose');
            for self.children -> $child {
                %h<children>.push: $child.to-hash;
            }
            %h;
        }

        my class X::BadRole is Exception {
            has $.role-name;
            has $.node-name;
            method message() {
                "cannot resolve role '{ $!role-name }' specified for node '{ $!node-name }'";
            }
        }

        sub get-type(Mu:U $base-type, %h) {
            my $type = $base-type;
            if %h<does> -> $role-name {
                my $role = ::($role-name);
                if !$role &&  $role ~~ Failure {
                    CATCH {
                        default {
                            say $_;
                            X::BadRole.new(:$role-name, node-name => %h<name>).throw;
                        }
                    }
                    $role = (require ::("$role-name"));
                }
                if $role !~~ Failure {
                    $type = $base-type but $role;
                }
                else {
                   X::BadRole.new(:$role-name, node-name => %h<name>).throw;
                }
            }
            %h<template> ?? $type but Template[$type] !! $type;
        }

        method children-from-hash(Parent:D: %h) {
            for %h<children>.list -> $child {
                my $child-node = do given $child<type> {
                    when 'directory' {
                        my $type = get-type(Directory,$child);
                        $type.from-hash(parent => self, $child);
                    }
                    when 'file' {
                        my $type = get-type(File, $child);
                        $type.from-hash(parent => self, $child);
                    }
                    default {
                        die 'DAFUQ!';
                    }
                }
                self.children.append: $child-node;
            }
        }

        method all-children(Bool :$real) {
            gather {
                for self.children.list -> $child {
                    unless ( $real && $child ~~ Template) {
                        take $child;
                        if $child ~~ Parent {
                            for $child.all-children(:$real) -> $child {
                                take $child;
                            }
                        }
                    }
                }
            }
        }


        method nodes-for-purpose(Str $purpose, Bool :$real) {
            self.all-children(:$real).grep({ $_.purpose.defined && $_.purpose eq $purpose });
        }

        method template-for-purpose(Str $purpose) returns Template {
            self.nodes-for-purpose($purpose).grep(*.is-template).first;
        }

        method all-templates() {
            self.all-children.grep(Template);
        }

        method realise-templates() {
            my @reals;
            for self.all-templates -> $template {
                @reals.append: $template.gather-instances;
            }
            @reals;
        }

        method delete() returns Bool {
            my @res;
            for self.children -> $child {
                @res.append: $child.delete;
            }
            @res.append: self.IO.rmdir;
            so all(@res);
        }
    }

    role Node {
        has Str    $.name;
        has Parent $.parent;
        has Str    $.purpose;

        method path-parts() {
            my @parts = $!name;
            if $!parent.defined {
                @parts.prepend: $!parent.path-parts;
            }
            @parts;
        }

        method is-template() {
            False;
        }

        method path() returns Str {
            $*SPEC.catdir(self.path-parts);
        }

        method IO() returns IO::Path {
            self.path.IO;
        }

        method create() returns Bool {
            ...
        }

        method delete() returns Bool {
            ...
        }

        method accepts-path(IO::Path:D ) returns Bool {
            ...
        }
    }

    class File does Node {
        method to-hash(File:D:) {
            my %h = type => 'file', name => $!name;
            %h<purpose> = self.purpose if self.purpose.defined;
            %h;
        }

        method from-hash(%h, Parent:D :$parent) {
            self.new(:$parent,|%h);
        }

        method create() returns Bool {
            my $fh = self.IO.open(:w);
            $fh.close;
        }
        method delete() returns Bool {
            so self.IO.unlink;
        }
        method accepts-path(IO::Path:D $path) returns Bool {
            $path.e && $path.f
        }

    }

    class Directory does Node does Parent {

        has Str $.what = 'directory';

        proto method generate(|c) { * }

        multi method generate(IO::Path:D :$root!, Parent :$parent!) {
            my $dir = self.new(name => $root.basename, :$parent);
            $dir.gather-children($root);
            $dir;
        }

        method from-hash(Directory:U: %h, Parent:D :$parent) {
            my %args = %h.pairs.grep({$_.key ~~ any(<name purpose>) && $_.value.defined}).Hash;
            my $dir = self.new(|%args, :$parent);
            $dir.children-from-hash(%h);
            $dir;
        }

        method create() returns Bool {
            my @res = self.IO.mkdir();
            for self.children -> $child {
                @res.append: $child.create;
            }
            so all(@res);
        }

        method accepts-path(IO::Path:D $path) returns Bool {
            $path.e && $path.d
        }

    }

    class Layout does Parent {
        has Str  $.root = '.';
        has Str  $.what = 'layout';

        proto method generate(|c) { * }

        multi method generate(Str :$root = '.') returns Layout {
            self.generate(root => $root.IO);
        }

        multi method generate(IO::Path:D :$root!) {
            my $layout = self.new(root => $root.basename);
            $layout.gather-children($root);
            $layout;
        }

        method from-hash(%h, :$root) {
            my $layout = self.new(:$root);
            $layout.children-from-hash(%h);
            $layout;
        }

        method to-json() {
            to-json(self.to-hash);
        }

        proto method from-json(|c) { * }

        multi method from-json(Layout:U: Str :$path!, |c) returns Layout {
            self.from-json(path => $path.IO, |c);
        }

        multi method from-json(Layout:U: IO::Path :$path!, |c) returns Layout {
            self.from-json($path.slurp, |c);
        }


        multi method from-json(Layout:U: Str $json, Str :$root = '.', Bool :$real) returns Layout {
            my $layout = self.from-hash(from-json($json), :$root);
            if $real {
                $layout.realise-templates
            }
            $layout;
        }

        method path-parts() {
            $!root;
        }


        method create(Str :$root) returns Bool {
            $!root = $root.Str if $root.defined;

            if !$!root.IO.e {
                $!root.IO.mkdir;
            }
            my Bool @res;
            for self.children -> $child {
                @res.append: $child.create;
            }
            so all(@res);
        }

        method IO() returns IO::Path {
            $!root.IO;
        }
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
