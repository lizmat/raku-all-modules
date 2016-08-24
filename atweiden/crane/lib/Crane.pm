use v6;
use X::Crane;
unit class Crane;

# at {{{

sub at($container, *@steps) is rw is export
{
    my $root := $container;
    return-rw _at($root, @steps);
}

# Associative handling {{{

multi sub _at(Associative $container, @steps where *.elems > 1) is rw
{
    my $root := $container;
    if $root{@steps[0]}:exists
    {
        $root := $root{@steps[0]};
    }
    else
    {
        die X::Crane::AssociativeKeyDNE.new;
    }
    return-rw _at($root, @steps[1..*]);
}

multi sub _at(Associative $container, @steps where *.elems == 1) is rw
{
    my $root := $container;
    if $root{@steps[0]}:exists
    {
        $root := $root{@steps[0]};
    }
    else
    {
        die X::Crane::AssociativeKeyDNE.new;
    }
    return-rw $root;
}

multi sub _at(Associative $container, @steps where *.elems == 0) is rw
{
    return-rw $container;
}

multi sub _at(Associative $container) is rw
{
    return-rw $container;
}

# end Associative handling }}}

# Positional handling {{{

multi sub _at(Positional $container, @steps where *.elems > 1) is rw
{
    my $root := $container;
    validate-positional-index(@steps[0]);
    if $root[@steps[0]]:exists
    {
        $root := $root[@steps[0]];
    }
    else
    {
        die X::Crane::PositionalIndexDNE.new;
    }
    return-rw _at($root, @steps[1..*]);
}

multi sub _at(Positional $container, @steps where *.elems == 1) is rw
{
    my $root := $container;
    validate-positional-index(@steps[0]);
    if $root[@steps[0]]:exists
    {
        $root := $root[@steps[0]];
    }
    else
    {
        die X::Crane::PositionalIndexDNE.new;
    }
    return-rw $root;
}

multi sub _at(Positional $container, @steps where *.elems == 0) is rw
{
    return-rw $container;
}


multi sub _at(Positional $container) is rw
{
    return-rw $container;
}

# end Positional handling }}}

# end at }}}

# in {{{

sub in(\container, *@steps) is rw is export
{
    return-rw _in(container, @steps);
}

# Associative handling {{{

multi sub _in(Associative \container, @steps where *.elems > 1) is rw
{
    return-rw _in(container{@steps[0]}, @steps[1..*]);
}

multi sub _in(Associative \container, @steps where *.elems == 1) is rw
{
    return-rw container{@steps[0]};
}

multi sub _in(Associative \container, @steps where *.elems == 0) is rw
{
    return-rw container;
}

multi sub _in(Associative \container) is rw
{
    return-rw container;
}

# end Associative handling }}}

# Positional handling {{{

multi sub _in(Positional \container, @steps where *.elems > 1) is rw
{
    validate-positional-index(@steps[0]);
    return-rw _in(container[@steps[0]], @steps[1..*]);
}

multi sub _in(Positional \container, @steps where *.elems == 1) is rw
{
    validate-positional-index(@steps[0]);
    return-rw container[@steps[0]];
}

multi sub _in(Positional \container, @steps where *.elems == 0) is rw
{
    return-rw container;
}


multi sub _in(Positional \container) is rw
{
    return-rw container;
}

# end Positional handling }}}

# Any handling {{{

multi sub _in(\container, @steps where *.elems > 1) is rw
{
    given @steps[0]
    {
        when Int && $_ >= 0
        {
            return-rw _in(container[@steps[0]], @steps[1..*]);
        }
        when WhateverCode
        {
            return-rw _in(container[@steps[0]], @steps[1..*]);
        }
        default
        {
            return-rw _in(container{@steps[0]}, @steps[1..*]);
        }
    }
}

multi sub _in(\container, @steps where *.elems == 1) is rw
{
    given @steps[0]
    {
        when Int && $_ >= 0
        {
            return-rw container[@steps[0]];
        }
        when WhateverCode
        {
            return-rw container[@steps[0]];
        }
        default
        {
            return-rw container{@steps[0]};
        }
    }
}

multi sub _in(\container, @steps where *.elems == 0) is rw
{
    return-rw container;
}

multi sub _in(\container) is rw
{
    return-rw container;
}

# end Any handling }}}

# end in }}}

# exists {{{

method exists($container, :@path!, Bool :$k = True, Bool :$v) returns Bool
{
    $v.so ?? exists-value($container, @path) !! exists-key($container, @path);
}

# exists-key {{{

multi sub exists-key($container, @path where *.elems > 1) returns Bool
{
    exists-key($container, [@path[0]])
        ?? exists-key(at($container, @path[0]), @path[1..*])
        !! False;
}

multi sub exists-key(
    Associative $container,
    @path where *.elems == 1
) returns Bool
{
    $container{@path[0]}:exists;
}

multi sub exists-key(
    Associative $container,
    @path where *.elems == 0
) returns Bool
{
    die X::Crane::ExistsRootContainerKey.new;
}

multi sub exists-key(
    Positional $container,
    @path where *.elems == 1
) returns Bool
{
    validate-positional-index(@path[0]);
    $container[@path[0]]:exists;
}

