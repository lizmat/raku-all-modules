class Tree::Simple {
    ## class constants
    our $ROOT = "root";

    #uid should be private however cannot init it a value within a new fcn
    #will be private when submethod BUILD works
    has $.uid is rw;
    has $.node is rw;
    has @.children is rw;
    has $.height is rw = 1;
    has $.width is rw = 1;
    has $.parent is rw;
    has $.depth is rw =-1;
    

## ----------------------------------------------------------------------------
## Tree::Simple
## ----------------------------------------------------------------------------


### constructor

multi method new(){
    my $x =self.bless(*, node => '',parent => 'root');

    #####
    #should be in submethod BUILD
    $x.uid = $x.WHERE;
    ###
    return $x;
}
    
    
multi method new($node) {
    my $x =self.bless(*, node => $node,parent => 'root');

    #####
    #should be in submethod BUILD
    $x.uid = $x.WHERE;
    ###
    return $x;
}

multi method new($node,'root'){
    my $x= self.bless(*, node => $node,parent =>'root');

    #####
    #should be in submethod BUILD
    $x.uid = $x.WHERE;
    ###
    return $x;
}

#todo might be a rakudo bug where i cannot put the object type in the signatures without failing..
multi method new($node,$parent){
    die 'Parent is not a Tree::Simple' if $parent !~~ Tree::Simple;
    
    my $x = self.bless(*, node => $node,parent =>$parent,depth => $parent.getDepth() + 1);

    #####
    #should be in submethod BUILD
    $x.uid = $x.WHERE;
    $parent.addChild($x);
    ###
    return $x;
}


method !setParent($parent where { $parent eq $Tree::Simple::ROOT || $parent ~~ Tree::Simple}) {
     $.parent = $parent;    
     if ($parent eq $ROOT) {
         $.depth = -1;
     }
     else {
         $.depth = $parent.getDepth() + 1;
     }
}

method !detachParent() {
#     return if $USE_WEAK_REFS;
     self.parent = Mu;
}

method setHeight(Tree::Simple $child) {

     my $child_height = $child.getHeight();
     if self.height < $child_height +1  {
         self.height = $child_height+1;
     }

     # and now bubble up to the parent (unless we are the root)
     if ! self.isRoot() {
         self.getParent().setHeight(self);
     }
}

multi method setWidth(Tree::Simple $child_width) {
    return if self.width > self.getChildCount();    
    my $width = $child_width.getWidth();
    self.width += $width;
    
     # and now bubble up to the parent (unless we are the root)
    if !self.isRoot() {
        self.getParent().setWidth($width);
    }
    
}
    
    
multi method setWidth(Int $child_width) {
     self.width += $child_width;
     # and now bubble up to the parent (unless we are the root)
     self.getParent().setWidth($child_width) unless self.isRoot();            
}

## ----------------------------------------------------------------------------
## mutators

method setNodeValue($node_value where {defined($node_value)}) {
    self.node = $node_value;
}

method setUID($uid where { defined($uid) }) {
    self.uid = $uid;
}

## ----------------------------------------------
## child methods

#around type method like moose
method addChild(Tree::Simple $child) {
    #provides the index
    my $index = self.getChildCount();
    self.insertChildAt($index,$child);
    return self;
}

method addChildren(*@children) {
    my $index;
    for |@children -> $child {
        $index = self.getChildCount();
        self.insertChildAt($index,$child);        
    }
    return self;
}

#adding alias for insertChildAt
#Tree::Simple.^add_method('insertChild', Tree::Simple.^can('insertChildAt')); 
#Tree::Simple.^add_method('insertChildren', Tree::Simple.^can('insertChildAt')); 
#todo hopefully one day it will return the two functions below
method insertChild($index,*@trees) {
	self.insertChildAt($index,|@trees);
}

method insertChildren($index,*@trees) {
	self.insertChildAt($index,|@trees);
}
#need to have an index and at least one child
method insertChildAt(Int $index where { $index >= 0 },*@trees where { @trees.elems() > 0 }) {
     # check the bounds of our children 
     # against the index given
     my $max = self.getChildCount();
     if $index > $max {
          die "Index Out of Bounds : got ($index) expected no more than (" ~ $max ~ ")";
     }


     for |@trees -> $tree is rw {
         $tree ~~ Tree::Simple 
             || die "Insufficient Arguments : Child must be a Tree::Simple object";
         $tree!setParent(self);
         self.setHeight($tree);   
         self.setWidth($tree);                         
         $tree.fixDepth() unless $tree.isLeaf();
     }

    # if index is zero, use this optimization
    if $index == 0 {
        unshift self.children , |@trees;
    }
    # if index is equal to the number of children
    # then use this optimization    
    elsif $index == $max {
        push self.children , |@trees;
    }
    # otherwise do some heavy lifting here
    else {
        splice self.children, $index,0, |@trees;
    }
}

method removeChildAt($index) {

    (self.getChildCount() != 0) 
         || die "Illegal Operation : There are no children to remove";        
    # check the bounds of our children 
    # against the index given        
     ($index < self.getChildCount()) 
         || die "Index Out of Bounds : got ($index) expected no more than (" ~ self.getChildCount() ~ ")";        

    my $removed_child;
    # if index is zero, use this optimization    
    if $index == 0 {
        $removed_child = shift self.children;
    }
    # if index is equal to the number of children
    # then use this optimization    
    elsif $index == self.children.end {
        $removed_child = pop self.children;    
    }
    # otherwise do some heavy lifting here    
    else {
        $removed_child = self.children[$index];
        splice self.children, $index, 1;
    }
    # make sure we fix the height
    self.fixHeight();
    self.fixWidth();    
    # make sure that the removed child
    # is no longer connected to the parent
    # so we change its parent to ROOT
    $removed_child!setParent($ROOT);
    # and now we make sure that the depth 
    # of the removed child is aligned correctly
    $removed_child.fixDepth() unless $removed_child.isLeaf();    
    # return ths removed child
    # it is the responsibility 
    # of the user of this module
    # to properly dispose of this
    # child (and all its sub-children)
    return $removed_child;
}

    # maintain backwards compatability
    # so any non-ref arguments will get 
    # sent to removeChildAt
    #todo nyi what is ref in p6 idoms?    
multi method removeChild(Int $child_index) {
    return self.removeChildAt($child_index);
}
    
    
multi method removeChild(Tree::Simple $child_to_remove) {
    my $index = 0;
    for self.getAllChildren() -> $child {
        ("$child" eq "$child_to_remove") && return self.removeChildAt($index);
        $index++;
    }
    die "Child Not Found : cannot find object ($child_to_remove) in self";
}

method getIndex {
    return -1 if $.parent eq $ROOT;
    my $index = 0;
    for self.parent.getAllChildren() ->  $sibling {
        #probably stringify the object to see if they are the same. Nice short circuit as well
        ("$sibling" eq self) && return $index;
        $index++;
    }
    return $index;
}

## ----------------------------------------------
## Sibling methods

# these addSibling and addSiblings functions 
# just pass along their arguments to the addChild
# and addChildren method respectively, this 
# eliminates the need to overload these method
# in things like the Keyable Tree object

method addSibling(Tree::Simple $child) {
     (!self.isRoot()) 
         || die "Insufficient Arguments : cannot add a sibling to a ROOT tree";
    self.parent.addChild($child);
}

method addSiblings(@siblings) {
     (!self.isRoot()) 
         || die "Insufficient Arguments : cannot add siblings to a ROOT tree";
     self.parent.addChildren(@siblings);
}

method insertSibling($index,$sibling) {
    (!self.isRoot()) 
         || die "Insufficient Arguments : cannot insert sibling(s) to a ROOT tree";
    self.parent.insertChildren($index,$sibling);
}
    
    
method insertSiblings($index,@args) {
    (!self.isRoot()) 
         || die "Insufficient Arguments : cannot insert sibling(s) to a ROOT tree";
    self.parent.insertChildren($index,@args);    
}

# I am not permitting the removal of siblings 
# as I think in general it is a bad idea

## ----------------------------------------------------------------------------
## accessors
#todo remove them and add the alias to the attributes
method getUID       { $.uid;    }
method getParent    { $.parent; }
method getDepth     { $.depth;  }
method getNodeValue { $.node;   }
method getWidth     { $.width;  }
method getHeight    { $.height; }

method getChildCount {
    return @.children.elems();
}

method getChild(Int $index) {
     return self.children[$index];
}

method getAllChildren {
    return self.children;
}

method getSibling($index) {
     (!self.isRoot()) 
         || die "Insufficient Arguments : cannot get siblings from a ROOT tree";    
     self.getParent().getChild($index);
}

method getAllSiblings {
     (!self.isRoot()) 
         || die "Insufficient Arguments : cannot get siblings from a ROOT tree";
    self.getParent().getAllChildren();
}

## ----------------------------------------------------------------------------
## informational

method isLeaf {
    self.getChildCount() == 0;
}

method isRoot {
    return (!defined($.parent) || $.parent eq $ROOT);
}

method size() {
    my $size = 1;
    for self.getAllChildren() -> $child {
        $size += $child.size();    
    }
    return $size;
}

## ----------------------------------------------------------------------------
# misc

# NOTE:
# Occasionally one wants to have the 
# depth available for various reasons
# of convience. Sometimes that depth 
# field is not always correct.
# If you create your tree in a top-down
# manner, this is usually not an issue
# since each time you either add a child
# or create a tree you are doing it with 
# a single tree and not a hierarchy.
# If however you are creating your tree
# bottom-up, then you might find that 
# when adding hierarchies of trees, your
# depth fields are all out of whack.
# This is where this method comes into play
# it will recurse down the tree and fix the
# depth fields appropriately.
# This method is called automatically when 
# a subtree is added to a child array
method fixDepth {
    # make sure the tree's depth 
    # is up to date all the way down
    self.traverse(sub ($tree) {
            return if $tree.isRoot();
            $tree.depth = $tree.getParent().getDepth() + 1;
        }
    );
}

# NOTE:
# This method is used to fix any height 
# discrepencies which might arise when 
# you remove a sub-tree
method fixHeight {
    # we must find the tallest sub-tree
    # and use that to define the height
    my $max_height = 0;
    unless self.isLeaf() {
        for self.getAllChildren() -> $child {
            my $child_height = $child.getHeight();
            $max_height = $child_height if $max_height < $child_height;
        }
    }
    # if there is no change, then we 
    # need not bubble up through the
    # parents
    return if self.height == ($max_height + 1);
    # otherwise ...
    self.height = $max_height + 1;
    # now we need to bubble up through the parents 
    # in order to rectify any issues with height
    self.getParent().fixHeight() unless self.isRoot();
}

method fixWidth {
    my $fixed_width = 0;
    for self.getAllChildren() {
        $fixed_width += $_.getWidth();
    }
    
    self.width = $fixed_width;
    self.getParent().fixWidth() unless self.isRoot();
}

method traverse(Code $func,Code $post?) {
    for self.getAllChildren() -> $child { 
        $func.($child);
        $child.traverse($func, $post);
        $post && $post.($child);
    }
}

# this is an improved version of the 
# old accept method, it now it more
# accepting of its arguments

method accept($visitor) {

    #todo check to ensure that the $visitor has the 'visit' fcn
#    die '$Visitor is not a valid Visitor object' if $visitor !~~ Tree::Simple::Visitor;
	
#     my ($self, $visitor) = @_;
#     # it must be a blessed reference and ...
#     (blessed($visitor) && 
#         # either a Tree::Simple::Visitor object, or ...
#         ($visitor.isa("Tree::Simple::Visitor") || 
#             # it must be an object which has a 'visit' method avaiable
#             $visitor.can('visit')))
#         || die "Insufficient Arguments : You must supply a valid Visitor object";
	$visitor.visit(self);
}
    


    
## ----------------------------------------------------------------------------
## cloning 

method clone() {
    # first clone the value in the node
    my $cloned_node = cloneNode(self.getNodeValue());
    # create a new Tree::Simple object 
    # here with the cloned node, however
    # we do not assign the parent node
    # since it really does not make a lot
    # of sense. To properly clone it would
    # be to clone back up the tree as well,
    # which IMO is not intuitive. So in essence
    # when you clone a tree, you detach it from
    # any parentage it might have
    my $clone = self.new($cloned_node);
    # however, because it is a recursive thing
    # when you clone all the children, and then
    # add them to the clone, you end up setting
    # the parent of the children to be that of
    # the clone (which is correct)
    $clone.addChildren(
                map { $_.clone() }, self.getAllChildren()
                ) unless self.isLeaf();
    # return the clone            
    return $clone;
}
    
# this allows cloning of single nodes while 
# retaining connections to a tree, this is sloppy
method cloneShallow() {
     my $cloned_tree = self.new(cloneNode(self.getNodeValue()));
     $cloned_tree.addChildren(self.getAllChildren);
#     # just clone the node (if you can)
     return $cloned_tree;    
}

multi sub cloneNode(Str $node,%seen? = {} ) {
    	# store the clone in the cache and 
    	%seen{$node} = $node;        

	return $node;
}

multi sub cloneNode($node where { $node ~~ Array}, %seen? ={}){
        my $clone = [ map { cloneNode($_, %seen) }, @($node) ];

    	# store the clone in the cache and 
    	%seen{$node} = $clone;        

	return $clone;
}

multi sub cloneNode($node where { $node ~~ Hash },%seen? ={}){
        my $clone = {};
        for keys $node -> $key  {
	    $clone.{$key} = cloneNode($node.{$key}, %seen);
        }
       
    	# store the clone in the cache and 
    	%seen{$node} = $clone;        

	return $clone;
}
    
multi sub cloneNode(Tree::Simple $node, %seen? ={}) {
    	# store the clone in the cache and 
        my $clone = $node.clone();
    	%seen{$node} = $node;        

	return $clone;
}   
    
# this is a helper function which 
# recursively clones the node
multi sub cloneNode($node,%seen? = {}) {
    # create a cache if we dont already
    # have one to prevent circular refs
    # from being copied more than once
    # now here we go...
    my $clone;
    # if it is not a reference, then lets just return it
#    return $node unless $node ~~ Tree::Simple;
    # if it is in the cache, then return that
    return %seen{$node} if %seen{$node}:exists;
    # if it is an object, then ...
    if $node ~~ Tree::Simple {
        # see if we can clone it
        if $node.can('clone') {
            $clone = $node.clone();
        }
        # otherwise respect that it does 
        # not want to be cloned
        else {
            $clone = $node;
        }        
    }
    elsif $node ~~ Capture {
	$clone = $node;
    }
    else {
	$clone = $node;
    }
       
    # store the clone in the cache and 
    %seen{$node} = $clone;        
    # then return the clone
    return $clone;
}


## ----------------------------------------------------------------------------
## Desctructor

method DESTROY() {
    # if we are using weak refs 
    # we dont need to worry about
    # destruction, it will just happen
    #todo not sure what to do here... need to implement references
    #return if $USE_WEAK_REFS;
    # we want to detach all our children from 
    # ourselves, this will break most of the 
    # connections and allow for things to get
    # reaped properly
     unless (!(@.children) && @.children.elems()==0) {
         for @.children ->$child { 
             defined $child && $child!detachParent();
         }
     }
    # we do not need to remove or undef the _children
    # of the _parent fields, this will cause some 
    # unwanted releasing of connections. 
}

## ----------------------------------------------------------------------------
## end Tree::Simple
## ----------------------------------------------------------------------------

};


