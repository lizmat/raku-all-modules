use v6.c;

class List::MoreUtils:ver<0.0.2>:auth<cpan:ELIZABETH> {
    our sub any(&code, @values --> Bool:D) is export(:all) {
        return True if code($_) for @values;
        False
    }
    our sub any_u(&code, @values --> Bool:D) is export(:all) {
        @values ?? any(&code,@values) !! Nil
    }

    our sub all(&code, @values --> Bool:D) is export(:all) {
        return False unless code($_) for @values;
        True
    }
    our sub all_u(&code, @values --> Bool:D) is export(:all) {
        @values ?? all(&code,@values) !! Nil
    }

    our sub none(&code, @values --> Bool:D) is export(:all) {
        return False if code($_) for @values;
        True
    }
    our sub none_u(&code, @values --> Bool:D) is export(:all) {
        @values ?? none(&code,@values) !! Nil
    }

    our sub notall(&code, @values --> Bool:D) is export(:all) {
        return True unless code($_) for @values;
        False
    }
    our sub notall_u(&code, @values --> Bool:D) is export(:all) {
        @values ?? notall(&code,@values) !! Nil
    }

    our sub one(&code, @values --> Bool:D) is export(:all) {
        my Int $seen = 0;
        return False if code($_) && $seen++ for @values;
        so $seen
    }
    our sub one_u(&code, @values --> Bool:D) is export(:all) {
        @values ?? one(&code,@values) !! Nil
    }

    our sub apply(&code, @values, :$scalar) is export(:all) {
        $scalar
          ?? @values.map( -> $_ is copy { code($_); $_ } ).tail
          !! @values.map( -> $_ is copy { code($_); $_ } ).List
    }

    our proto sub insert_after(|) is export(:all) {*}
    multi sub insert_after(&code, \insertee, @values --> Nil) {
        for @values.kv -> $key, $value {
            if code($value) {
                @values.splice($key + 1, 0, insertee);
                return
            }
        }
    }
    multi sub insert_after(&code, Pair:D $pair) {
        insert_after(&code, $pair.key, $pair.value)
    }
    multi sub insert_after(&code, *%_ --> Nil) {
        %_.elems > 1
          ?? die "Can only specify one named parameter to 'insert_after'"
          !! insert_after(&code, .key, .value) with %_.head
    }

    our proto sub insert_after_string(|) is export(:all) {*}
    multi sub insert_after_string(Str() $string, \insertee, @values --> Nil) {
        for @values.kv -> $key, $value {
            if $value.defined && $value eq $string {
                @values.splice($key + 1, 0, insertee);
                return
            }
        }
    }
    multi sub insert_after_string(Str() $string, Pair:D $pair) {
        insert_after_string($string, $pair.key, $pair.value)
    }
    multi sub insert_after_string(Str() $string , *%_ --> Nil) {
        %_.elems > 1
          ?? die "Can only specify one named parameter to 'insert_after_string'"
          !! insert_after_string($string, .key, .value) with %_.head
    }

    our sub pairwise(&code, @a, @b) is export(:all) {
        my $elems = @a.elems max @b.elems;
        my @pairwise;
        @pairwise.append(code(@a.AT-POS($_), @b.AT-POS($_)).Slip) for ^$elems;
        @pairwise
    }

    our sub mesh(**@arrays, :$DONTSLIP) is export(:all) {
        my @iterators = @arrays.map: *.iterator;
        my $nr_values = +@iterators;
        my @mesh;

        loop {
            my $seen = $nr_values;
            my @values = @iterators.map: {
                my $pulled := .pull-one;
                if $pulled =:= IterationEnd {
                    --$seen;
                    Nil
                }
                else {
                    $pulled
                }
            }
            last unless $seen;
            @mesh.append( $DONTSLIP ?? @values !! @values.Slip )
        }
        @mesh
    }
    our constant &zip is export(:all) = &mesh;

    our sub zip6(|c) is export(:all) { mesh(|c, :DONTSLIP) }
    our constant &zip_unflatten is export(:all) = &zip6;

    our sub listcmp(**@arrays --> Hash:D) is export(:all) {
        my %result;
        for @arrays.kv -> $index, @array {
            my %seen;
            for @array -> \value {
                if value.defined {
                    with %result{value} {
                        .push($index) unless %seen{value}++;
                    }
                    else {
                        %result.BIND-KEY(value,[$index]);
                    }
                }
            }
        }
        %result
    }

    our sub arrayify(**@values) is export(:all) {
        my @arrayify;
        multi sub flatten(@values) { flatten($_) for @values }
        multi sub flatten(\value)  { @arrayify.push(value) }

        flatten($_) for @values;
        @arrayify
    }

    our sub uniq(@values, :$scalar) is export(:all) {
        my %seen;
        my @uniq;

        @uniq.push($_) unless %seen{.defined ?? .Str !! .^name}++ for @values;
        $scalar ?? +@uniq !! @uniq
    }
    our constant &distinct is export(:all) = &uniq;

    our sub singleton(@values is copy, :$scalar) is export(:all) {
        my %once;
        my %duplicates;

        for @values.kv -> $index, $_ {
            my $key = .defined ?? .Str !! .^name;
            if %duplicates{$key} {
                @values[$index]:delete;
            }
            elsif %once{$key}:exists {
                @values[%once{$key}:delete]:delete;
                @values[$index]:delete;
                %duplicates{$key} = 1;
            }
            else {
                %once{$key} = $index
            }
        }

        $scalar
          ?? (@values[]:v).elems
          !! (@values[]:v).List
    }

    our sub duplicates(@values, :$scalar) is export(:all) {
        my %seen;
        my @duplicates;

        @duplicates.push($_) if %seen{.defined ?? .Str !! .^name}++ == 1
          for @values;
        $scalar ?? +@duplicates !! @duplicates
    }

    our sub frequency(@values, :$scalar) is export(:all) {
        my %seen;
        %seen{.defined ?? .Str !! .^name}++ for @values;
        $scalar ?? %seen.elems !! %seen.kv.List
    }

