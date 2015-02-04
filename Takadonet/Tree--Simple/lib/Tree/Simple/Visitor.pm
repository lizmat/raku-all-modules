class Tree::Simple::Visitor{
use Tree::Simple;

# class constants
our $RECURSIVE     = 'RECURSIVE';
our $CHILDREN_ONLY = 'CHILDREN_ONLY';

#RECURSIVE CHILDREN_ONLY
subset DEPTH of Mu where { $_ eq 'RECURSIVE' || $_ eq 'CHILDREN_ONLY'};

has $.depth is rw ;
    
has Code $.filter_fcn is rw;
has Bool $.include_trunk is rw = Bool::False;
has @.results is rw;

### constructors
multi method new(){
	self.bless(*, depth => 'RECURSIVE');
}

multi method new(Code $func) {
	self.bless(*, depth => 'RECURSIVE',filter_fcn => $func, include_trunk=>Bool::True);
}

#check to see if $depth  is RECURSIVE or CHILDREN_ONLY
multi method new(Code $func,$depth) {
        die 'Not legal value for depth.' if $depth ne $Tree::Simple::Visitor::RECURSIVE and $depth ne $Tree::Simple::Visitor::CHILDREN_ONLY;
	self.bless(*, depth => $depth,filter_fcn => $func, include_trunk=>Bool::True);
}

### methods

#if given Mu, don't die but do nothing. Do not believe it should set to Bool::True
multi method includeTrunk(Mu){ };

multi method includeTrunk(''){
	self.include_trunk = Bool::False;
}

multi method includeTrunk() {
    return self.include_trunk;
}

multi method includeTrunk(Bool $trunk) {
    self.include_trunk = $trunk;
}
#if given Mu, don't die but do nothing. Do not believe it should set to Bool::True
# node filter methods

method getNodeFilter() {
 	return self.filter_fcn; 
}

method clearNodeFilter() {
    self.filter_fcn = Mu;     
}

method setNodeFilter(Code $filter_fcn) {
 	self.filter_fcn = $filter_fcn; 
}

# resultscn methods 

method setResults(@results) {
    @.results= @results;
}

method getResults() {
    return @.results;
}

# visit routine
method visit(Tree::Simple $tree) {
    # get all things set up
    my @results;
    my $func;
    
    if self.filter_fcn {
        $func = sub ($a) { push @results , self.filter_fcn.($a) };    
    }
    else {
        $func = sub ($a) { push @results , $a.getNodeValue() }; 
    }
    # always apply the function 
    # to the tree's node
    $func.($tree) if self.include_trunk;
    # then recursively to all its children
    # if the object is configured that way
    $tree.traverse($func) if self.depth eq 'RECURSIVE';
    # or just visit its immediate children
    # if the object is configured that way
    if self.depth eq 'CHILDREN_ONLY' {
        for $tree.getAllChildren() -> $x {
            $func.($x);
        }
    }
    # now store the results we got
    self.results = @results;
}

}

=begin pod
    
=head1 NAME

Tree::Simple::Visitor - Visitor object for Tree::Simple objects

=head1 SYNOPSIS

  use Tree::Simple;
  use Tree::Simple::Visitor;
  
  # create a visitor instance
  my $visitor = Tree::Simple::Visitor.new();  							 
  
  # create a tree to visit
  my $tree = Tree::Simple.new($Tree::Simple::ROOT)
                         .addChildren(
                             Tree::Simple.new("1.0"),
                             Tree::Simple.new("2.0")
                                         .addChild(
                                             Tree::Simple.new("2.1.0")
                                             ),
                             Tree::Simple.new("3.0")
                             );

  # by default this will collect all the 
  # node values in depth-first order into 
  # our results 
  $tree.accept($visitor);	  
  
  # get our results and print them
  print join ", ", $visitor.getResults();  # prints "1.0, 2.0, 2.1.0, 3.0" 
  
  # for more complex node objects, you can specify 
  # a node filter which will be used to extract the
  # information desired from each node
  $visitor.setNodeFilter(sub { 
                my ($t) = @_;
                return $t.getNodeValue().description();
                });  
                  