=begin pod

=head1 NAME

Tree::Simple - A simple tree object

=head1 SYNOPSIS

	use Tree::Simple;
  
	# make a tree root
	my $tree = Tree::Simple.new("0", $Tree::Simple::ROOT);
  
	# explicity add a child to it
	$tree.addChild(Tree::Simple.new("1"));
  
	# specify the parent when creating
	# an instance and it adds the child implicity
	my $sub_tree = Tree::Simple.new("2", $tree);
  
	# chain method calls
	$tree.getChild(0).addChild(Tree::Simple.new("1.1"));
  
	# add more than one child at a time
	$sub_tree.addChildren(
             Tree::Simple.new("2.1"),
             Tree::Simple.new("2.2")
	);

	# add siblings
	$sub_tree.addSibling(Tree::Simple.new("3"));
  
	# insert children a specified index
	$sub_tree.insertChild(1, Tree::Simple.new("2.1a"));
  
	# clean up circular references
	$tree.DESTROY();

=head1 DESCRIPTION

This module in an fully object-oriented implementation of a simple n-ary 
tree. It is built upon the concept of parent-child relationships, so 
therefore every B<Tree::Simple> object has both a parent and a set of 
children (who themselves may have children, and so on). Every B<Tree::Simple> 
object also has siblings, as they are just the children of their immediate 
parent. 