    our sub occurrences(@values, :$scalar) is export(:all) {
        my $seen = @values.Bag;
        my @occurrences;
        @occurrences[.value].push(.key) for $seen.pairs;
        $scalar ?? +@occurrences !! @occurrences
    }

    our sub mode(@values, :$scalar) is export(:all) {
        my $seen = @values.Bag;
        my $max = $seen.values.max;

        if $scalar {
            $max
        }
        else {
            my @mode = $seen.map: { .key if .value == $max };
            @mode.unshift($max)
        }
    }

    our sub after(&code, @values) is export(:all) {
        my $found = False;
        @values.toggle( { $found || code($_) && $found++ }, :off ).List
    }

    our sub after_incl(&code, @values) is export(:all) {
        @values.toggle( &code, :off ).List
    }

    our sub before(&code, @values) is export(:all) {
        @values.toggle( { !code($_) } ).List
    }

    our sub before_incl(&code, @values) is export(:all) {
        my $looking = True;
        @values.toggle( { $looking && !code($_) || $looking-- } ).List
    }

    our sub part(&code, @values) is export(:all) {
        my Array @part;
        for @values {
            my $index = code($_);
            @part[ $index < 0 ?? @part + $index !! $index].push($_)
        }
        @part
    }

    our sub samples(Int() $count, @values) is export(:all) {
        @values.pick($count).List
    }

    our sub natatime($n, @values) is export(:all) {
        my $iterator := @values.rotor($n, :partial).iterator;
        return {
            (my $pulled := $iterator.pull-one) =:= IterationEnd
              ?? ()
              !! $pulled
        }
    }

    our sub firstval(&code, @values) is export(:all) {
        @values.first: &code
    }
    our constant &first_value is export(:all) = &firstval;

    our sub onlyval(&code, @values) is export(:all) {
        my $iterator := @values.grep(&code).iterator;
        my $onlyval := $iterator.pull-one;
        $onlyval =:= IterationEnd
          ?? Nil
          !! $iterator.pull-one =:= IterationEnd
            ?? $onlyval
            !! Nil
    }
    our constant &only_value is export(:all) = &onlyval;

    our sub lastval(&code, @values) is export(:all) {
        @values.first(&code, :end)
    }
    our constant &last_value is export(:all) = &lastval;

    our sub firstres(&code, @values) is export(:all) {
        my $firstres :=
          @values.map({ if code($_) -> \val { val } }).iterator.pull-one;
        $firstres =:= IterationEnd ?? Nil !! $firstres
    }
    our constant &first_result is export(:all) = &firstres;

    our sub onlyres(&code, @values) is export(:all) {
        my $iterator := @values.map({ if code($_) -> \val { val } }).iterator;
        my $onlyres := $iterator.pull-one;

        $onlyres =:= IterationEnd
          ?? Nil
          !! $iterator.pull-one =:= IterationEnd
            ?? $onlyres
            !! Nil
    }
    our constant &only_result is export(:all) = &onlyres;

    our sub lastres(&code, @values) is export(:all) {
        @values.map({ if code($_) -> \val { val } }).tail
    }
    our constant &last_result is export(:all) = &lastres;

    our sub indexes(&code, @values) is export(:all) {
        @values.grep( &code, :k ).List
    }

    our sub firstidx(&code, @values) is export(:all) {
        @values.first( &code, :k ) // -1
    }
    our constant &first_index is export(:all) = &firstidx;

    our sub onlyidx(&code, @values) is export(:all) {
        my $iterator := @values.grep( &code, :k ).iterator;
        my $onlyidx := $iterator.pull-one;
        $onlyidx =:= IterationEnd
          ?? -1
          !! $iterator.pull-one =:= IterationEnd
            ?? $onlyidx
            !! -1
    }
    our constant &only_index is export(:all) = &onlyidx;

    our sub lastidx(&code, @values) is export(:all) {
        @values.first( &code, :k, :end ) // -1
    }
    our constant &last_index is export(:all) = &lastidx;

    our sub sort_by(&code, @values) is export(:all) {
        @values.sort( { ~code($_) } ).List
    }

    our sub nsort_by(&code, @values) is export(:all) {
        @values.sort( { +code($_) } ).List
    }

    our sub qsort(&code, @values) is export(:all) {
        @values .= sort( &code ).List
    }

    our sub true(&code, @values) is export(:all) {
        my $true = 0;
        ++$true if code($_) for @values;
        $true
    }

    our sub false(&code, @values) is export(:all) {
        my $false = 0;
        ++$false unless code($_) for @values;
        $false
    }

    our sub each_array(**@arrays) is export(:all) {
        each_arrayref(@arrays)
    }

    our sub each_arrayref(@arrays) is export(:all) {
        my $elems = @arrays>>.elems.max;
        my $index = -1;

        return {
            if $_ && $_ eq "index" {
                $index
            }
            elsif ++$index < $elems {
                @arrays.map( { $_[$index] } ).List
            }
            else {
                ()
            }
        }
    }

    our sub minmax(@values) is export(:all) {
        @values
          ?? ((.min,.max) with @values.minmax)
          !! ()
    }
    our constant &minmaxstr is export(:all) = &minmax;

    sub REDUCE($result is copy, &code, @values) {
        $result = code($result,$_) for @values;
        $result
    }
    our sub reduce_0(&code,@values) is export(:all) {
        REDUCE( 0, &code, @values )
    }
    our sub reduce_1(&code,@values) is export(:all) {
        REDUCE( 1, &code, @values )
    }
    our sub reduce_u(&code,@values) is export(:all) {
        REDUCE( Any, &code, @values )
    }