=head1 DESCRIPTION

This object has been revised into what I think is more intelligent approach to Visitor objects. This is now a more suitable base class for building your own Visitors. It is also the base class for the visitors found in the B<Tree::Simple::VisitorFactory> distribution, which includes a number of useful pre-built Visitors.

  my $visitor = Tree::Simple::Visitor.new();  							 
  $tree.accept($visitor);	  
  print join ", ", $visitor.getResults();  # prints "1.0, 2.0, 2.1.0, 3.0"  

This object is still pretty much a wrapper around the Tree::Simple C<traverse> method, and can be thought of as a depth-first traversal Visitor object.  

=head1 METHODS

=over 4

=item B<new ($func, $depth)>

The new style interface means that all arguments to the constructor are now optional. As a means of defining the usage of the old and new, when no arguments are sent to the constructor, it is assumed that the new style interface is being used. In the new style, the C<$depth> is always assumed to be equivalent to C<RECURSIVE> and the C<$func> argument can be set with C<setNodeFilter> instead. This is the recommended way of doing things now. If you have been using the old way, it is still there, and I will maintain backwards compatability for a few more version before removing it entirely. If you are using this module (and I don't even know if anyone actually is) you have been warned. Please contact me if this will be a problem.

The old style constructor documentation is retained her for reference:

The first argument to the constructor is a code reference to a function which expects a B<Tree::Simple> object as its only argument. The second argument is optional, it can be used to set the depth to which the function is applied. If no depth is set, the function is applied to the current B<Tree::Simple> instance. If C<$depth> is set to C<CHILDREN_ONLY>, then the function will be applied to the current B<Tree::Simple> instance and all its immediate children. If C<$depth> is set to C<RECURSIVE>, then the function will be applied to the current B<Tree::Simple> instance and all its immediate children, and all of their children recursively on down the tree. If no C<$depth> is passed to the constructor, then the function will only be applied to the current B<Tree::Simple> object and none of its children.

=item B<includeTrunk ($boolean)>

Based upon the value of C<$boolean>, this will tell the visitor to collect the trunk of the tree as well. It is defaulted to false (C<0>) in the new style interface, but is defaulted to true (C<1>) in the old style interface.

=item B<getNodeFilter>

This method returns the CODE reference set with C<setNodeFilter> argument.

=item B<clearNodeFilter>

This method clears node filter field.

=item B<setNodeFilter ($filter_function)>

This method accepts a CODE reference as its C<$filter_function> argument. This code reference is used to filter the tree nodes as they are collected. This can be used to customize output, or to gather specific information from a more complex tree node. The filter function should accept a single argument, which is the current Tree::Simple object.

=item B<getResults>

This method returns the accumulated results of the application of the node filter to the tree.

=item B<setResults>

This method should not really be used outside of this class, as it just would not make any sense to. It is included in this class and in this documenation to facilitate subclassing of this class for your own needs. If you desire to clear the results, then you can simply call C<setResults> with no argument.

=item B<visit ($tree)>

The C<visit> method accepts a B<Tree::Simple> and applies the function set in C<new> or C<setNodeFilter> appropriately. The results of this application can be retrieved with C<getResults>

=back

=head1 CONSTANTS

These constants are part of the old-style interface, and therefore will eventually be deprecated.

=over 4

=item B<RECURSIVE>

If passed this constant in the constructor, the function will be applied recursively down the hierarchy of B<Tree::Simple> objects. 

=item B<CHILDREN_ONLY>

If passed this constant in the constructor, the function will be applied to the immediate children of the B<Tree::Simple> object. 

=back

=head1 BUGS

None that I am aware of. The code is pretty thoroughly tested (see B<CODE COVERAGE> section in B<Tree::Simple>) and is based on an (non-publicly released) module which I had used in production systems for about 2 years without incident. Of course, if you find a bug, let me know, and I will be sure to fix it. 

=head1 SEE ALSO

I have written a set of pre-built Visitor objects, available on CPAN as B<Tree::Simple::VisitorFactory>.

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