It is can be used to model hierarchal information such as a file-system, 
the organizational structure of a company, an object inheritance hierarchy, 
versioned files from a version control system or even an abstract syntax 
tree for use in a parser. It makes no assumptions as to your intended usage, 
but instead simply provides the structure and means of accessing and 
traversing said structure. 

This module uses exceptions and a minimal Design By Contract style. All method 
arguments are required unless specified in the documentation, if a required 
argument is not defined an exception will usually be thrown. Many arguments 
are also required to be of a specific type, for instance the C<$parent> 
argument to the constructor B<must> be a B<Tree::Simple> object or an object 
derived from B<Tree::Simple>, otherwise an exception is thrown. This may seems 
harsh to some, but this allows me to have the confidence that my code works as 
I intend, and for you to enjoy the same level of confidence when using this 
module. Note however that this module does not use any Exception or Error module, 
the exceptions are just strings thrown with C<die>. 


=head1 CONSTANTS

=over 4

=item B<ROOT>

This class constant serves as a placeholder for the root of our tree. If a tree 
does not have a parent, then it is considered a root. 

=back

=head1 METHODS

=head2 Constructor

=over 4

=item B<new ($node, $parent)>

The constructor accepts two arguments a C<$node> value and an optional C<$parent>. 
The C<$node> value can be any scalar value (which includes references and objects). 
The optional C<$parent> value must be a B<Tree::Simple> object, or an object 
derived from B<Tree::Simple>. Setting this value implies that your new tree is a 
child of the parent tree, and therefore adds it to the parent's children. If the 
C<$parent> is not specified then its value defaults to ROOT.