    our sub bsearch(&code,@values,:$index,:$scalar) is export(:all) {
        my $elems = +@values;
        my $i = 0;
        my $j = $elems;

        until $i > $j {
            my $k = ($i + $j) div 2;
            if $k >= $elems {
                return $index
                  ?? -1
                  !! $scalar ?? False !! []
            }

            if code(@values[$k]) -> $rc {
                $rc < 0
                  ?? ($i = $k + 1)
                  !! ($j = $k - 1)
            }
            else {
                return $index
                  ?? $k
                  !! $scalar ?? True !! [@values[$k]]
            }
        }
        $index
          ?? -1
          !! $scalar ?? False !! []
    }
    our sub bsearchidx(&code,@values,:$scalar) is export(:all) {
        bsearch(&code,@values,:$scalar,:index)
    }
    our constant &bsearch_index is export(:all) = &bsearchidx;

    our sub lower_bound(&code,@values) is export(:all) {
        my $count = +@values;
        my $lower = 0;

        while $count > 0 {
            my $step = $count +> 1;

            if code(@values[$lower + $step]) < 0 {
                $lower += $step + 1;
                $count -= $step + 1;
            }
            else {
                $count = $step;
            }
        }
        $lower
    }

    our sub upper_bound(&code,@values) is export(:all) {
        my $count = +@values;
        my $upper = 0;

        while $count > 0 {
            my $step = $count +> 1;

            if code(@values[$upper + $step]) <= 0 {
                $upper += $step + 1;
                $count -= $step + 1;
            }
            else {
                $count = $step;
            }
        }
        $upper
    }

    our sub equal_range(&code,@values) is export(:all) {
        ( lower_bound(&code,@values), upper_bound(&code,@values) )
    }

    our sub binsert(&code,\item,@values) is export(:all) {
        my $lb = lower_bound(&code,@values);
        @values.splice($lb, 0, item);
        $lb
    }
    our constant &bsearch_insert is export(:all) = &binsert;

    our sub bremove(&code,@values) is export(:all) {
        my $lb = lower_bound(&code,@values);
        $lb == @values ?? Nil !! @values.splice($lb, 1)
    }
    our constant &bsearch_remove is export(:all) = &bremove;
}

sub EXPORT(*@args, *%_) {

    if @args {
        my $imports := Map.new( |(EXPORT::all::{ @args.map: '&' ~ * }:p) );
        if $imports != @args {
            die "List::MoreUtils doesn't know how to export: "
              ~ @args.grep( { !$imports{$_} } ).join(', ')
        }
        $imports
    }
    else {
        Map.new
    }
}

=begin pod

=head1 NAME

List::MoreUtils - Port of Perl 5's List::MoreUtils 0.428

=head1 SYNOPSIS

    # import specific functions
    use List::MoreUtils <any uniq>;

    if any { /foo/ }, uniq @has_duplicates {
        # do stuff
    }

    # import everything
    use List::MoreUtils ':all';

=head1 DESCRIPTION

List::MoreUtils provides some trivial but commonly needed functionality on
lists which is not going to go into C<List::Util>.

=head1 EXPORTS

Nothing by default. To import all of this module's symbols use the C<:all>
tag. Otherwise functions can be imported by name as usual:

    use List::MoreUtils :all;

    use List::MoreUtils <any firstidx>;

=head1 Porting Caveats

Perl 6 does not have the concept of C<scalar> and C<list> context.  Usually,
the effect of a scalar context can be achieved by prefixing C<+> to the
result, which would effectively return the number of elements in the result,
which usually is the same as the scalar context of Perl 5 of these functions.

Perl 6 does not have a magic C<$a> and C<$b>.  But they can be made to exist
by specifying the correct signature to blocks, specifically "-> $a, $b".
These have been used in all examples that needed them.  Just using the
signature auto-generating C<$^a> and C<$^b> would be more Perl 6 like.  But
since we want to keep the documentation as close to the original as possible,
it was decided to specifically specify the "-> $a, $b" signatures.

Many functions take a C<&code> parameter of a C<Block> to be called by the
function.  Many of these assume B<$_> will be set.  In Perl 6, this happens
automagically if you create a block without a definite or implicit signature:

  say { $_ == 4 }.signature;   # (;; $_? is raw)

which indicates the Block takes an optional parameter that will be aliased
as C<$_> inside the Block.

Perl 6 also doesn't have a single C<undef> value, but instead has
C<Type Objects>, which could be considered undef values, but with a type
annotation.  In this module, C<Nil> (a special value denoting the absence
of a value where there should have been one) is used instead of C<undef>.

Also note there are no special parsing rules with regards to blocks in Perl 6.
So a comma is B<always> required after having specified a block.

The following functions are actually built-ins in Perl 6.

  any all none minmax uniq zip

They mostly provide the same or similar semantics, but there may be subtle
differences, so it was decided to not just use the built-ins.  If these
functions are imported from this library in a scope, they will used instead
of the Perl 6 builtins.  The easiest way to use both the functions of this
library and the Perl 6 builtins in the same scope, is to use the method syntax
for the Perl 6 versions.

    my @a = 42,5,2,98792,88;
    {  # Note: imports in Perl 6 are always lexically scoped
        use List::Util <minmax>;
        say minmax @a;  # Ported Perl 5 version
        say @a.minmax;  # Perl 6 version
    }
    say minmax @a;  # Perl 6 version again

Many functions returns either C<True> or C<False>.  These are C<Bool>ean
objects in Perl 6, rather than just C<0> or C<1>.  However, if you use
a Boolean value in a numeric context, they are silently coerced to 0 and 1.
So you can still use them in numeric calculations as if they are 0 and 1.

Some functions return something different in scalar context than in list
context.  Perl 6 doesn't have those concepts.  Functions that are supposed
to return something different in scalar context also accept a C<:scalar>
named parameter to indicate a scalar context result is required.  This will
be noted with the function in question if that feature is available.

=head1 FUNCTIONS

=head2 Junctions

=head3 I<Treatment of an empty list>

There are two schools of thought for how to evaluate a junction on an
empty list:

=item Reduction to an identity (boolean)

=item Result is undefined (three-valued)

