use v6;

=NAME Path::Map - map paths to handlers

=begin SYNOPSIS

    my $mapper = Path::Map.new(
        '/x/y/z' => 'XYZ',
        '/a/b/c' => 'ABC',
        '/a/b'   => 'AB',

        '/date/:year/:month/:day' => 'Date',

        # Every path beginning with 'seo' is mapped the same.
        '/seo/*' => 'slurpy',
    );

    if my $match = $mapper.lookup('/date/2013/12/25') {
        # $match.handler is 'Date'
        # $match.variables is ( year => 2012, month => 12, day => 25 )
    }

    # Add more mappings later
    $mapper.add_handler(Str $path, Mu $target, :key(Callable $constraint), ...)

=end SYNOPSIS

=begin DESCRIPTION

This class maps (or "routes") paths to handlers. The paths can contain variable
path segments, which match against any incoming path segment, where the matching
segments are saved as named variables for later retrieval.  Simple validation
may be added to any named segment in the form of a C<Callable>.

Note that the handlers being mapped to can be any arbitrary data, not just
strings as illustrated in the synopsis.

This is a functional port of the Perl 5 module of the same name by Matt
Lawrence, see L<Path::Map|https://metacpan.org/pod/Path::Map>.

=head2 Implementation

Path::Map uses hash trees to do look-ups, with the goal of producing a fast
and lightweight routing implementation.  No performance testing has been
done on the Perl 6 version at this stage, however this should in theory mean
that performance does not degrade significantly when a large number of
branches are added to a router at the same depth, and that the order in which
routes are added will not need to consider the frequency of lookup for a
particular path.

=end DESCRIPTION

class Path::Map { ... }

# Match class for lookup results.
class Path::Map::Match does Callable {
  has Path::Map $.mapper is required; # The final mapper that produced this match
  has @.values; # Path segment values and leftover segments
  has %.variables; # Variables resolved by the lookup.

  method CALL-ME {
    $!mapper.target ~~ Callable or die 'handler is not Callable';
    $!mapper.target.(|%_, |%!variables);
  }

  # Returns the target handler
  method handler {
    $!mapper.target;
  }
}