=back

=head2 Mutator Methods

=over 4

=item B<setNodeValue ($node_value)>

This sets the node value to the scalar C<$node_value>, an exception is thrown if 
C<$node_value> is not defined.

=item B<setUID ($uid)>

This allows you to set your own unique ID for this specific Tree::Simple object. 
A default value derived from the object's hex address is provided for you, so use 
of this method is entirely optional. It is the responsibility of the user to 
ensure the value's uniqueness, all that is tested by this method is that C<$uid> 
is a true value (evaluates to true in a boolean context). For even more information 
about the Tree::Simple UID see the C<getUID> method.

=item B<addChild ($tree)>

This method accepts only B<Tree::Simple> objects or objects derived from 
B<Tree::Simple>, an exception is thrown otherwise. This method will append 
the given C<$tree> to the end of it's children list, and set up the correct 
parent-child relationships. This method is set up to return its invocant so 
that method call chaining can be possible. Such as:

  my $tree = Tree::Simple.new("root").addChild(Tree::Simple.new("child one"));

Or the more complex:

  my $tree = Tree::Simple.new("root").addChild(
                         Tree::Simple.new("1.0").addChild(
                                     Tree::Simple.new("1.0.1")     
                                     )
                         );

=item B<addChildren (@trees)>

This method accepts an array of B<Tree::Simple> objects, and adds them to 
it's children list. Like C<addChild> this method will return its invocant 
to allow for method call chaining.