In the first case, the result of the junction applied to the empty list is
determined by a mathematical reduction to an identity depending on whether
the underlying comparison is "or" or "and".  Conceptually:

                    "any are true"      "all are true"
                    --------------      --------------
    2 elements:     A || B || 0         A && B && 1
    1 element:      A || 0              A && 1
    0 elements:     0                   1

In the second case, three-value logic is desired, in which a junction
applied to an empty list returns C<Nil> rather than C<True> or C<False>.

Junctions with a C<_u> suffix implement three-valued logic.  Those
without are boolean.

=head3 all BLOCK, LIST

=head3 all_u BLOCK, LIST

Returns True if all items in LIST meet the criterion given through
BLOCK. Passes each element in LIST to the BLOCK in turn:

  say "All values are non-negative"
    if all { $_ >= 0 }, ($x, $y, $z);

For an empty LIST, C<all> returns True (i.e. no values failed the condition)
and C<all_u> returns C<Nil>.

Thus, C<< all_u(@list) >> is equivalent to C<< @list ?? all(@list) !! Nil >>.

B<Note>: because Perl treats C<Nil> as false, you must check the return value
of C<all_u> with C<defined> or you will get the opposite result of what you
expect.

=head3 any BLOCK, LIST

=head3 any_u BLOCK, LIST

Returns True if any item in LIST meets the criterion given through
BLOCK. Passes each element in LIST to the BLOCK in turn:

  say "At least one non-negative value"
    if any { $_ >= 0 }, ($x, $y, $z);

For an empty LIST, C<any> returns False and C<any_u> returns C<Nil>.

Thus, C<< any_u(@list) >> is equivalent to C<< @list ?? any(@list) !! undef >>.

=head3 none BLOCK, LIST

=head3 none_u BLOCK, LIST

Logically the negation of C<any>. Returns True if no item in LIST meets
the criterion given through BLOCK. Passes each element in LIST to the BLOCK
in turn:

  say "No non-negative values"
    if none { $_ >= 0 }, ($x, $y, $z);

For an empty LIST, C<none> returns True (i.e. no values failed the condition)
and C<none_u> returns C<Nil>.

Thus, C<< none_u(@list) >> is equivalent to C<< @list ?? none(@list) !! Nil >>.

B<Note>: because Perl treats C<Nil> as false, you must check the return value
of C<none_u> with C<defined> or you will get the opposite result of what you
expect.

=head3 notall BLOCK, LIST

=head3 notall_u BLOCK, LIST

Logically the negation of C<all>. Returns True if not all items in LIST meet
the criterion given through BLOCK. Passes each element in LIST to the BLOCK
in turn:

  say "Not all values are non-negative"
    if notall { $_ >= 0 }, ($x, $y, $z);

For an empty LIST, C<notall> returns False and C<notall_u> returns C<Nil>.

Thus, C<< notall_u(@list) >> is equivalent to C<< @list ?? notall(@list) !! Nil >>.

=head3 one BLOCK, LIST

=head3 one_u BLOCK, LIST

Returns True if precisely one item in LIST meets the criterion given through
BLOCK. Passes each element in LIST to the BLOCK in turn:

    say "Precisely one value defined"
      if one { defined($_) }, @list;

Returns False otherwise.

For an empty LIST, C<one> returns False and C<one_u> returns C<Nil>.

The expression C<one BLOCK, LIST> is almost equivalent to
C<1 == True BLOCK, LIST>, except for short-cutting.  Evaluation of BLOCK will
immediately stop at the second true value seen.

=head2 Transformation

=head3 apply BLOCK, LIST

Applies BLOCK to each item in LIST and returns a list of the values after
BLOCK has been applied. Returns the last element if C<:scalar> has been
specified.  This function is similar to C<map> but will not modify the
elements of the input list:

    my @list = 1 .. 4;
    my @mult = apply { $_ *= 2 }, @list;
    print "@list = @list[]\n";
    print "@mult = @mult[]\n";
    =====================================
    @list = 1 2 3 4
    @mult = 2 4 6 8

With the C<:scalar> named parameter:

    my @list = 1 .. 4;
    my $last = apply { $_ *= 2 }, @list, :scalar;
    print "@list = @list[]\n";
    print "\$last = $last\n";
    =====================================
    @list = 1 2 3 4
    $last = 8

Think of it as syntactic sugar for

    my @mult = map -> $_ is copy { $_ *= 2 }, @list;

=head3 insert_after BLOCK, VALUE, LIST

Inserts VALUE after the first item in LIST for which the criterion in BLOCK
is true. Sets C<$_> for each item in LIST in turn.

    my @list = <This is a list>;
    insert_after { $_ eq "a" }, "longer" => @list;
    say "@list[]";
    ===================================
    This is a longer list

=head3 insert_after_string STRING, VALUE, LIST

Inserts VALUE after the first item in LIST which is equal to STRING.

    my @list = <This is a list>;
    insert_after_string "a", "longer" => @list;
    say "@list[]";
    ===================================
    This is a longer list

=head3 pairwise BLOCK, ARRAY1, ARRAY2

Evaluates BLOCK for each pair of elements in ARRAY1 and ARRAY2 and returns a
new list consisting of BLOCK's return values. The two elements are passed as
parameters to BLOCK.

    my @a = 1 .. 5;
    my @b = 11 .. 15;
    my @x = pairwise -> $a, $b { $a + $b }, @a, @b; # returns 12, 14, 16, 18, 20

    # mesh with pairwise
    my @a = <a b c>;
    my @b = <1 2 3>;
    my @x = pairwise -> $a, $b { $a, $b }, @a, @b;    # returns a, 1, b, 2, c, 3

=head3 mesh ARRAY1, ARRAY2 [ , ARRAY3 ... ]

=head3 zip ARRAY1, ARRAY2 [ , ARRAY3 ... ]

Returns a list consisting of the first elements of each array, then
the second, then the third, etc, until all arrays are exhausted.