multi sub exists-key(
    Positional $container,
    @path where *.elems == 0
) returns Bool
{
    die X::Crane::ExistsRootContainerKey.new;
}

multi sub exists-key($container, @path where *.elems > 0) returns Bool
{
    False;
}

# end exists-key }}}

# exists-value {{{

multi sub exists-value($container, @path where *.elems > 1) returns Bool
{
    exists-value($container, [@path[0]])
        ?? exists-value(at($container, @path[0]), @path[1..*])
        !! False;
}

multi sub exists-value(
    Associative $container,
    @path where *.elems == 1
) returns Bool
{
    $container{@path[0]}.defined;
}

multi sub exists-value(
    Associative $container,
    @path where *.elems == 0
) returns Bool
{
    $container.defined;
}

multi sub exists-value(
    Positional $container,
    @path where *.elems == 1
) returns Bool
{
    validate-positional-index(@path[0]);
    $container[@path[0]].defined;
}

multi sub exists-value(
    Positional $container,
    @path where *.elems == 0
) returns Bool
{
    $container.defined;
}

multi sub exists-value($container, @path where *.elems > 0) returns Bool
{
    False;
}

# end exists-value }}}

# end exists }}}

# get {{{

multi method get(
    $container,
    :@path!,
    Bool :$k! where *.so,
    Bool :$v where *.not,
    Bool :$p where *.not
) returns Any
{
    get-key($container, @path);
}

multi method get(
    $container,
    :@path!,
    Bool :$k where *.not,
    Bool :$v = True,
    Bool :$p where *.not
) returns Any
{
    get-value($container, @path);
}

multi method get(
    $container,
    :@path!,
    Bool :$k where *.not,
    Bool :$v where *.not,
    Bool :$p! where *.so
) returns Any
{
    get-pair($container, @path);
}

# get-key {{{

multi sub get-key($container, @path where *.elems > 1) returns Any
{
    exists-key($container, [@path[0]])
        ?? get-key(at($container, @path[0]), @path[1..*])
        !! die X::Crane::GetPathNotFound.new;
}

multi sub get-key(Associative $container, @path where *.elems == 1) returns Any
{
    exists-key($container, [@path[0]])
        ?? ($container{@path[0]}:!k)
        !! die X::Crane::GetPathNotFound.new;
}

multi sub get-key(Associative $container, @path where *.elems == 0) returns Any
{
    die X::Crane::GetRootContainerKey.new;
}

multi sub get-key(Positional $container, @path where *.elems == 1) returns Any
{
    validate-positional-index(@path[0]);
    exists-key($container, [@path[0]])
        ?? ($container[@path[0]]:!k)
        !! die X::Crane::GetPathNotFound.new;
}

multi sub get-key(Positional $container, @path where *.elems == 0) returns Any
{
    die X::Crane::GetRootContainerKey.new;
}

multi sub get-key($container, @path where *.elems > 0) returns Any
{
    die X::Crane::GetPathNotFound.new;
}

multi sub get-key($container, @path where *.elems == 0) returns Any
{
    die X::Crane::GetRootContainerKey.new;
}

# end get-key }}}

# get-value {{{

multi sub get-value($container, @path where *.elems > 1) returns Any
{
    exists-key($container, [@path[0]])
        ?? get-value(at($container, @path[0]), @path[1..*])
        !! die X::Crane::GetPathNotFound.new;
}

multi sub get-value(Associative $container, @path where *.elems == 1) returns Any
{
    exists-key($container, [@path[0]])
        ?? ($container{@path[0]}:!v)
        !! die X::Crane::GetPathNotFound.new;
}

multi sub get-value(Associative $container, @path where *.elems == 0) returns Any
{
    $container;
}

multi sub get-value(Positional $container, @path where *.elems == 1) returns Any
{
    validate-positional-index(@path[0]);
    exists-key($container, [@path[0]])
        ?? ($container[@path[0]]:!v)
        !! die X::Crane::GetPathNotFound.new;
}

multi sub get-value(Positional $container, @path where *.elems == 0) returns Any
{
    $container;
}

multi sub get-value($container, @path where *.elems > 0) returns Any
{
    die X::Crane::GetPathNotFound.new;
}

multi sub get-value($container, @path where *.elems == 0) returns Any
{
    $container;
}

# end get-value }}}

# get-pair {{{

multi sub get-pair($container, @path where *.elems > 1) returns Any
{
    exists-key($container, [@path[0]])
        ?? get-pair(at($container, @path[0]), @path[1..*])
        !! die X::Crane::GetPathNotFound.new;
}

multi sub get-pair(Associative $container, @path where *.elems == 1) returns Any
{
    exists-key($container, [@path[0]])
        ?? ($container{@path[0]}:!p)
        !! die X::Crane::GetPathNotFound.new;
}

multi sub get-pair(Associative $container, @path where *.elems == 0) returns Any
{
    die X::Crane::GetRootContainerKey.new;
}

multi sub get-pair(Positional $container, @path where *.elems == 1) returns Any
{
    validate-positional-index(@path[0]);
    exists-key($container, [@path[0]])
        ?? ($container[@path[0]]:!p)
        !! die X::Crane::GetPathNotFound.new;
}