=item B<insertChild ($index, $tree)>

This method accepts a numeric C<$index> and a B<Tree::Simple> object (C<$tree>), 
and inserts the C<$tree> into the children list at the specified C<$index>. 
This results in the shifting down of all children after the C<$index>. The 
C<$index> is checked to be sure it is the bounds of the child list, if it 
out of bounds an exception is thrown. The C<$tree> argument's type is 
verified to be a B<Tree::Simple> or B<Tree::Simple> derived object, if 
this condition fails, an exception is thrown. 

=item B<insertChildren ($index, @trees)>

This method functions much as insertChild does, but instead of inserting a 
single B<Tree::Simple>, it inserts an array of B<Tree::Simple> objects. It 
too bounds checks the value of C<$index> and type checks the objects in 
C<@trees> just as C<insertChild> does.

=item B<removeChild> ($child | $index)>

Accepts two different arguemnts. If given a B<Tree::Simple> object (C<$child>), 
this method finds that specific C<$child> by comparing it with all the other 
children until it finds a match. At which point the C<$child> is removed. If 
no match is found, and exception is thrown. If a non-B<Tree::Simple> object 
is given as the C<$child> argument, an exception is thrown. 

This method also accepts a numeric C<$index> and removes the child found at 
that index from it's list of children. The C<$index> is bounds checked, if 
this condition fail, an exception is thrown.

When a child is removed, it results in the shifting up of all children after 
it, and the removed child is returned. The removed child is properly 
disconnected from the tree and all its references to its old parent are 
removed. However, in order to properly clean up and circular references 
the removed child might have, it is advised to call it's C<DESTROY> method. 
See the L<CIRCULAR REFERENCES> section for more information.