Examples:

    my @x = <a b c d>;
    my @y = <1 2 3 4>;
    my @z = mesh @x, @y;       # returns a, 1, b, 2, c, 3, d, 4

    my Str @a = 'x';
    my Int @b = 1, 2;
    my @c = <zip zap zot>;
    my @d = mesh @a, @b, @c;   # x, 1, zip, Str, 2, zap, Str, Int, zot

C<zip> is an alias for C<mesh>.

=head3 zip6 ARRAY1, ARRAY2 [ , ARRAY3 ... ]

=head3 zip_unflatten ARRAY1, ARRAY2 [ , ARRAY3 ... ]

Returns a list of arrays consisting of the first elements of each array,
then the second, then the third, etc, until all arrays are exhausted.

    my @x = <a b c d>;
    my @y = <1 2 3 4>;
    my @z = zip6 @x, @y;     # returns [a, 1], [b, 2], [c, 3], [d, 4]

    my Str @a = 'x';
    my Int @b = 1, 2;
    my @c = <zip zap zot>;
    my @d = zip6 @a, @b, @c; # [x, 1, zip], [Str, 2, zap], [Str, Int, zot]

C<zip_unflatten> is an alias for C<zip6>.

=head3 listcmp ARRAY0 ARRAY1 [ ARRAY2 ... ]

Returns an associative list of elements and every I<id> of the list it
was found in. Allows easy implementation of @a & @b, @a | @b, @a ^ @b and
so on.  Undefined entries in any given array are skipped.

    my @a = <one two four five six seven eight nine ten>;
    my @b = <two five seven eleven thirteen seventeen>;
    my @c = <one one two five eight thirteen twentyone>;

    my %cmp := listcmp @a, @b, @c;
    # (one => [0, 2], two => [0, 1, 2], four => [0], ...)

    my @seq = 1, 2, 3;
    my @prim = Int, 2, 3, 5;
    my @fib = 1, 1, 2;
    my $cmp = listcmp @seq, @prim, @fib;
    # { 1 => [0, 2], 2 => [0, 1, 2], 3 => [0, 1], 5 => [1] }

=head3 arrayify LIST [,LIST [,LIST...]]

Returns a list costisting of each element of the given arrays. Recursive arrays
are flattened, too.

    my @a = 1, [[2], 3], 4, [5], 6, [7], 8, 9;
    my @l = arrayify @a;   # returns 1, 2, 3, 4, 5, 6, 7, 8, 9

=head3 uniq LIST

=head3 distinct LIST

Returns a new list by stripping duplicate values in LIST by comparing
the values as hash keys, except that type objects are considered separate
from ''.  The order of elements in the returned list is the same as in LIST.
Returns the number of unique elements in LIST if the C<:scalar> named parameter
has been specified.

    my @x = uniq (1, 1, 2, 2, 3, 5, 3, 4);           # returns (1,2,3,5,4)
    my $x = uniq (1, 1, 2, 2, 3, 5, 3, 4), :$scalar; # returns 5

    my @n = distinct "Mike", "Michael", "Richard", "Rick", "Michael", "Rick"
    # ("Mike", "Michael", "Richard", "Rick")

    my @s = distinct "A8", "", Str, "A5", "S1", "A5", "A8"
    # ("A8", "", Str, "A5", "S1")

    my @w = uniq "Giulia", "Giulietta", Str, "", 156, "Giulietta", "Giulia";
    # ("Giulia", "Giulietta", Str, "", 156)

C<distinct> is an alias for C<uniq>.

=head3 singleton LIST

Returns a new list by stripping values in LIST occurring only once by
comparing the values as hash keys, except that type objects are considered
separate from ''.  The order of elements in the returned list is the same
as in LIST.  Returns the number of elements occurring only once in LIST
if the C<:scalar> named parameter has been specified.

    my @x = singleton (1,1,4,2,2,3,3,5);          # returns (4,5)
    my $n = singleton (1,1,4,2,2,3,3,5), :scalar; # returns 2

=head3 duplicates LIST

Returns a new list by stripping values in LIST occuring more than once by
comparing the values as hash keys, except that type objects are considered
separate from ''.  The order of elements in the returned list is the same
as in LIST.  Returns the number of elements occurring more than once in LIST.

    my @y = duplicates (1,1,2,4,7,2,3,4,6,9);          # returns (1,2,4)
    my $n = duplicates (1,1,2,4,7,2,3,4,6,9), :scalar; # returns 3

=head3 frequency LIST

Returns a hash of distinct values and the corresponding frequency.

    my %f := frequency values %radio_nrw; # returns (
    #  'Deutschlandfunk (DLF)' => 9, 'WDR 3' => 10,
    #  'WDR 4' => 11, 'WDR 5' => 14, 'WDR Eins Live' => 14,
    #  'Deutschlandradio Kultur' => 8,...)

=head3 occurrences LIST

Returns a new list of frequencies and the corresponding values from LIST.

    my @o = occurrences (1 xx 3, 2 xx 4, 3 xx 2, 4 xx 7, 5 xx 2, 6 xx 4);
    # (Any, Any, [3, 5], [1], [2, 6], Any, Any, [4])

=head3 mode LIST

Returns the modal value of LIST. Returns the modal value only if the
C<:scalar> name parameter is specified.  Otherwise all probes occuring
I<modal> times are returned as well.

    my @m = mode (1 xx 3, 2 xx 4, 3 xx 2, 4 xx 7, 5 xx 2, 6 xx 7);
    #  (7, 4, 6)
    my $mode = mode (1 xx 3, 2 xx 4, 3 xx 2, 4 xx 7, 5 xx 2, 6 xx 7), :scalar;
    #  7

=head2 Partitioning

=head3 after BLOCK, LIST

Returns a list of the values of LIST after (and not including) the point
where BLOCK returns a true value. Passes the value as a parameter to
BLOCK for each element in LIST in turn.

    my @x = after { $_ %% 5 }, (1..9);   # returns (6, 7, 8, 9)