multi sub get-pair(Positional $container, @path where *.elems == 0) returns Any
{
    die X::Crane::GetRootContainerKey.new;
}

multi sub get-pair($container, @path where *.elems > 0) returns Any
{
    die X::Crane::GetPathNotFound.new;
}

multi sub get-pair($container, @path where *.elems == 0) returns Any
{
    die X::Crane::GetRootContainerKey.new;
}

# end get-pair }}}

# end get }}}

# set {{{

method set(\container, :@path!, :$value!) returns Any
{
    # the Crane.set operation will fail when @path[*-1] is invalid for
    # the container type according to Crane syntax rules:
    #
    #   if @path[*-2] is Positional, then @path[*-1] must be
    #   Int/WhateverCode
    #
    # the Crane.set operation will fail when it's invalid to set
    # $container at @path to $value, such as when $container at @path
    # is an immutable value (X::Crane::OpSet::RO)
    CATCH
    {
        when X::Assignment::RO
        {
            die X::Crane::OpSet::RO.new(:typename(.typename));
        }
    }

    in(container, @path) = $value ~~ Positional ?? $value.clone !! $value;
    container ~~ Positional ?? |container !! container;
}

# end set }}}

# add {{{

method add(\container, :@path!, :$value!, Bool :$in-place = False) returns Any
{
    # the Crane.add operation will fail when @path DNE in $container
    # with rules similar to JSON Patch (X::Crane::AddPathNotFound,
    # X::Crane::AddPathOutOfRange)
    #
    # the Crane.add operation will fail when @path[*-1] is invalid for
    # the container type according to Crane syntax rules:
    #
    #   if @path[*-2] is Positional, then @path[*-1] must be
    #   Int/WhateverCode
    #
    # the Crane.add operation will fail when it's invalid to set
    # $container at @path to $value, such as when $container at @path
    # is an immutable value (X::Crane::Add::RO)
    CATCH
    {
        when X::Assignment::RO
        {
            die X::Crane::Add::RO.new(:typename(.typename));
        }
        when X::Method::NotFound
        {
            my rule no-such-method-splice
            {
                No such method \'splice\' for invocant of type \'(\w+)\'
            }
            if .message ~~ &no-such-method-splice
            {
                die X::Crane::Add::RO.new(:typename(~$0));
            }
        }
        when X::OutOfRange
        {
            die X::Crane::AddPathOutOfRange.new(
                :operation<add>,
                :out-of-range($_)
            );
        }
    }

    # route add operation based on path length
    add(container, :@path, :$value, :$in-place);
}

multi sub add(
    \container,
    :@path! where *.elems > 1,
    :$value!,
    Bool :$in-place = False
) returns Any
{
    unless Crane.exists(container, :path(@path[0..^*-1]), :v)
    {
        die X::Crane::AddPathNotFound.new;
    }

    # route add operation based on destination type
    given at(container, @path[0..^*-1]).WHAT
    {
        when Associative
        {
            # add pair to existing Associative (or replace existing pair)
            add-to-associative(
                container,
                :path(@path[0..^*-1]),
                :step(@path[*-1]),
                :$value,
                :$in-place
            );
        }
        when Positional
        {
            validate-positional-index(@path[*-1]);

            # splice in $value to Positional
            add-to-positional(
                container,
                :path(@path[0..^*-1]),
                :step(@path[*-1]),
                :$value,
                :$in-place
            );
        }
        default
        {
            # invalid path request that should never happen
            # how did we get here?
            # if:
            #
            #     Crane.exists($container, :path(@path[0..^*-1]), :v)
            #
            # and we have a path with >1 elems, then we must be entering
            # either an Associative or a Positional container
            # at($container, @path[0..^*-1])
            die '✗ Crane accident: add operation failed, invalid path';
        }
    }
}

multi sub add(
    \container,
    :@path! where *.elems == 1,
    :$value!,
    Bool :$in-place = False
) returns Any
{
    unless Crane.exists(container, :path(), :v)
    {
        die X::Crane::AddPathNotFound.new;
    }

    # route add operation based on destination type
    given container.WHAT
    {
        when Associative
        {
            # add pair to existing Associative (or replace existing pair)
            add-to-associative(
                container,
                :step(@path[*-1]),
                :$value,
                :$in-place
            );
        }
        when Positional
        {
            validate-positional-index(@path[*-1]);

            # splice in $value to Positional
            add-to-positional(
                container,
                :step(@path[*-1]),
                :$value,
                :$in-place
            );
        }
        default
        {
            # invalid path request that should never happen
            # how did we get here?
            # if:
            #
            #     Crane.exists($container, :path(@path[0..^*-1]), :v)
            #
            # and we have a path with 1 elem, then we must be entering
            # either an Associative or a Positional container
            # at($container, @path[0..^*-1])
            die '✗ Crane accident: add operation failed, invalid path';
        }
    }
}

multi sub add(
    \container,
    :@path! where *.elems == 0,
    :$value!,
    Bool :$in-place = False
) returns Any
{
    given container.WHAT
    {
        when Associative
        {
            add-to-associative(container, :$value, :$in-place);
        }
        when Positional
        {
            add-to-positional(container, :$value, :$in-place);
        }
        default
        {
            add-to-any(container, :$value, :$in-place);
        }
    }
}