=item B<addSibling ($tree)>

=item B<addSiblings (@trees)>

=item B<insertSibling ($index, $tree)>

=item B<insertSiblings ($index, @trees)>

The C<addSibling>, C<addSiblings>, C<insertSibling> and C<insertSiblings> 
methods pass along their arguments to the C<addChild>, C<addChildren>, 
C<insertChild> and C<insertChildren> methods of their parent object 
respectively. This eliminates the need to overload these methods in subclasses 
which may have specialized versions of the *Child(ren) methods. The one 
exceptions is that if an attempt it made to add or insert siblings to the 
B<ROOT> of the tree then an exception is thrown.

=back

B<NOTE:>
There is no C<removeSibling> method as I felt it was probably a bad idea. 
The same effect can be achieved by manual upwards traversal. 

=head2 Accessor Methods

=over 4

=item B<getNodeValue>

This returns the value stored in the object's node field.

=item B<getUID>

This returns the unique ID associated with this particular tree. This can 
be custom set using the C<setUID> method, or you can just use the default. 
The default is the hex-address extracted from the stringified Tree::Simple 
object. This may not be a I<universally> unique identifier, but it should 
be adequate for at least the current instance of your perl interpreter. If 
you need a UUID, one can be generated with an outside module (there are 
    many to choose from on CPAN) and the C<setUID> method (see above).

=item B<getChild ($index)>

This returns the child (a B<Tree::Simple> object) found at the specified 
C<$index>. Note that we do use standard zero-based array indexing.

=item B<getAllChildren>

This returns an array of all the children (all B<Tree::Simple> objects). 
It will return an array reference in scalar context. 

=item B<getSibling ($index)>

=item B<getAllSiblings>

Much like C<addSibling> and C<addSiblings>, these two methods simply call 
C<getChild> and C<getAllChildren> on the invocant's parent.

=item B<getDepth>

Returns a number representing the invocant's depth within the hierarchy of 
B<Tree::Simple> objects. 

B<NOTE:> A C<ROOT> tree has the depth of -1. This be because Tree::Simple 
assumes that a tree's root will usually not contain data, but just be an 
anchor for the data-containing branches. This may not be intuitive in all 
cases, so I mention it here.

=item B<getParent>

Returns the invocant's parent, which could be either B<ROOT> or a 
B<Tree::Simple> object.

=item B<getHeight>

Returns a number representing the length of the longest path from the current 
tree to the furthest leaf node.

=item B<getWidth>

Returns the a number representing the breadth of the current tree, basically 
it is a count of all the leaf nodes.

=item B<getChildCount>

Returns the number of children the invocant contains.

=item B<getIndex>

Returns the index of this tree within its parent's child list. Returns -1 if 
the tree is the root.

=back

=head2 Predicate Methods

=over 4

=item B<isLeaf>

Returns true (1) if the invocant does not have any children, false (0) otherwise.

=item B<isRoot>

Returns true (1) if the invocant's "parent" field is B<ROOT>, returns false 
(0) otherwise.

=back

=head2 Recursive Methods

=over 4

=item B<traverse ($func, ?$postfunc)>

This method accepts two arguments a mandatory C<$func> and an optional
C<$postfunc>. If the argument C<$func> is not defined then an exception
is thrown. If C<$func> or C<$postfunc> are not in fact CODE references
then an exception is thrown. The function C<$func> is then applied
recursively to all the children of the invocant. If given, the function
C<$postfunc> will be applied to each child after the child's children
have been traversed.

Here is an example of a traversal function that will print out the
hierarchy as a tabbed in list.

  $tree.traverse(sub {
      my ($_tree) = @_;
      print (("\t" x $_tree.getDepth()), $_tree.getNodeValue(), "\n");
  });

Here is an example of a traversal function that will print out the 
hierarchy in an XML-style format.

  $tree.traverse(sub {
      my ($_tree) = @_;
      print ((' ' x $_tree.getDepth()),
              '<', $_tree.getNodeValue(),'>',"\n");
  },
  sub {
      my ($_tree) = @_;
      print ((' ' x $_tree.getDepth()),
              '</', $_tree.getNodeValue(),'>',"\n");
  });
        
=item B<size>

Returns the total number of nodes in the current tree and all its sub-trees.

=item B<height>

This method has also been B<deprecated> in favor of the C<getHeight> method above, 
it remains as an alias to C<getHeight> for backwards compatability. 