=head3 after_incl BLOCK, LIST

Same as C<after> but also includes the element for which BLOCK is true.

    my @x = after_incl { $_ %% 5 }, (1..9);   # returns (5, 6, 7, 8, 9)

=head3 before BLOCK, LIST

Returns a list of values of LIST up to (and not including) the point where
BLOCK returns a true value. Passes the value as a parameter to BLOCK for
each element in LIST in turn.

    my @x = before { $_ %% 5 }, (1..9);   # returns (1, 2, 3, 4)

=head3 before_incl BLOCK LIST

Same as C<before> but also includes the element for which BLOCK is true.

    my @x = before_incl { $_ %% 5 }, (1..9);   # returns (1, 2, 3, 4, 5)

=head3 part BLOCK, LIST

Partitions LIST based on the return value of BLOCK which denotes into which
partition the current value is put.

Returns a list of the partitions thusly created. Each partition created is
an Array.

    my $i = 0;
    my @part = part { $i++ % 2 } (1..8); # returns ([1, 3, 5, 7], [2, 4, 6, 8])

You can have a sparse list of partitions as well where non-set partitions will
be an C<Array> type object:

    my @part = part { 2 } (1..5);        # returns (Array, Array, [1,2,3,4,5])

Be careful with negative values, though:

    my @part = part { -1 } (1..10);
    ===============================
    Unsupported use of a negative -1 subscript to index from the end

Negative values are only ok when they refer to a partition previously created:

    my @idx  = 0, 1, -1;
    my $i    = 0;
    my @part = part { $idx[$i++ % 3] }, (1..8); # ([1, 4, 7], [2, 3, 5, 6, 8])

=head3 samples COUNT, LIST

Returns a new list containing COUNT random samples from LIST. Is similar to
L<List::Util/shuffle>, but stops after COUNT.

    my @r  = samples 10, (1..10); # same as (1..10).pick(*)
    my @r2 = samples 5, (1..10);  # same as (1..10).pick(5)

=head2 Iteration

=head3 each_array ARRAY1, ARRAY2 ...

Creates an array iterator to return the elements of the list of arrays ARRAY1,
ARRAY2 throughout ARRAYn in turn.  That is, the first time it is called, it
returns the first element of each array.  The next time, it returns the second
elements.  And so on, until all elements are exhausted.

This is useful for looping over more than one array at once:

    my &ea = each_array(@a, @b, @c);
    while ea() -> ($a,$b,$c) { .... }

The iterator returns the empty list when it reached the end of all arrays.

If the iterator is passed an argument of 'C<index>', then it returns
the index of the last fetched set of values, as a scalar.

=head3 each_arrayref LIST

Like each_array, but the arguments is a single list with arrays.

=head3 natatime EXPR, LIST

Creates an array iterator, for looping over an array in chunks of
C<$n> items at a time.  (n at a time, get it?).  An example is
probably a better explanation than I could give in words.

Example:

    my @x = 'a'..'g';
    my &it = natatime 3, @x;
    while it() -> @vals {
        print "@vals[]\n";
    }

This prints

  a b c
  d e f
  g

=head2 Searching

=head3 firstval BLOCK, LIST

=head3 first_value BLOCK, LIST

Returns the first element in LIST for which BLOCK evaluates to true. Each
element of LIST is passed to the BLOCK in turn. Returns C<Nil> if no such
element has been found.

    my @list = <alpha beta cicero bearing effortless>;
    say firstval { .starts-with('c') }, @list;  # cicero
    say firstval { .starts-with('b') }, @list;  # beta
    say firstval { .starts-with('g') }, @list;  # Nil, because never

C<first_value> is an alias for C<firstval>.

=head3 onlyval BLOCK, LIST

=head3 only_value BLOCK, LIST

Returns the only element in LIST for which BLOCK evaluates to true. Each
element in LIST is passed to BLOCK in turn. Returns C<Nil> if no such element
has been found.

    my @list = <alpha beta cicero bearing effortless>;
    say onlyval { .starts-with('c') }, @list;  # cicero
    say onlyval { .starts-with('b') }, @list;  # Nil, because twice
    say onlyval { .starts-with('g') }, @list;  # Nil, because never

C<only_value> is an alias for C<onlyval>.

=head3 lastval BLOCK, LIST

=head3 last_value BLOCK, LIST

Returns the last value in LIST for which BLOCK evaluates to true. Each element
in LIST is passed to BLOCK in turn. Returns C<Nil> if no such element has been
found.

    my @list = <alpha beta cicero bearing effortless>;
    say lastval { .starts-with('c') }, @list;  # cicero
    say lastval { .starts-with('b') }, @list;  # bearing
    say lastval { .starts-with('g') }, @list;  # Nil, because never

C<last_value> is an alias for C<lastval>.

=head3 firstres BLOCK, LIST

=head3 first_result BLOCK, LIST

Returns the result of BLOCK for the first element in LIST for which BLOCK
evaluates to true. Each element of LIST is passed to BLOCK in turn. Returns
C<Nil> if no such element has been found.

    my @list = <alpha beta cicero bearing effortless>;
    say firstres { .uc if .starts-with('c') }, @list;  # CICERO
    say firstres { .uc if .starts-with('b') }, @list;  # BETA
    say firstres { .uc if .starts-with('g') }, @list;  # Nil, because never

C<first_result> is an alias for C<firstres>.

=head3 onlyres BLOCK, LIST

=head3 only_result BLOCK, LIST

Returns the result of BLOCK for the first element in LIST for which BLOCK
evaluates to true. Each element of LIST is passed to BLOCK in turn. Returns
C<Nil> if no such element has been found.

    my @list = <alpha beta cicero bearing effortless>;
    say onlyres { .uc if .starts-with('c') }, @list;  # CICERO
    say onlyres { .uc if .starts-with('b') }, @list;  # Nil, because twice
    say onlyres { .uc if .starts-with('g') }, @list;  # Nil, because never

C<only_result> is an alias for C<onlyres>.