# Associative handling {{{

multi sub add-to-associative(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool :$in-place = False
) returns Any
{
    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));
    at($root, @path){$step} = $value.WHAT ~~ Positional ?? $value.clone !! $value;
    $root;
}

multi sub add-to-associative(
    \container,
    :$step!,
    :$value!,
    Bool :$in-place = False
) returns Any
{
    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));
    $root{$step} = $value.WHAT ~~ Positional ?? $value.clone !! $value;
    $root;
}

multi sub add-to-associative(
    \container,
    :$value!,
    Bool :$in-place where *.not
) returns Any
{
    my $root = container.deepmap(*.clone);
    $root = $value;
    $root;
}

multi sub add-to-associative(
    \container,
    :$value!,
    Bool :$in-place where *.so
) returns Any
{
    container = $value;
    container;
}

# end Associative handling }}}

# Positional handling {{{

multi sub add-to-positional(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool :$in-place = False
) returns Any
{
    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));

    # XXX when $value is a multi-dimensional array, splice ruins it by
    # flattening it (splice's signature is *@target-to-splice-in)
    #
    # we have to inspect the structure of $value and work around this
    # to provide a sane api
    if $value ~~ Positional
    {
        my @value = $value;
        at($root, @path).splice($step, 0, $@value);
    }
    else
    {
        at($root, @path).splice($step, 0, $value);
    }
    |$root;
}

multi sub add-to-positional(
    \container,
    :$step!,
    :$value!,
    Bool :$in-place = False
) returns Any
{
    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));
    if $value ~~ Positional
    {
        my @value = $value;
        $root.splice($step, 0, $@value);
    }
    else
    {
        $root.splice($step, 0, $value);
    }
    |$root;
}

multi sub add-to-positional(
    \container,
    :$value!,
    Bool :$in-place where *.not
) returns Any
{
    my $root = container.deepmap(*.clone);
    $root = $value;
    |$root;
}

multi sub add-to-positional(
    \container,
    :$value!,
    Bool :$in-place where *.so
) returns Any
{
    container = $value.WHAT ~~ Positional ?? $value.clone !! $value;
    |container;
}

# end Positional handling }}}

# Any handling {{{

multi sub add-to-any(
    \container,
    :$value!,
    Bool :$in-place where *.not
) returns Any
{
    my $root = container.deepmap(*.clone);
    $root = $value;
    $root;
}

multi sub add-to-any(
    \container,
    :$value!,
    Bool :$in-place where *.so
) returns Any
{
    container = $value;
    container;
}

# end Any handling }}}

# end add }}}

# remove {{{

method remove(\container, :@path!, Bool :$in-place = False) returns Any
{
    # the Crane.remove operation will fail when @path DNE in $container
    # with rules similar to JSON Patch (X::Crane::RemovePathNotFound)
    #
    # the Crane.remove operation will fail when @path[*-1] is invalid for
    # the container type according to Crane syntax rules:
    #
    #   if @path[*-2] is Positional, then @path[*-1] must be
    #   Int/WhateverCode
    #
    # the Crane.remove operation will fail when it's invalid to remove
    # from $container at @path, such as when $container at @path is an
    # immutable value (X::Crane::Remove::RO)
    CATCH
    {
        when X::AdHoc
        {
            my rule can-not-remove
            {
                Can not remove [values|elements] from a (\w+)
            }
            if .payload ~~ &can-not-remove
            {
                die X::Crane::Remove::RO.new(:typename(~$0));
            }
        }
        when X::Method::NotFound
        {
            my rule no-such-method-splice
            {
                No such method \'splice\' for invocant of type \'(\w+)\'
            }
            if .message ~~ &no-such-method-splice
            {
                die X::Crane::Remove::RO.new(:typename(~$0));
            }
        }
    }

    # route remove operation based on path length
    remove(container, :@path, :$in-place);
}

multi sub remove(
    \container,
    :@path! where *.elems > 1,
    Bool :$in-place = False
) returns Any
{
    unless Crane.exists(container, :@path)
    {
        die X::Crane::RemovePathNotFound.new;
    }

    # route remove operation based on destination type
    given at(container, @path[0..^*-1]).WHAT
    {
        when Associative
        {
            # remove pair from Associative
            remove-from-associative(
                container,
                :path(@path[0..^*-1]),
                :step(@path[*-1]),
                :$in-place
            );
        }
        when Positional
        {
            validate-positional-index(@path[*-1]);

            # remove element from Positional
            remove-from-positional(
                container,
                :path(@path[0..^*-1]),
                :step(@path[*-1]),
                :$in-place
            );
        }
        default
        {
            # invalid path request that should never happen
            # how did we get here?
            # if:
            #
            #     Crane.exists(container, :@path)
            #
            # and we have a path with >1 elems, then we must be entering
            # either an Associative or a Positional container
            # at($container, @path[0..^*-1])
            die '✗ Crane accident: remove operation failed, invalid path';
        }
    }
}