B<NOTE:> This is also no longer a recursive method which get's it's value on demand, 
but a value stored in the Tree::Simple object itself, hopefully making it much 
more efficient and usable.

=back

=head2 Visitor Methods

=over 4     

=item B<accept ($visitor)>

It accepts either a B<Tree::Simple::Visitor> object (which includes classes derived 
    from B<Tree::Simple::Visitor>), or an object who has the C<visit> method available 
    (tested with C<$visitor-E<gt>can('visit')>). If these qualifications are not met, 
    and exception will be thrown. We then run the Visitor's C<visit> method giving the 
    current tree as its argument. 

I have also created a number of Visitor objects and packaged them into the 
B<Tree::Simple::VisitorFactory>. 

=back

=head2 Cloning Methods

Cloning a tree can be an extremly expensive operation for large trees, so we provide 
two options for cloning, a deep clone and a shallow clone.

When a Tree::Simple object is cloned, the node is deep-copied in the following manner. 
If we find a normal scalar value (non-reference), we simply copy it. If we find an 
object, we attempt to call C<clone> on it, otherwise we just copy the reference (since 
we assume the object does not want to be cloned). If we find a SCALAR, REF reference we 
copy the value contained within it. If we find a HASH or ARRAY reference we copy the 
reference and recursively copy all the elements within it (following these exact 
guidelines). We also do our best to assure that circular references are cloned 
only once and connections restored correctly. This cloning will not be able to copy 
CODE, RegExp and GLOB references, as they are pretty much impossible to clone. We 
also do not handle C<tied> objects, and they will simply be copied as plain 
references, and not re-C<tied>. 

=over 4

=item B<clone>

The clone method does a full deep-copy clone of the object, calling C<clone> recursively 
on all its children. This does not call C<clone> on the parent tree however. Doing 
this would result in a slowly degenerating spiral of recursive death, so it is not 
recommended and therefore not implemented. What happens is that the tree instance 
that C<clone> is actually called upon is detached from the tree, and becomes a root 
node, all if the cloned children are then attached as children of that tree. I personally 
think this is more intuitive then to have the cloning crawl back I<up> the tree is not 
what I think most people would expect. 

=item B<cloneShallow>

This method is an alternate option to the plain C<clone> method. This method allows the 
cloning of single B<Tree::Simple> object while retaining connections to the rest of the 
tree/hierarchy.

=back

=head2 Misc. Methods

=over 4

=item B<DESTROY>

To avoid memory leaks through uncleaned-up circular references, we implement the 
C<DESTROY> method. This method will attempt to call C<DESTROY> on each of its 
children (if it has any). This will result in a cascade of calls to C<DESTROY> on 
down the tree. It also cleans up it's parental relations as well. 

Because of perl's reference counting scheme and how that interacts with circular 
references, if you want an object to be properly reaped you should manually call 
C<DESTROY>. This is especially nessecary if your object has any children. See the 
section on L<CIRCULAR REFERENCES> for more information.

=item B<fixDepth>

Tree::Simple will manage your tree's depth field for you using this method. You 
should never need to call it on your own, however if you ever did need to, here 
is it. Running this method will traverse your all the invocant's sub-trees 
correcting the depth as it goes.

=item B<fixHeight>

Tree::Simple will manage your tree's height field for you using this method. 
You should never need to call it on your own, however if you ever did need to, 
here is it. Running this method will correct the heights of the current tree 
and all it's ancestors.

=item B<fixWidth>

Tree::Simple will manage your tree's width field for you using this method. You 
should never need to call it on your own, however if you ever did need to, 
here is it. Running this method will correct the widths of the current tree 
and all it's ancestors.

=back

=head2 Private Methods

I would not normally document private methods, but in case you need to subclass 
Tree::Simple, here they are.

=over 4

=item B<_init ($node, $parent, $children)>

This method is here largely to facilitate subclassing. This method is called by 
new to initialize the object, where new's primary responsibility is creating 
the instance.

=item B<!setParent ($parent)>

This method sets up the parental relationship. It is for internal use only.

=item B<_setHeight ($child)>

This method will set the height field based upon the height of the given C<$child>.

=back

=head1 CIRCULAR REFERENCES

I have revised the model by which Tree::Simple deals with ciruclar references. 
In the past all circular references had to be manually destroyed by calling 
DESTROY. The call to DESTROY would then call DESTROY on all the children, and 
therefore cascade down the tree. This however was not always what was needed, 
nor what made sense, so I have now revised the model to handle things in what 
I feel is a more consistent and sane way. 