=head3 lastres BLOCK, LIST

=head3 last_result BLOCK, LIST

Returns the result of BLOCK for the last element in LIST for which BLOCK
evaluates to true. Each element of LIST is passed to BLOCK in turn. Returns
C<Nil> if no such element has been found.

    my @list = <alpha beta cicero bearing effortless>;
    say lastval { .uc if .starts-with('c') }, @list;  # CICERO
    say lastval { .uc if .starts-with('b') }, @list;  # BEARING
    say lastval { .uc if .starts-with('g') }, @list;  # Nil, because never

C<last_result> is an alias for C<lastres>.

=head3 indexes BLOCK, LIST

Evaluates BLOCK for each element in LIST (passed to BLOCK as the parameter)
and returns a list of the indices of those elements for which BLOCK returned
a true value. This is just like C<grep> only that it returns indices instead
of values:

    my @x = indexes { $_ %% 2 } (1..10);   # returns (1, 3, 5, 7, 9)

=head3 firstidx BLOCK, LIST

=head3 first_index BLOCK, LIST

Returns the index of the first element in LIST for which the criterion in BLOCK
is true. Passes each element in LIST to BLOCK in turn:

    my @list = 1, 4, 3, 2, 4, 6;
    printf "item with index %i in list is 4", firstidx { $_ == 4 }, @list;
    ===============================
    item with index 1 in list is 4

Returns C<-1> if no such item could be found.

    my @list = 1, 3, 4, 3, 2, 4;
    print firstidx { $_ == 3 }, @list;    # 1
    print firstidx { $_ == 5 }, @list;    # -1, because not found

C<first_index> is an alias for C<firstidx>.

=head3 onlyidx BLOCK, LIST

=head3 only_index BLOCK, LIST

Returns the index of the only element in LIST for which the criterion
in BLOCK is true. Passes each element in LIST to BLOCK in turn:

    my @list = 1, 3, 4, 3, 2, 4;
    printf "uniqe index of item 2 in list is %i", onlyidx { $_ == 2 }, @list;
    ===============================
    unique index of item 2 in list is 4

Returns C<-1> if either no such item or more than one of these has been found.

    my @list = 1, 3, 4, 3, 2, 4;
    print onlyidx { $_ == 3 }, @list;    # -1, because more than once
    print onlyidx { $_ == 5 }, @list;    # -1, because not found

C<only_index> is an alias for C<onlyidx>.

=head3 lastidx BLOCK, LIST

=head3 last_index BLOCK, LIST

Returns the index of the last element in LIST for which the criterion in BLOCK
is true. Passes each element in LIST to BLOCK in turn:

    my @list = 1, 4, 3, 2, 4, 6;
    printf "item with index %i in list is 4", lastidx { $_ == 4 } @list;
    ==================================
    item with index 4 in list is 4

Returns C<-1> if no such item could be found.

    my @list = 1, 3, 4, 3, 2, 4;
    print lastidx { $_ == 3 }, @list;    # 3
    print lastidx { $_ == 5 }, @list;    # -1, because not found

C<last_index> is an alias for C<lastidx>.

=head2 Sorting

=head3 sort_by BLOCK, LIST

Returns the list of values sorted according to the string values returned by
the BLOCK. A typical use of this may be to sort objects according to the
string value of some accessor, such as:

    my @sorted = sort_by { .name }, @people;  # same as @people.sort( *.name )

The key function is being passed each value in turn, The values are then
sorted according to string comparisons on the values returned.
This is equivalent to:

    my @sorted = sort -> $a, $b { $a.name cmp $b.name }, @people;

except that it guarantees the C<name> accessor will be executed only once
per value.  One interesting use-case is to sort strings which may have numbers
embedded in them "naturally", rather than lexically:

    my @sorted = sort_by { S:g/ (\d+) / { sprintf "%09d", $0 } / }, @strings;

This sorts strings by generating sort keys which zero-pad the embedded numbers
to some level (9 digits in this case), helping to ensure the lexical sort puts
them in the correct order.

=head3 nsort_by BLOCK, LIST

Similar to C<sort_by> but compares its key values numerically.

=head3 qsort BLOCK, ARRAY

This sorts the given array B<in place> using the given compare code.  The
Perl 6 version uses the basic sort functionality as provided by the C<sort>
built-in function.

=head2 Searching in sorted Lists

=head3 bsearch BLOCK, LIST

Performs a binary search on LIST which must be a sorted list of values.
BLOCK receives each element in turn and must return a negative value if the
element is smaller, a positive value if it is bigger and zero if it matches.

Returns a boolean value if the C<:scalar> named parameter is specified.
Otherwise it returns a single element list if it was found, or the empty list
if none of the calls to BLOCK returned C<0>.

    my @list  = <alpha beta cicero delta>;
    my @found = bsearch { $_ cmp "cicero" }, @list;   # ("cicero",)
    my @found = bsearch { $_ cmp "effort" }, @list;   # ()

    my @list  = <alpha beta cicero delta>;
    my $found = bsearch { $_ cmp "cicero" }, @list, :scalar;   # True
    my $found = bsearch { $_ cmp "effort" }, @list, :scalar;   # False

=head3 bsearchidx BLOCK, LIST

=head3 bsearch_index BLOCK, LIST

Performs a binary search on LIST which must be a sorted list of values.
BLOCK receives each element in turn and must return a negative value if the
element is smaller, a positive value if it is bigger and zero if it matches.

Returns the index of found element, otherwise C<-1>.

    my @list  = <alpha beta cicero delta>;
    my $found = bsearchidx { $_ cmp "cicero" }, @list;   # 2
    my $found = bsearchidx { $_ cmp "effort" }, @list;   # -1

C<bsearch_index> is an alias for C<bsearchidx>.

=head3 lower_bound BLOCK, LIST