multi sub remove(
    \container,
    :@path! where *.elems == 1,
    Bool :$in-place = False
) returns Any
{
    unless Crane.exists(container, :@path)
    {
        die X::Crane::RemovePathNotFound.new;
    }

    # route remove operation based on destination type
    given container.WHAT
    {
        when Associative
        {
            # remove pair from Associative
            remove-from-associative(container, :step(@path[*-1]), :$in-place);
        }
        when Positional
        {
            validate-positional-index(@path[*-1]);

            # remove element from Positional
            remove-from-positional(container, :step(@path[*-1]), :$in-place);
        }
        default
        {
            # invalid path request that should never happen
            # how did we get here?
            # if:
            #
            #     Crane.exists(container, :@path)
            #
            # and we have a path with 1 elem, then we must be entering
            # either an Associative or a Positional container
            # at($container, @path[0..^*-1])
            die '✗ Crane accident: remove operation failed, invalid path';
        }
    }
}

multi sub remove(
    \container,
    :@path! where *.elems == 0,
    Bool :$in-place = False
) returns Any
{
    given container.WHAT
    {
        when Associative
        {
            remove-from-associative(container, :$in-place);
        }
        when Positional
        {
            remove-from-positional(container, :$in-place);
        }
        default
        {
            remove-from-any(container, :$in-place);
        }
    }
}

# Associative handling {{{

multi sub remove-from-associative(
    \container,
    :@path!,
    :$step!,
    Bool :$in-place = False
) returns Any
{
    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));
    at($root, @path){$step}:delete;
    $root;
}

multi sub remove-from-associative(
    \container,
    :$step!,
    Bool :$in-place = False
) returns Any
{
    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));
    $root{$step}:delete;
    $root;
}

multi sub remove-from-associative(
    \container,
    Bool :$in-place where *.not
) returns Any
{
    my $root = container.deepmap(*.clone);
    $root = Empty;
    $root;
}

multi sub remove-from-associative(
    \container,
    Bool :$in-place where *.so
) returns Any
{
    container = Empty;
    container;
}

# end Associative handling }}}

# Positional handling {{{

multi sub remove-from-positional(
    \container,
    :@path!,
    :$step!,
    Bool :$in-place = False
) returns Any
{
    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));
    at($root, @path).splice($step, 1);
    |$root;
}

multi sub remove-from-positional(
    \container,
    :$step!,
    Bool :$in-place = False
) returns Any
{
    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));
    $root.splice($step, 1);
    |$root;
}

multi sub remove-from-positional(
    \container,
    Bool :$in-place where *.not
) returns Any
{
    my $root = container.deepmap(*.clone);
    $root = Empty;
    |$root;
}

multi sub remove-from-positional(
    \container,
    Bool :$in-place where *.so
) returns Any
{
    container = Empty;
    |container;
}

# end Positional handling }}}

# Any handling {{{

multi sub remove-from-any(\container, Bool :$in-place where *.not) returns Any
{
    my $root = container.deepmap(*.clone);
    $root = Nil;
    $root;
}

multi sub remove-from-any(\container, Bool :$in-place where *.so) returns Any
{
    container = Nil;
    container;
}

# end Any handling }}}

# end remove }}}

# replace {{{

method replace(\container, :@path!, :$value!, Bool :$in-place = False) returns Any
{
    # the Crane.replace operation will fail when @path DNE in $container
    # with rules similar to JSON Patch (X::Crane::ReplacePathNotFound)
    #
    # the Crane.replace operation will fail when @path[*-1] is invalid
    # for the container type according to Crane syntax rules:
    #
    #   if @path[*-2] is Positional, then @path[*-1] must be
    #   Int/WhateverCode
    #
    # the Crane.replace operation will fail when it's invalid to set
    # $container at @path to $value, such as when $container at @path
    # is an immutable value (X::Crane::Replace::RO)
    CATCH
    {
        when X::Assignment::RO
        {
            die X::Crane::Replace::RO.new(:typename(.typename));
        }
        when X::Method::NotFound
        {
            my rule no-such-method-splice
            {
                No such method \'splice\' for invocant of type \'(\w+)\'
            }
            if .message ~~ &no-such-method-splice
            {
                die X::Crane::Replace::RO.new(:typename(~$0));
            }
        }
    }

    # route replace operation based on path length
    replace(container, :@path, :$value, :$in-place);
}

multi sub replace(
    \container,
    :@path! where *.elems > 1,
    :$value!,
    Bool :$in-place = False
) returns Any
{
    unless Crane.exists(container, :@path)
    {
        die X::Crane::ReplacePathNotFound.new;
    }

    # route replace operation based on destination type
    given at(container, @path[0..^*-1]).WHAT
    {
        when Associative
        {
            # replace pair in Associative
            replace-in-associative(
                container,
                :path(@path[0..^*-1]),
                :step(@path[*-1]),
                :$value,
                :$in-place
            );
        }
        when Positional
        {
            validate-positional-index(@path[*-1]);

            # splice in $value to Positional
            replace-in-positional(
                container,
                :path(@path[0..^*-1]),
                :step(@path[*-1]),
                :$value,
                :$in-place
            );
        }
        default
        {
            # invalid path request that should never happen
            # how did we get here?
            # if:
            #
            #     Crane.exists(container, :@path)
            #
            # and we have a path with >1 elems, then we must be entering
            # either an Associative or a Positional container
            # at($container, @path[0..^*-1])
            die '✗ Crane accident: replace operation failed, invalid path';
        }
    }
}