# Regular expression for combing the path components out of a Str.
my $componentrx = /
  [ <?after '/'> | ^^ ] [ $<slurpy> = '*' | [ $<var> = ':' ]? $<path> = <-[/*]>+ ]
  /;

class Path::Map does Associative {
  # Hash providing storage of defined segments
  has %.map handles <keys values pairs kv>;

  # Array mapping resolvers & validators to path segments
  has @!resolv;
  has %!dyncache;

  # Cache holding variables modified by constraints.
  has %!vcache;

  has $.target is rw; #= Target / handler for this mapper.
  has $.key is rw; #= Key for named segments
  has Bool $.slurpy is rw = False; # Wildcard "slurpy" marker.

=head1 METHODS

  #| The constructor.  Takes a list of pairs and adds each via L<#add_handler>.
  #|   Pairs may be of the form C«$path => $handler» or
  #|   C«$path => ($handler, *%constraints)»
  method new(Path::Map:U: *@maps) {
    my $obj := Path::Map.bless;
    @maps and do for @maps {
      when Pair {
	if .value ~~ List {
	  $obj.add_handler(.key, .value[0], |%(.value[1..*]));
	} else {
	  $obj.add_handler(.key, .value);
	}
      }
    }

    $obj;
  }

  #| Adds a single item to the mapping.
  method add_handler(Path::Map:D: Str $path, $handler, *%constraints) {
    my @vars;
    my Bool $slurpy = False;

    my Path::Map $mapper = self;

    for $path.comb($componentrx, :match).list -> $/ {
      if $slurpy || ($<slurpy>:exists) {
        $slurpy = True;
        last;
      }
      my $p = $<path>.Str;
      if $<var>:exists {
        push @vars, $p;
        $p = ($/.Str => %constraints{$<path>} // { True });
      }
      $mapper{$p} = Path::Map.new unless $mapper{$p}:exists;
      $mapper{$p}.key = $<path>.Str if $<var>:exists;
      $mapper = $mapper{$p};
    }

    $mapper.target = $handler;
    $mapper.slurpy = $slurpy;
  }

=begin pod

The path template should be a string comprising slash-delimited path segments,
where a path segment may contain any character other than the slash. Any
segment beginning with a colon (C<:>) denotes a mandatory named variable.
Empty segments, including those implied by leading or trailing slashes are
ignored.

For example, these are all identical path templates:

    /a/:var/b
    a/:var/b/
    //a//:var//b//

The order in which templates are added will affect the lookup only when a named
segment has differing keys, Thus:

    $map.add_handler('foo/:foo/bar', 'A');
    $map.add_handler('foo/:foo/baz', 'B');

produces the same tree as:

    $map.add_handler('foo/:foo/baz', 'B');
    $map.add_handler('foo/:foo/bar', 'A');

however:

    $map.add_handler('foo/:bar/baz', 'A');
    $map.add_handler('foo/:ban/baz', 'B');

will always resolve C<'foo/*/baz'> to C<'A'>, and:

    $map.add_handler('foo/:ban/baz', 'B');
    $map.add_handler('foo/:bar/baz', 'A');

will always resolve C<'foo/*/baz'>; to C<'B'>.

Templates containing a segment consisting entirely of C<'*'> match instantly
at that point, with all remaining segments assigned to the C<values> of the
match as normal, but without any variable names. Any remaining segments in the
template are ignored, so it only makes sense for the wildcard to be the last
segment.

    my $map = Path::Map.new('foo/:foo/*', 'Something');
    my match = $map.lookup('foo/bar/baz/qux');
    $match.variables; # (foo => 'bar')
    $match.values; # (bar baz qux)

Additional named arguments passed to C<add_handler> validate the named variables
in the path specification with the corresponding key using a C<Callable>; this
will be called with the value of the segment as the only argument, and should
return a C<True> or C<False> response.  No exception handling is performed by
the C<lookup> method, so any Exceptions or Failures are liable to prevent
further look-ups on alternative paths. Multiple constraints for the same segment
may be used with different constraints, provided each handler uses a different
key.

    $map.add_handler('foo/:bar', 'Something even', :bar({ try { +$_ %% 2 } }));
    $map.add_handler('foo/:baz', 'Something odd', :baz({ try { 1 + $_ %% 2 } }));
    $match = $map.lookup('foo/42'); # succeeds first validation; .handler eq 'Something even';
    $match = $map.lookup('foo/21'); # succeeds second validation; .handler eq 'Something odd';
    $match = $map.lookup('foo/seven'); # fails all validation; returns Nil;

Validation blocks can specify their (single) argument as rw to allow the mapped
value to be transformed during validation:

    $map.add_handler('foo/:bar', 'Transform!', :bar(-> $bar is rw { try { $bar = Int($bar) } }));
    $map.lookup('foo/42').variables<bar>; # Int
    $map.lookup('foo/qux'); # Does not validate; Nil

=end pod

  # Looks up a path by array of segments
  multi method lookup(Path::Map:D $mapper:
                      @components is copy,
                      %variables  is copy = {},
                      @values     is copy = [],
                      $value?) {
    # Add value to segment variables and values if component is a named key
    if $!key {
      %variables{$!key} = $value;
      @values.push($value);
    }

    # Descend into segment
    if @components {
      my $c = @components[0];

      # Resolve and loop through child segment mappers.
      if $mapper{$c}:exists {
        for @($mapper{$c}).map: -> $map {
          start {
            # Lookup by stripping out the zeroeth component & return the first successful match.
            $map.lookup(@components[1..*], %variables, @values, %!vcache{$map}{$c});
          }
        } -> $promise {
          my $result = await $promise and return $result;
        }
      } else {
        # Only allow continuations for slurpy matches.
        return Nil unless $!slurpy;
      }
    }

    # No target means no match.
    return Nil unless $!target;

    # Slurp the remaining components into values
    @values.push(|@components) if @components;

    # Successful match!
    Path::Map::Match.new(:$mapper, :%variables, :@values);
  }

  #| Returns a C<Path::Map::Match> object if the path matches a known template.
  multi method lookup(Str $path) {
    self.lookup($path.comb(/<-[/]>+/).Array);
  }

=begin pod

Calling a C<Path::Map> object directly is equivalent to calling its lookup method.

The two main methods on the C<Path::Map::Match> object are:

=item handler

    The handler that was matched, identical to whatever was originally passed to
    L<#add_handler>.

=item variables

    The named path variables as a C<Hash>.

The C<mapper> that matched the path and associated C<values> are also accessible
as methods of the C<Path::Map::Match> object.

For convenience, You can call a C<Path::Map::Match> object directly if its
C<handler> implements the C<Callable> role - in which case the matched
C<variables> will be passed to the handler.

=end pod

  #| Returns all of the handlers in no particular order.
  method handlers {
    (self.target, %!map.values.map: { .handlers }).grep({ defined $_ }).flat.unique;
  }

  # Resolves and Validates named keys.
  method !dynamic($key) {
    @!resolv.grep( -> $p {
      %!dyncache{$p.WHERE}{$key} //= ($p.value.(%!vcache{%!map{$p.gist}}{$key} = $key) || False);
    })».gist;
  }

  # Associative callbacks.

  multi method EXISTS-KEY(Pair $key) {
    %!map{$key.gist}:exists;
  }

  multi method EXISTS-KEY($key) {
    quietly { %!map{$key | self!dynamic($key).any }:exists }
  }

  multi method AT-KEY(Path::Map:D: Pair $key) {
    %!map{$key.gist};
  }

  method CALL-ME(Str $path) {
    self.lookup($path);
  }

  multi method AT-KEY(Path::Map:D: $key) {
    %!map{$key} // %!map{self!dynamic($key)} || Nil;
  }

  multi method ASSIGN-KEY(Pair $key, $new) {
    @!resolv.push: $key;
    %!map{$key.gist} = $new;
  }

  multi method ASSIGN-KEY($key, $new) {
    %!map{$key} = $new;
  }

  multi method BIND-KEY(Pair $key, \new) {
    @!resolv.push: $key;
    %!map{$key.gist} := new;
  }

  multi method BIND-KEY($key, \new) {
    %!map{$key} := new;
  }

  multi method DELETE-KEY(Path::Map:D: $key) {
    %!map{$key}:delete;
  }

  my Path::Map %pool;

  # Associative lookup on Path::Map class returns a mapper from the pool
  multi method AT-KEY(Path::Map:U: $key) {
    %pool{$key};
  }

  # Trait mod for allowing code definitions with is Path::Map(:type<path/to/map>)
  multi trait_mod:<is> (Code:D $handler, Path::Map, Pair $binding where .key & .value ~~ Str) is export(:traits) {
    my %constraints = $handler.signature.params.grep({ so .named }).map: -> $param {
      # Strip the sigil.
      $param.name.substr(1) => -> $var is rw {
	try {
	  $var = $param.type.($var) unless (Any ~~ $param.type);
	  $var ~~ $param.constraints
	}
      }
    };

    (%pool{$binding.key} //= Path::Map.new()).add_handler($binding.value, $handler, |%constraints);
  }

=begin pod

=head1 TRAITS

When C<use>ing Path::Map with :traits you may specify a C<Code> block as
C<is Path::Map(:type<path/to/map>)> and it will be stored as a mapping in the
C<Path::Map> namespace.  This will try to use the type constraints from any
parameter definitions:

=begin code

    use Path::Map :traits;

    sub handle_things(Int :$baz) is Path::Map(:foo<bar/:baz>) { ... };

    ...

    use Path::Map;

    Path::Map<foo>.lookup('bar/100').handler; # handle_things
    Path::Map<foo>.lookup('bar/qux').handler; # Nil

=end code

=end pod

}

=begin pod

=head1 SEE ALSO

L<Path::Router>, L<Path::Map|https://metacpan.org/pod/Path::Map> for Perl 5

=head1 AUTHOR

L<Francis Whittle|mailto:fj.whittle@gmail.com>

=head1 KUDOS

Matt Lawrence - author of Perl 5 L<Path::Map|https://metacpan.org/pod/Path::Map>
module.  Please do not contact Matt with issues with the Perl 6 module.

=head1 COPYRIGHT

This library is free software; you can redistribute it and/or modify it under
the terms of the
L<Artistic License 2.0|http://www.perlfoundation.org/artistic_license_2_0>

=end pod