Circular references are now managed with the simple idea that the parent makes 
the descisions for the child. This means that child-to-parent references are 
weak, while parent-to-child references are strong. So if a parent is destroyed 
it will force all it's children to detach from it, however, if a child is 
destroyed it will not be detached from it's parent.

=head2 Optional Weak References

By default, you are still required to call DESTROY in order for things to 
happen. However I have now added the option to use weak references, which 
alleviates the need for the manual call to DESTROY and allows Tree::Simple 
to manage this automatically. This is accomplished with a compile time 
setting like this:

  use Tree::Simple 'use_weak_refs';
  
And from that point on Tree::Simple will use weak references to allow for 
perl's reference counting to clean things up properly.

For those who are unfamilar with weak references, and how they affect the 
reference counts, here is a simple illustration. First is the normal model 
that Tree::Simple uses:
 
 +---------------+
 | Tree::Simple1 |<---------------------+
 +---------------+                      |
 | parent        |                      |
 | children      |-+                    |
 +---------------+ |                    |
                   |                    |
                   |  +---------------+ |
                   +.| Tree::Simple2 | |
                      +---------------+ |
                      | parent        |-+
                      | children      |
                      +---------------+
                      
Here, Tree::Simple1 has a reference count of 2 (one for the original 
variable it is assigned to, and one for the parent reference in 
Tree::Simple2), and Tree::Simple2 has a reference count of 1 (for the 
child reference in Tree::Simple2).                       
                     
Now, with weak references:
                     
 +---------------+
 | Tree::Simple1 |.......................
 +---------------+                      :
 | parent        |                      :
 | children      |-+                    : <--[ weak reference ]
 +---------------+ |                    :
                   |                    :
                   |  +---------------+ :
                   +.| Tree::Simple2 | :
                      +---------------+ :
                      | parent        |..
                      | children      |
                      +---------------+   
                      
Now Tree::Simple1 has a reference count of 1 (for the variable it is 
assigned to) and 1 weakened reference (for the parent reference in 
Tree::Simple2). And Tree::Simple2 has a reference count of 1, just 
as before.                                                            

=head1 BUGS

None that I am aware of. The code is pretty thoroughly tested (see 
L<CODE COVERAGE> below) and is based on an (non-publicly released) 
module which I had used in production systems for about 3 years without 
incident. Of course, if you find a bug, let me know, and I will be sure 
to fix it. 


=head1 SEE ALSO

I have written a number of other modules which use or augment this 
module, they are describes below and available on CPAN.

=over 4

=item L<Tree::Parser> - A module for parsing formatted files into Tree::Simple hierarchies.

=item L<Tree::Simple::View> - A set of classes for viewing Tree::Simple hierarchies in various output formats.

=item L<Tree::Simple::VisitorFactory> - A set of several useful Visitor objects for Tree::Simple objects.

=item L<Tree::Binary> - If you are looking for a binary tree, this you might want to check this one out.

=back

Also, the author of L<Data::TreeDumper> and I have worked together 
to make sure that B<Tree::Simple> and his module work well together. 
If you need a quick and handy way to dump out a Tree::Simple heirarchy, 
this module does an excellent job (and plenty more as well).

I have also recently stumbled upon some packaged distributions of 
Tree::Simple for the various Unix flavors. Here  are some links:

=over 4


=back

=head1 ACKNOWLEDGEMENTS

=over 4


=item Thanks to Nadim Ibn Hamouda El Khemir for making L<Data::TreeDumper> work 
with B<Tree::Simple>.

=item Thanks to Brett Nuske for his idea for the C<getUID> and C<setUID> methods.

=item Thanks to whomever submitted the memory leak bug to RT (#7512). 

=item Thanks to Mark Thomas for his insight into how to best handle the I<height> 
and I<width> properties without unessecary recursion.

=item Thanks for Mark Lawrence for the &traverse post-func patch, tests and docs.

=back

=head1 AUTHOR

Original Authors of Perl 5 version on CPAN
Stevan Little, E<lt>stevan@iinteractive.comE<gt>

Rob Kinyon, E<lt>rob@iinteractive.comE<gt>

Current Author
Philip mabon, E<lt>philipmabon@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2010 by Philip mabon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

=end pod