multi sub replace(
    \container,
    :@path! where *.elems == 1,
    :$value!,
    Bool :$in-place = False
) returns Any
{
    unless Crane.exists(container, :@path)
    {
        die X::Crane::ReplacePathNotFound.new;
    }

    # route replace operation based on destination type
    given container.WHAT
    {
        when Associative
        {
            # replace pair in Associative
            replace-in-associative(
                container,
                :step(@path[*-1]),
                :$value,
                :$in-place
            );
        }
        when Positional
        {
            validate-positional-index(@path[*-1]);

            # splice in $value to Positional
            replace-in-positional(
                container,
                :step(@path[*-1]),
                :$value,
                :$in-place
            );
        }
        default
        {
            # invalid path request that should never happen
            # how did we get here?
            # if:
            #
            #     Crane.exists(container, :@path)
            #
            # and we have a path with 1 elem, then we must be entering
            # either an Associative or a Positional container
            # at($container, @path[0..^*-1])
            die '✗ Crane accident: replace operation failed, invalid path';
        }
    }
}

multi sub replace(
    \container,
    :@path! where *.elems == 0,
    :$value!,
    Bool :$in-place = False
) returns Any
{
    given container.WHAT
    {
        when Associative
        {
            replace-in-associative(container, :$value, :$in-place);
        }
        when Positional
        {
            replace-in-positional(container, :$value, :$in-place);
        }
        default
        {
            replace-in-any(container, :$value, :$in-place);
        }
    }
}

# Associative handling {{{

multi sub replace-in-associative(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool :$in-place = False
) returns Any
{
    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));
    at($root, @path){$step} = $value.WHAT ~~ Positional ?? $value.clone !! $value;
    $root;
}

multi sub replace-in-associative(
    \container,
    :$step!,
    :$value!,
    Bool :$in-place = False
) returns Any
{
    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));
    $root{$step} = $value.WHAT ~~ Positional ?? $value.clone !! $value;
    $root;
}

multi sub replace-in-associative(
    \container,
    :$value!,
    Bool :$in-place where *.not
) returns Any
{
    my $root = container.deepmap(*.clone);
    $root = $value;
    $root;
}

multi sub replace-in-associative(
    \container,
    :$value!,
    Bool :$in-place where *.so
) returns Any
{
    container = $value;
    container;
}

# end Associative handling }}}

# Positional handling {{{

multi sub replace-in-positional(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool :$in-place = False
) returns Any
{
    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));
    if $value ~~ Positional
    {
        my @value = $value;
        at($root, @path).splice($step, 1, $@value);
    }
    else
    {
        at($root, @path).splice($step, 1, $value);
    }
    |$root;
}

multi sub replace-in-positional(
    \container,
    :$step!,
    :$value!,
    Bool :$in-place = False
) returns Any
{
    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));
    if $value ~~ Positional
    {
        my @value = $value;
        $root.splice($step, 1, $@value);
    }
    else
    {
        $root.splice($step, 1, $value);
    }
    |$root;
}

multi sub replace-in-positional(
    \container,
    :$value!,
    Bool :$in-place where *.not
) returns Any
{
    my $root = container.deepmap(*.clone);
    $root = $value;
    |$root;
}

multi sub replace-in-positional(
    \container,
    :$value!,
    Bool :$in-place where *.so
) returns Any
{
    container = $value.WHAT ~~ Positional ?? $value.clone !! $value;
    |container;
}

# end Positional handling }}}

# Any handling {{{

multi sub replace-in-any(
    \container,
    :$value!,
    Bool :$in-place where *.not
) returns Any
{
    my $root = container.deepmap(*.clone);
    $root = $value;
    $root;
}

multi sub replace-in-any(
    \container,
    :$value!,
    Bool :$in-place where *.so
) returns Any
{
    container = $value;
    container;
}

# end Any handling }}}

# end replace }}}

# move {{{