Returns the index of the first element in LIST which does not compare
I<less than val>. Technically it's the first element in LIST which does
not return a value below zero when passed to BLOCK.

    my @ids = 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 6;
    my $lb = lower_bound { $_ <=> 2 }, @ids; # 1
    my $lb = lower_bound { $_ <=> 4 }, @ids; # 9

=head3 upper_bound BLOCK, LIST

Returns the index of the first element in LIST which does not compare
I<greater than val>. Technically it's the first element in LIST which does
not return a value below or equal to zero when passed to BLOCK.

    my @ids = 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 6;
    my $ub = upper_bound { $_ <=> 2 }, @ids; # 3
    my $ub = upper_bound { $_ <=> 4 }, @ids; # 13

=head3 equal_range BLOCK, LIST

Returns a list of indices containing the C<lower_bound> and the C<upper_bound>
of given BLOCK and LIST.

    my @ids = 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 6;
    my $er = equal_range { $_ <=> 2 }, @ids; # (1,3)
    my $er = equal_range { $_ <=> 4 }, @ids; # (9,13)

=head2 Operations on sorted Lists

=head3 binsert BLOCK, ITEM, LIST

=head3 bsearch_insert BLOCK, ITEM, LIST

Performs a binary search on LIST which must be a sorted list of values.
BLOCK must return a negative value if the current element (passed as a
parameter to the BLOCK) is smaller, a positive value if it is bigger and
zero if it matches.

ITEM is inserted at the index where the ITEM should be placed (based on above
search). That means, it's inserted before the next bigger element.

    my @l = 2,3,5,7;
    binsert { $_ <=> 4 },  4, @l; # @l = (2,3,4,5,7)
    binsert { $_ <=> 6 }, 42, @l; # @l = (2,3,4,5,42,7)

You take care that the inserted element matches the compare result.

C<bsearch_insert> is an alias for C<binsert>.

=head3 bremove BLOCK, LIST

=head3 bsearch_remove BLOCK, LIST

Performs a binary search on LIST which must be a sorted list of values.
BLOCK must return a negative value if the current element (passed as a
parameter to the BLOCK) is smaller, a positive value if it is bigger and
zero if it matches.

The item at the found position is removed and returned.

    my @l = 2,3,4,5,7;
    bremove { $_ <=> 4 }, @l; # @l = (2,3,5,7);

C<bsearch_remove> is an alias for C<bremove>.

=head2 Counting and calculation

=head3 true BLOCK, LIST

Counts the number of elements in LIST for which the criterion in BLOCK is true.
Passes each item in LIST to BLOCK in turn:

    printf "%i item(s) are defined", true { defined($_) }, @list;

=head3 false BLOCK, LIST

Counts the number of elements in LIST for which the criterion in BLOCK is false.
Passes each item in LIST to BLOCK in turn:

    printf "%i item(s) are not defined", false { defined($_) }, @list;

=head3 reduce_0 BLOCK, LIST

Reduce LIST by calling BLOCK in scalar context for each element of LIST.
The first parameter contains the progressional result and is initialized
with B<0>.  The second parameter contains the currently being processed
element of LIST.

    my $reduced = reduce_0 -> $a, $b { $a + $b }, @list;

In the Perl 5 version, C<$_> is also set to the index of the element being
processed.  This is not the case in the Perl 6 version for various reasons.
Should you need the index value in your calculation, you can post-increment
the anonymous state variable instead: C<$++>:

    my $reduced = reduce_0 -> $a, $b { dd $++ }, @list; # 0 1 2 3 4 5 ...

The idea behind reduce_0 is B<summation> (addition of a sequence of numbers).

=head3 reduce_1 BLOCK, LIST

Reduce LIST by calling BLOCK in scalar context for each element of LIST.
The first parameter contains the progressional result and is initialized
with B<1>.  The second parameter contains the currently being processed
element of LIST.

    my $reduced = reduce_1 -> $a, $b { $a * $b }, @list;

In the Perl 5 version, C<$_> is also set to the index of the element being
processed.  This is not the case in the Perl 6 version for various reasons.
Should you need the index value in your calculation, you can post-increment
the anonymous state variable instead: C<$++>:

    my $reduced = reduce_1 -> $a, $b { dd $++ }, @list; # 0 1 2 3 4 5 ...

The idea behind reduce_1 is B<product> of a sequence of numbers.

=head3 reduce_u BLOCK, LIST

Reduce LIST by calling BLOCK in scalar context for each element of LIST.
The first parameter contains the progressional result and is initialized
with B<Any>.  The second parameter contains the currently being processed
element of LIST.

    my $reduced = reduce_u -> $a, $b { $a.push($b) }, @list;

In the Perl 5 version, C<$_> is also set to the index of the element being
processed.  This is not the case in the Perl 6 version for various reasons.
Should you need the index value in your calculation, you can post-increment
the anonymous state variable instead: C<$++>:

    my $reduced = reduce_u -> $a, $b { dd $++ }, @list; # 0 1 2 3 4 5 ...

The idea behind reduce_u is to produce a list of numbers.

=head3 minmax LIST

Calculates the minimum and maximum of LIST and returns a two element list with
the first element being the minimum and the second the maximum. Returns the
empty list if LIST was empty.

    my ($min,$max) = minmax (43,66,77,23,780); # (23,780)

=head3 minmaxstr LIST

Computes the minimum and maximum of LIST using string compare and returns a
two element list with the first element being the minimum and the second the
maximum. Returns the empty list if LIST was empty.

    my ($min,$max) = minmaxstr <foo bar baz zippo>; # <bar zippo>

=head1 SEE ALSO

L<List::Util>, L<List::AllUtils>, L<List::UtilsBy>

=head1 THANKS

Thanks to all of the individuals who have contributed to the Perl 5 version
of this module.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/List-MoreUtils . Comments
and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

Re-imagined from the Perl 5 version as part of the CPAN Butterfly Plan. Perl 5
version originally developed by Tassilo von Parseval, subsequently maintained
by Adam Kennedy and Jens Rehsack.

=end pod

# vim: ft=perl6 expandtab sw=4