method move(\container, :@from!, :@path!, Bool :$in-place = False) returns Any
{
    # the Crane.move operation will fail when @from or @path DNE in
    # $container with rules similar to JSON Patch
    # (X::Crane::MoveFromNotFound, X::Crane::MovePathNotFound,
    # X::Crane::MovePathOutOfRange)
    #
    # the Crane.move operation will fail when @from is to be moved into
    # one of its children (X::Crane::MoveParentToChild)
    #
    # the Crane.move operation will fail when @from[*-1] or @path[*-1]
    # is invalid for the container type according to Crane syntax rules:
    #
    #   if @from[*-2] is Positional, then @from[*-1] must be
    #   Int/WhateverCode
    #
    #   if @path[*-2] is Positional, then @path[*-1] must be
    #   Int/WhateverCode
    #
    # the Crane.move operation will fail when it's invalid to move the
    # value of $container at @from, such as when $container at @from is
    # an immutable value (X::Crane::MoveFrom::RO)
    #
    # the Crane.move operation will fail when it's invalid to set
    # $container at @path to the value of $container at @from,
    # such as when $container at @path is an immutable value
    # (X::Crane::MovePath::RO)
    CATCH
    {
        when X::Crane::AddPathNotFound
        {
            die X::Crane::MovePathNotFound.new;
        }
        when X::Crane::AddPathOutOfRange
        {
            die X::Crane::MovePathOutOfRange.new(
                :add-path-out-of-range(.message)
            );
        }
        when X::Crane::Add::RO
        {
            die X::Crane::MovePath::RO.new(:typename(.typename));
        }
        when X::Crane::GetPathNotFound
        {
            die X::Crane::MoveFromNotFound.new;
        }
        when X::Crane::Remove::RO
        {
            die X::Crane::MoveFrom::RO.new(:typename(.typename));
        }
    }

    # a location cannot be moved into one of its children
    if path-is-child-of-from(@from, @path)
    {
        die X::Crane::MoveParentToChild.new;
    }

    my $value = Crane.get(container, :path(@from), :v);

    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));
    Crane.remove($root, :path(@from), :in-place);
    Crane.add($root, :@path, :$value, :in-place);
    $root ~~ Positional ?? |$root !! $root;
}

# end move }}}

# copy {{{

method copy(\container, :@from!, :@path!, Bool :$in-place = False) returns Any
{
    # the Crane.copy operation will fail when @from or @path DNE in
    # $container with rules similar to JSON Patch
    # (X::Crane::CopyFromNotFound, X::Crane::CopyPathNotFound,
    # X::Crane::CopyPathOutOfRange)
    #
    # the Crane.copy operation will fail when @from is to be copied into
    # one of its children (X::Crane::CopyParentToChild)
    #
    # the Crane.copy operation will fail when @from[*-1] or @path[*-1]
    # is invalid for the container type according to Crane syntax rules:
    #
    #   if @from[*-2] is Positional, then @from[*-1] must be
    #   Int/WhateverCode
    #
    #   if @path[*-2] is Positional, then @path[*-1] must be
    #   Int/WhateverCode
    #
    # the Crane.copy operation will fail when it's invalid to set
    # $container at @path to the value of $container at @from,
    # such as when $container at @path is an immutable value
    # (X::Crane::CopyPath::RO)
    CATCH
    {
        when X::Crane::AddPathNotFound
        {
            die X::Crane::CopyPathNotFound.new;
        }
        when X::Crane::AddPathOutOfRange
        {
            die X::Crane::CopyPathOutOfRange.new(
                :add-path-out-of-range(.message)
            );
        }
        when X::Crane::Add::RO
        {
            die X::Crane::CopyPath::RO.new(:typename(.typename));
        }
        when X::Crane::GetPathNotFound
        {
            die X::Crane::CopyFromNotFound.new;
        }
    }

    # a location cannot be copied into one of its children
    if path-is-child-of-from(@from, @path)
    {
        die X::Crane::CopyParentToChild.new;
    }

    my $value = Crane.get(container, :path(@from), :v);

    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));
    Crane.add($root, :@path, :$value, :in-place);
    $root ~~ Positional ?? |$root !! $root;
}

# end copy }}}

# test {{{

method test($container, :@path!, :$value!) returns Bool
{
    unless Crane.exists($container, :@path)
    {
        die X::Crane::TestPathNotFound.new;
    }
    at($container, @path) eqv $value;
}

# end test }}}

# list {{{

multi method list(Associative $container, :@path) returns List
{
    list(at($container, @path));
}

multi method list(Positional $container, :@path) returns List
{
    list(at($container, @path));
}

multi method list($container) returns List
{
    list($container);
}

multi sub list(
    Associative $container where *.elems > 0,
    :@carry = ()
) returns List
{
    my @tree;
    for $container.keys -> $toplevel
    {
        my @current = |@carry, $toplevel;
        push @tree, |list(at($container, $toplevel), :carry(@current));
    }
    @tree.sort.List;
}

multi sub list(
    Positional $container where *.elems > 0,
    :@carry = ()
) returns List
{
    my @tree;
    for $container.keys -> $toplevel
    {
        my @current = |@carry, $toplevel;
        push @tree, |list(at($container, $toplevel), :carry(@current));
    }
    @tree.sort.List;
}

multi sub list($container, :@carry = ()) returns List
{
    List({:path(@carry), :value($container)});
}

# end list }}}

# flatten {{{

method flatten($container, :@path) returns Hash[Any,List]
{
    my %tree{List} = Crane.list($container,:@path).map({$_<path> => $_<value>});
}

# end flatten }}}

# transform {{{

method transform(
    \container,
    :@path!,
    :&with!,
    Bool :$in-place = False
) returns Any
{
    unless is-valid-callable-signature(&with)
    {
        die X::Crane::TransformCallableSignatureParams.new;
    }

    if @path.elems > 0
    {
        unless Crane.exists(container, :@path)
        {
            die X::Crane::TransformPathNotFound.new;
        }
    }

    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));

    my $value;
    try
    {
        CATCH
        {
            default
            {
                die X::Crane::TransformCallableRaisedException.new;
            }
        }
        $value = with(at($root, @path));
    }

    try
    {
        CATCH
        {
            when X::Crane::Replace::RO
            {
                die X::Crane::Transform::RO.new(:typename(.typename));
            }
            default
            {
                die '✗ Crane error: something went wrong during transform';
            }
        }
        Crane.replace($root, :@path, :$value, :in-place);
    }

    $root;
}

# end transform }}}

# patch {{{

method patch(\container, @patch, Bool :$in-place = False) returns Any
{
    my $root;
    $in-place ?? ($root := container) !! ($root = container.deepmap(*.clone));
    for @patch -> %patch
    {
        try
        {
            CATCH
            {
                when X::Crane::PatchAddFailed
                {
                    die X::Crane::Patch.new(:help-text(.message));
                }
                when X::Crane::PatchRemoveFailed
                {
                    die X::Crane::Patch.new(:help-text(.message));
                }
                when X::Crane::PatchReplaceFailed
                {
                    die X::Crane::Patch.new(:help-text(.message));
                }
                when X::Crane::PatchMoveFailed
                {
                    die X::Crane::Patch.new(:help-text(.message));
                }
                when X::Crane::PatchCopyFailed
                {
                    die X::Crane::Patch.new(:help-text(.message));
                }
                when X::Crane::PatchTestFailed
                {
                    die X::Crane::Patch.new(:help-text(.message));
                }
                default
                {
                    die '✗ Crane accident: patch operation failed';
                }
            }
            patch($root, %patch);
        }
    }
    $root;
}

# add
multi sub patch(
    \container,
    %patch (:$op! where $_ eq 'add', :@path!, :$value!)
)
{
    CATCH
    {
        default
        {
            X::Crane::PatchAddFailed.new.throw;
        }
    }
    Crane.add(container, :@path, :$value, :in-place);
}

# remove
multi sub patch(
    \container,
    %patch (:$op! where $_ eq 'remove', :@path!)
)
{
    CATCH
    {
        default
        {
            X::Crane::PatchRemoveFailed.new.throw;
        }
    }
    Crane.remove(container, :@path, :in-place);
}

# replace
multi sub patch(
    \container,
    %patch (:$op! where $_ eq 'replace', :@path!, :$value!)
)
{
    CATCH
    {
        default
        {
            X::Crane::PatchReplaceFailed.new.throw;
        }
    }
    Crane.replace(container, :@path, :$value, :in-place);
}

# move
multi sub patch(
    \container,
    %patch (:$op! where $_ eq 'move', :@from!, :@path!)
)
{
    CATCH
    {
        default
        {
            X::Crane::PatchMoveFailed.new.throw;
        }
    }
    Crane.move(container, :@from, :@path, :in-place);
}

# copy
multi sub patch(
    \container,
    %patch (:$op! where $_ eq 'copy', :@from!, :@path!)
)
{
    CATCH
    {
        default
        {
            X::Crane::PatchCopyFailed.new.throw;
        }
    }
    Crane.copy(container, :@from, :@path, :in-place);
}

# test
multi sub patch(
    \container,
    %patch (:$op! where $_ eq 'test', :@path!, :$value!)
)
{
    Crane.test(container, :@path, :$value)
        or X::Crane::PatchTestFailed.new.throw;
}

# end patch }}}

# helper functions {{{

# INT0P: Int where * >= 0 (valid)
# WEC: WhateverCode (valid)
# INTM: Int where * < 0 (invalid)
# OTHER: everything else (invalid)
enum Classifier <INT0P INTM OTHER WEC>;

# classify positional index requests for better error messages
multi sub get-positional-index-classifier(Int $ where * >= 0) returns Classifier
{
    INT0P;
}
multi sub get-positional-index-classifier(Int $ where * < 0) returns Classifier
{
    INTM;
}
multi sub get-positional-index-classifier(WhateverCode $) returns Classifier
{
    WEC;
}
multi sub get-positional-index-classifier($) returns Classifier
{
    OTHER;
}

multi sub test-positional-index-classifier(INT0P) {*}
multi sub test-positional-index-classifier(WEC) {*}
multi sub test-positional-index-classifier(INTM)
{
    die X::Crane::PositionalIndexInvalid.new(:classifier<INTM>);
}
multi sub test-positional-index-classifier(OTHER)
{
    die X::Crane::PositionalIndexInvalid.new(:classifier<OTHER>);
}

sub validate-positional-index($step)
{
    test-positional-index-classifier(get-positional-index-classifier($step));
}

multi sub path-is-child-of-from(
    @from,
    @path where *.elems == @from.elems
) returns Bool
{
    # @path can't be child of @from if both are at the same depth
    False;
}

multi sub path-is-child-of-from(
    @from,
    @path where *.elems < @from.elems
) returns Bool
{
    # @path can't be child of @from if @path is shallower than @from
    False;
}

# @path is at deeper level than @from
# verify @from[$_] !eqv @path[$_] for 0..@from.end
multi sub path-is-child-of-from(@from, @path) returns Bool
{
    (@from[$_] eqv @path[$_] for 0..@from.end).grep(*.so).elems == @from.elems;
}

sub is-valid-callable-signature(&c) returns Bool
{
    &c.signature.params.elems == 1
        && &c.signature.params.grep(*.positional).elems == 1;
}

# end helper functions }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
