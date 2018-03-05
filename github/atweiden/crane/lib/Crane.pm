use v6;
use X::Crane;
unit class Crane;

# sub at {{{

sub at(
    $container,
    *@steps
    --> Any
) is rw is export
{
    my $root := $container;
    return-rw _at($root, @steps);
}

# --- type Associative handling {{{

multi sub _at(
    Associative:D $container,
    @steps where { .elems() > 1 and $container{@steps[0]}:exists }
    --> Any
) is rw
{
    my $root := $container;
    $root := $root{@steps[0]};
    return-rw _at($root, @steps[1..*]);
}

multi sub _at(
    Associative:D $container,
    @steps where { .elems() > 1 }
    --> Nil
) is rw
{
    die(X::Crane::AssociativeKeyDNE.new());
}

multi sub _at(
    Associative:D $container,
    @steps where { .elems() == 1 and $container{@steps[0]}:exists }
    --> Any
) is rw
{
    my $root := $container;
    $root := $root{@steps[0]};
    return-rw $root;
}

multi sub _at(
    Associative:D $container,
    @steps where { .elems() == 1 }
    --> Nil
) is rw
{
    die(X::Crane::AssociativeKeyDNE.new());
}

multi sub _at(
    Associative:D $container,
    @steps where { .elems() == 0 }
    --> Any
) is rw
{
    return-rw $container;
}

multi sub _at(
    Associative:D $container
    --> Any
) is rw
{
    return-rw $container;
}

# --- end type Associative handling }}}
# --- type Positional handling {{{

# XXX may need waterfall handling here
multi sub _at(
    Positional:D $container,
    @steps where {
        .elems() > 1
            and is-valid-positional-index(@steps[0])
            and $container[@steps[0]]:exists
    }
    --> Any
) is rw
{
    my $root := $container;
    $root := $root[@steps[0]];
    return-rw _at($root, @steps[1..*]);
}

multi sub _at(
    Positional:D $container,
    @steps where { .elems() > 1 }
    --> Nil
) is rw
{
    die(X::Crane::PositionalIndexDNE.new());
}

multi sub _at(
    Positional:D $container,
    @steps where {
        .elems() == 1
            and is-valid-positional-index(@steps[0])
            and $container[@steps[0]]:exists
    }
    --> Any
) is rw
{
    my $root := $container;
    $root := $root[@steps[0]];
    return-rw $root;
}

multi sub _at(
    Positional:D $container,
    @steps where { .elems() == 1 }
    --> Nil
) is rw
{
    die(X::Crane::PositionalIndexDNE.new());
}

multi sub _at(
    Positional:D $container,
    @steps where *.elems() == 0
    --> Any
) is rw
{
    return-rw $container;
}


multi sub _at(
    Positional:D $container
    --> Any
) is rw
{
    return-rw $container;
}

# --- end type Positional handling }}}

# end sub at }}}
# sub in {{{

sub in(
    \container,
    *@steps
    --> Any
) is rw is export
{
    return-rw _in(container, @steps);
}

# --- type Associative handling {{{

multi sub _in(
    Associative:D \container,
    @steps where *.elems() > 1
    --> Any
) is rw
{
    return-rw _in(container{@steps[0]}, @steps[1..*]);
}

multi sub _in(
    Associative:D \container,
    @steps where *.elems() == 1
    --> Any
) is rw
{
    return-rw container{@steps[0]};
}

multi sub _in(
    Associative:D \container,
    @steps where *.elems() == 0
    --> Any
) is rw
{
    return-rw container;
}

multi sub _in(
    Associative:D \container
    --> Any
) is rw
{
    return-rw container;
}

# --- end type Associative handling }}}
# --- type Positional handling {{{

multi sub _in(
    Positional:D \container,
    @steps where { .elems() > 1 and is-valid-positional-index(@steps[0]) }
    --> Any
) is rw
{
    return-rw _in(container[@steps[0]], @steps[1..*]);
}

multi sub _in(
    Positional:D \container,
    @steps where { .elems() == 1 and is-valid-positional-index(@steps[0]) }
    --> Any
) is rw
{
    return-rw container[@steps[0]];
}

multi sub _in(
    Positional:D \container,
    @steps where { .elems() == 0 }
    --> Any
) is rw
{
    return-rw container;
}

multi sub _in(
    Positional:D \container
    --> Any
) is rw
{
    return-rw container;
}

# --- end type Positional handling }}}
# --- type Any handling {{{

multi sub _in(
    \container,
    @steps where { .elems() > 1 and @steps[0] ~~ Int and @steps[0] >= 0 }
    --> Any
) is rw
{
    return-rw _in(container[@steps[0]], @steps[1..*]);
}

multi sub _in(
    \container,
    @steps where { .elems() > 1 and @steps[0] ~~ WhateverCode }
    --> Any
) is rw
{
    return-rw _in(container[@steps[0]], @steps[1..*]);
}

multi sub _in(
    \container,
    @steps where { .elems() > 1 }
    --> Any
) is rw
{
    return-rw _in(container{@steps[0]}, @steps[1..*]);
}

multi sub _in(
    \container,
    @steps where { .elems() == 1 and @steps[0] ~~ Int and @steps[0] >= 0 }
    --> Any
) is rw
{
    return-rw container[@steps[0]];
}

multi sub _in(
    \container,
    @steps where { .elems() == 1 and @steps[0] ~~ WhateverCode }
    --> Any
) is rw
{
    return-rw container[@steps[0]];
}

multi sub _in(
    \container,
    @steps where { .elems() == 1 }
    --> Any
) is rw
{
    return-rw container{@steps[0]};
}

multi sub _in(
    \container,
    @steps where *.elems() == 0
    --> Any
) is rw
{
    return-rw container;
}

multi sub _in(
    \container
    --> Any
) is rw
{
    return-rw container;
}

# --- end type Any handling }}}

# end sub in }}}

# method exists {{{

method exists(
    $container,
    :@path!,
    Bool :k($) = True,
    Bool :$v
    --> Bool:D
)
{
    exists($container, :@path, :k, :$v);
}

multi sub exists(
    $container,
    :@path!,
    Bool :k($) = True,
    Bool:D :v($)! where *.so
    --> Bool:D
)
{
    exists-value($container, @path);
}

multi sub exists(
    $container,
    :@path!,
    Bool :k($) = True,
    Bool :v($)
    --> Bool:D
)
{
    exists-key($container, @path);
}

# --- sub exists-key {{{

multi sub exists-key(
    $container,
    @path where { .elems() > 1 and exists-key($container, [@path[0]]) }
    --> Bool:D
)
{
    exists-key(at($container, @path[0]), @path[1..*]);
}

multi sub exists-key(
    $container,
    @path where { .elems() > 1 }
    --> Bool:D
)
{
    False;
}

multi sub exists-key(
    Associative:D $container,
    @path where { .elems() == 1 }
    --> Bool:D
)
{
    $container{@path[0]}:exists;
}

multi sub exists-key(
    Associative:D $container,
    @path where { .elems() == 0 }
    --> Nil
)
{
    die(X::Crane::ExistsRootContainerKey.new());
}

multi sub exists-key(
    Positional:D $container,
    @path where { .elems() == 1 and is-valid-positional-index(@path[0]) }
    --> Bool:D
)
{
    $container[@path[0]]:exists;
}

multi sub exists-key(
    Positional:D $container,
    @path where { .elems() == 0 }
    --> Nil
)
{
    die(X::Crane::ExistsRootContainerKey.new());
}

multi sub exists-key(
    $container,
    @path where { .elems() > 0 }
    --> Bool:D
)
{
    False;
}

# --- end sub exists-key }}}
# --- sub exists-value {{{

multi sub exists-value(
    $container,
    @path where { .elems() > 1 and exists-value($container, [@path[0]]) }
    --> Bool:D
)
{
    exists-value(at($container, @path[0]), @path[1..*]);
}

multi sub exists-value(
    $container,
    @path where { .elems() > 1 }
    --> Bool:D
)
{
    False;
}

multi sub exists-value(
    Associative:D $container,
    @path where { .elems() == 1 }
    --> Bool:D
)
{
    $container{@path[0]}.defined();
}

multi sub exists-value(
    Associative:D $container,
    @path where { .elems() == 0 }
    --> Bool:D
)
{
    $container.defined();
}

multi sub exists-value(
    Positional:D $container,
    @path where { .elems() == 1 and is-valid-positional-index(@path[0]) }
    --> Bool:D
)
{
    $container[@path[0]].defined();
}

multi sub exists-value(
    Positional:D $container,
    @path where { .elems() == 0 }
    --> Bool:D
)
{
    $container.defined();
}

multi sub exists-value(
    $container,
    @path where { .elems() > 0 }
    --> Bool:D
)
{
    False;
}

# --- end sub exists-value }}}

# end method exists }}}
# method get {{{

method get(
    $container,
    :@path!,
    *%h (
        Bool :$k,
        Bool :$v,
        Bool :$p
    )
    --> Any:D
)
{
    get($container, :@path, |%h);
}

multi sub get(
    $container,
    :@path!,
    Bool:D :k($)! where *.so(),
    Bool :v($) where *.not(),
    Bool :p($) where *.not()
    --> Any:D
)
{
    get-key($container, @path);
}

multi sub get(
    $container,
    :@path!,
    Bool :k($) where *.not(),
    Bool:D :v($) = True,
    Bool :p($) where *.not()
    --> Any:D
)
{
    get-value($container, @path);
}

multi sub get(
    $container,
    :@path!,
    Bool :k($) where *.not(),
    Bool :v($) where *.not(),
    Bool:D :p($)! where *.so()
    --> Any:D
)
{
    get-pair($container, @path);
}

# --- sub get-key {{{

multi sub get-key(
    $container,
    @path where { .elems() > 1 and exists-key($container, [@path[0]]) }
    --> Any:D
)
{
    get-key(at($container, @path[0]), @path[1..*]);
}

multi sub get-key(
    $container,
    @path where { .elems() > 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new());
}

multi sub get-key(
    Associative:D $container,
    @path where { .elems() == 1 and exists-key($container, [@path[0]]) }
    --> Any:D
)
{
    $container{@path[0]}:!k;
}

multi sub get-key(
    Associative:D $container,
    @path where { .elems() == 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new());
}

multi sub get-key(
    Associative:D $container,
    @path where { .elems() == 0 }
    --> Nil
)
{
    die(X::Crane::GetRootContainerKey.new());
}

multi sub get-key(
    Positional:D $container,
    @path where {
        .elems() == 1
            and is-valid-positional-index(@path[0])
            and exists-key($container, [@path[0]])
    }
    --> Any:D
)
{
    $container[@path[0]]:!k;
}

multi sub get-key(
    Positional:D $container,
    @path where { .elems() == 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new());
}

multi sub get-key(
    Positional:D $container,
    @path where { .elems() == 0 }
    --> Nil
)
{
    die(X::Crane::GetRootContainerKey.new());
}

multi sub get-key(
    $container,
    @path where { .elems() > 0 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new());
}

multi sub get-key(
    $container,
    @path where { .elems() == 0 }
    --> Nil
)
{
    die(X::Crane::GetRootContainerKey.new());
}

# --- end sub get-key }}}
# --- sub get-pair {{{

multi sub get-pair(
    $container,
    @path where { .elems() > 1 and exists-key($container, [@path[0]]) }
    --> Any:D
)
{
    get-pair(at($container, @path[0]), @path[1..*]);
}

multi sub get-pair(
    $container,
    @path where { .elems() > 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new());
}

multi sub get-pair(
    Associative:D $container,
    @path where { .elems() == 1 and exists-key($container, [@path[0]]) }
    --> Any:D
)
{
    $container{@path[0]}:!p;
}

multi sub get-pair(
    Associative:D $container,
    @path where { .elems() == 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new());
}

multi sub get-pair(
    Associative:D $container,
    @path where { .elems() == 0 }
    --> Nil
)
{
    die(X::Crane::GetRootContainerKey.new());
}

multi sub get-pair(
    Positional:D $container,
    @path where {
        .elems() == 1
            and is-valid-positional-index(@path[0])
            and exists-key($container, [@path[0]])
    }
    --> Any:D
)
{
    $container[@path[0]]:!p;
}

multi sub get-pair(
    Positional:D $container,
    @path where { .elems() == 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new());
}

multi sub get-pair(
    Positional:D $container,
    @path where { .elems() == 0 }
    --> Nil
)
{
    die(X::Crane::GetRootContainerKey.new());
}

multi sub get-pair(
    $container,
    @path where { .elems() > 0 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new());
}

multi sub get-pair(
    $container,
    @path where { .elems() == 0 }
    --> Nil
)
{
    die(X::Crane::GetRootContainerKey.new());
}

# --- end sub get-pair }}}
# --- sub get-value {{{

multi sub get-value(
    $container,
    @path where { .elems() > 1 and exists-key($container, [@path[0]]) }
    --> Any:D
)
{
    get-value(at($container, @path[0]), @path[1..*]);
}

multi sub get-value(
    $container,
    @path where { .elems() > 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new());
}

multi sub get-value(
    Associative:D $container,
    @path where { .elems() == 1 and exists-key($container, [@path[0]]) }
    --> Any:D
)
{
    $container{@path[0]}:!v;
}

multi sub get-value(
    Associative:D $container,
    @path where { .elems() == 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new());
}

multi sub get-value(
    Associative:D $container,
    @path where { .elems() == 0 }
    --> Any:D
)
{
    $container;
}

multi sub get-value(
    Positional:D $container,
    @path where {
        .elems() == 1
            and is-valid-positional-index(@path[0])
            and exists-key($container, [@path[0]])
    }
    --> Any:D
)
{
    $container[@path[0]]:!v;
}

multi sub get-value(
    Positional:D $container,
    @path where { .elems() == 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new());
}

multi sub get-value(
    Positional:D $container,
    @path where { .elems() == 0 }
    --> Any:D
)
{
    $container;
}

multi sub get-value(
    $container,
    @path where { .elems() > 0 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new());
}

multi sub get-value(
    $container,
    @path where { .elems() == 0 }
    --> Any:D
)
{
    $container;
}

# --- end sub get-value }}}

# end method get }}}

# method set {{{

method set(
    \container,
    :@path!,
    :$value!
    --> Any:D
)
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
        { die(X::Crane::OpSet::RO.new(:typename(.typename()))) }
    }

    set(container, :@path, :$value);
}

multi sub set(
    Positional \container,
    :@path!,
    :$value! where { $_ ~~ Positional }
    --> Any:D
)
{
    in(container, @path) = $value.clone();
    |container;
}

multi sub set(
    \container,
    :@path!,
    :$value! where { $_ ~~ Positional }
    --> Any:D
)
{
    in(container, @path) = $value.clone();
    container;
}

multi sub set(
    Positional \container,
    :@path!,
    :$value!
    --> Any:D
)
{
    in(container, @path) = $value;
    |container;
}

multi sub set(
    \container,
    :@path!,
    :$value!
    --> Any:D
)
{
    in(container, @path) = $value;
    container;
}

# end method set }}}

# method add {{{

method add(
    \container,
    :@path!,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
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
        when X::Multi::NoMatch
        {
            my rule cannot-resolve-caller-splice-list
            { 'Cannot resolve caller splice(List' }
            if .message() ~~ &cannot-resolve-caller-splice-list
            { die(X::Crane::Add::RO.new(:typename<List>)) }
        }
        when X::Assignment::RO
        { die(X::Crane::Add::RO.new(:typename(.typename()))) }
        when X::Method::NotFound
        {
            my rule no-such-method-splice
            { No such method \'splice\' for invocant of type \'(\w+)\' }
            if .message() ~~ &no-such-method-splice
            { die(X::Crane::Add::RO.new(:typename(~$0))) }
        }
        when X::OutOfRange
        { die(X::Crane::AddPathOutOfRange.new(:operation<add>, :out-of-range($_))) }
    }

    # route add operation based on path length
    add(container, :@path, :$value, :$in-place);
}

multi sub add(
    \container,
    :@path! where *.elems() > 1,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    unless Crane.exists(container, :path(@path[0..^*-1]), :v)
    { die(X::Crane::AddPathNotFound.new()) }
    my $what = at(container, @path[0..^*-1]).WHAT;
    add($what, container, :@path, :$value, :$in-place);
}

multi sub add(
    Associative,
    \container,
    :@path! where *.elems() > 1,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    add-to-associative(
        container,
        :path(@path[0..^*-1]),
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub add(
    Positional,
    \container,
    :@path! where *.elems() > 1,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    is-valid-positional-index(@path[*-1]);
    add-to-positional(
        container,
        :path(@path[0..^*-1]),
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub add(
    Any,
    \container,
    :@path! where *.elems() > 1,
    :$value!,
    Bool :$in-place = False
    --> Nil
)
{
    die('✗ Crane accident: add operation failed, invalid path');
}

multi sub add(
    Associative \container,
    :@path! where *.elems() == 1,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    unless Crane.exists(container, :path(), :v)
    { die(X::Crane::AddPathNotFound.new()) }
    add-to-associative(
        container,
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub add(
    Positional \container,
    :@path! where *.elems() == 1,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    unless Crane.exists(container, :path(), :v)
    { die(X::Crane::AddPathNotFound.new()) }
    is-valid-positional-index(@path[*-1]);
    add-to-positional(
        container,
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub add(
    \container,
    :@path! where *.elems() == 1,
    :$value!,
    Bool :$in-place = False
    --> Nil
)
{
    unless Crane.exists(container, :path(), :v)
    { die(X::Crane::AddPathNotFound.new()) }
    die('✗ Crane accident: add operation failed, invalid path');
}

multi sub add(
    Associative \container,
    :@path! where *.elems() == 0,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    add-to-associative(container, :$value, :$in-place);
}

multi sub add(
    Positional \container,
    :@path! where *.elems() == 0,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    add-to-positional(container, :$value, :$in-place);
}

multi sub add(
    \container,
    :@path! where *.elems() == 0,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    add-to-any(container, :$value, :$in-place);
}

# --- type Associative handling {{{

multi sub add-to-associative(
    \container,
    :@path!,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    at($root, @path){$step} = $value.clone();
    $root;
}

multi sub add-to-associative(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    at($root, @path){$step} = $value;
    $root;
}

multi sub add-to-associative(
    \container,
    :@path!,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    at($root, @path){$step} = $value.clone();
    $root;
}

multi sub add-to-associative(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    at($root, @path){$step} = $value;
    $root;
}

multi sub add-to-associative(
    \container,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where *.so
    --> Any:D
)
{
    my $root := container;
    $root{$step} = $value.clone();
    $root;
}

multi sub add-to-associative(
    \container,
    :$step!,
    :$value!,
    Bool:D :in-place($)! where *.so
    --> Any:D
)
{
    my $root := container;
    $root{$step} = $value;
    $root;
}

multi sub add-to-associative(
    \container,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    $root{$step} = $value.clone();
    $root;
}

multi sub add-to-associative(
    \container,
    :$step!,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    $root{$step} = $value;
    $root;
}

multi sub add-to-associative(
    \container,
    :$value!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    container = $value;
    container;
}

multi sub add-to-associative(
    \container,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    $root = $value;
    $root;
}

# --- end type Associative handling }}}
# --- type Positional handling {{{

# XXX when $value is a multi-dimensional array, splice ruins it by
# flattening it (splice's signature is *@target-to-splice-in)
#
# we have to inspect the structure of $value and work around this to
# provide a sane api
#
# weirdly, using C<where {$_ ~~ Positional}> makes a difference in type
# checking compared to C<Positional :$value!>
multi sub add-to-positional(
    \container,
    :@path!,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    my @value = $value;
    at($root, @path).splice($step, 0, $@value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    at($root, @path).splice($step, 0, $value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :@path!,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    my @value = $value;
    at($root, @path).splice($step, 0, $@value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    at($root, @path).splice($step, 0, $value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    my @value = $value;
    $root.splice($step, 0, $@value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :$step!,
    :$value!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    $root.splice($step, 0, $value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    my @value = $value;
    $root.splice($step, 0, $@value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :$step!,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    $root.splice($step, 0, $value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    container = $value.clone();
    |container;
}

multi sub add-to-positional(
    \container,
    :$value!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    container = $value;
    |container;
}

multi sub add-to-positional(
    \container,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    $root = $value.clone();
    |$root;
}

multi sub add-to-positional(
    \container,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    $root = $value;
    |$root;
}

# --- end type Positional handling }}}
# --- type Any handling {{{

multi sub add-to-any(
    \container,
    :$value!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    container = $value;
    container;
}

multi sub add-to-any(
    \container,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    $root = $value;
    $root;
}

# --- end type Any handling }}}

# end method add }}}
# method remove {{{

method remove(
    \container,
    :@path!,
    Bool :$in-place = False
    --> Any
)
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
            { Can not remove [values|elements] from a (\w+) }
            if .payload() ~~ &can-not-remove
            { die(X::Crane::Remove::RO.new(:typename(~$0))) }
        }
        when X::Multi::NoMatch
        {
            my rule cannot-resolve-caller-splice-list
            { 'Cannot resolve caller splice(List' }
            if .message() ~~ &cannot-resolve-caller-splice-list
            { die(X::Crane::Remove::RO.new(:typename<List>)) }
        }
        when X::Method::NotFound
        {
            my rule no-such-method-splice
            { No such method \'splice\' for invocant of type \'(\w+)\' }
            if .message() ~~ &no-such-method-splice
            { die(X::Crane::Remove::RO.new(:typename(~$0))) }
        }
    }

    # route remove operation based on path length
    remove(container, :@path, :$in-place);
}

multi sub remove(
    \container,
    :@path! where *.elems() > 1,
    Bool :$in-place = False
    --> Any
)
{
    unless Crane.exists(container, :@path)
    { die(X::Crane::RemovePathNotFound.new()) }
    my $what = at(container, @path[0..^*-1]).WHAT;
    remove($what, container, :@path, :$in-place);
}

multi sub remove(
    Associative,
    \container,
    :@path! where *.elems() > 1,
    Bool :$in-place = False
    --> Any
)
{
    remove-from-associative(
        container,
        :path(@path[0..^*-1]),
        :step(@path[*-1]),
        :$in-place
    );
}

multi sub remove(
    Positional,
    \container,
    :@path! where *.elems() > 1,
    Bool :$in-place = False
    --> Any
)
{
    is-valid-positional-index(@path[*-1]);
    remove-from-positional(
        container,
        :path(@path[0..^*-1]),
        :step(@path[*-1]),
        :$in-place
    );
}

multi sub remove(
    Any,
    \container,
    :@path! where *.elems() > 1,
    Bool :$in-place = False
    --> Nil
)
{
    die('✗ Crane accident: remove operation failed, invalid path');
}

multi sub remove(
    Associative \container,
    :@path! where *.elems() == 1,
    Bool :$in-place = False
    --> Any
)
{
    unless Crane.exists(container, :@path)
    { die(X::Crane::RemovePathNotFound.new()) }
    remove-from-associative(container, :step(@path[*-1]), :$in-place);
}

multi sub remove(
    Positional \container,
    :@path! where *.elems() == 1,
    Bool :$in-place = False
    --> Any
)
{
    unless Crane.exists(container, :@path)
    { die(X::Crane::RemovePathNotFound.new()) }
    is-valid-positional-index(@path[*-1]);
    remove-from-positional(container, :step(@path[*-1]), :$in-place);
}

multi sub remove(
    \container,
    :@path! where *.elems() == 1,
    Bool :$in-place = False
    --> Nil
)
{
    unless Crane.exists(container, :@path)
    { die(X::Crane::RemovePathNotFound.new()) }
    die('✗ Crane accident: remove operation failed, invalid path');
}

multi sub remove(
    Associative \container,
    :@path! where *.elems() == 0,
    Bool :$in-place = False
    --> Any
)
{
    remove-from-associative(container, :$in-place);
}

multi sub remove(
    Positional \container,
    :@path! where *.elems() == 0,
    Bool :$in-place = False
    --> Any
)
{
    remove-from-positional(container, :$in-place);
}

multi sub remove(
    \container,
    :@path! where *.elems() == 0,
    Bool :$in-place = False
    --> Any
)
{
    remove-from-any(container, :$in-place);
}

# --- type Associative handling {{{

multi sub remove-from-associative(
    \container,
    :@path!,
    :$step!,
    Bool:D :in-place($)! where *.so()
    --> Any
)
{
    my $root := container;
    at($root, @path){$step}:delete;
    $root;
}

multi sub remove-from-associative(
    \container,
    :@path!,
    :$step!,
    Bool :in-place($)
    --> Any
)
{
    my $root = container.deepmap(*.clone());
    at($root, @path){$step}:delete;
    $root;
}

multi sub remove-from-associative(
    \container,
    :$step!,
    Bool:D :in-place($)! where *.so()
    --> Any
)
{
    my $root := container;
    $root{$step}:delete;
    $root;
}

multi sub remove-from-associative(
    \container,
    :$step!,
    Bool :in-place($)
    --> Any
)
{
    my $root = container.deepmap(*.clone());
    $root{$step}:delete;
    $root;
}

multi sub remove-from-associative(
    \container,
    Bool:D :in-place($)! where *.so()
    --> Any
)
{
    container = Empty;
    container;
}

multi sub remove-from-associative(
    \container,
    Bool :in-place($)
    --> Any
)
{
    my $root = container.deepmap(*.clone());
    $root = Empty;
    $root;
}

# --- end type Associative handling }}}
# --- type Positional handling {{{

multi sub remove-from-positional(
    \container,
    :@path!,
    :$step!,
    Bool:D :in-place($)! where *.so()
    --> Any
)
{
    my $root := container;
    at($root, @path).splice($step, 1);
    |$root;
}

multi sub remove-from-positional(
    \container,
    :@path!,
    :$step!,
    Bool :in-place($)
    --> Any
)
{
    my $root = container.deepmap(*.clone());
    at($root, @path).splice($step, 1);
    |$root;
}

multi sub remove-from-positional(
    \container,
    :$step!,
    Bool:D :in-place($)! where *.so()
    --> Any
)
{
    my $root := container;
    $root.splice($step, 1);
    |$root;
}

multi sub remove-from-positional(
    \container,
    :$step!,
    Bool :in-place($)
    --> Any
)
{
    my $root = container.deepmap(*.clone());
    $root.splice($step, 1);
    |$root;
}

multi sub remove-from-positional(
    \container,
    Bool:D :in-place($)! where *.so()
    --> Any
)
{
    container = Empty;
    |container;
}

multi sub remove-from-positional(
    \container,
    Bool :in-place($)
    --> Any
)
{
    my $root = container.deepmap(*.clone());
    $root = Empty;
    |$root;
}

# --- end type Positional handling }}}
# --- type Any handling {{{

multi sub remove-from-any(
    \container,
    Bool:D :in-place($)! where *.so()
    --> Any
)
{
    container = Nil;
    container;
}

multi sub remove-from-any(
    \container,
    Bool :in-place($)
    --> Any
)
{
    my $root = container.deepmap(*.clone());
    $root = Nil;
    $root;
}

# --- end type Any handling }}}

# end method remove }}}
# method replace {{{

method replace(
    \container,
    :@path!,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
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
        { die(X::Crane::Replace::RO.new(:typename(.typename))) }
        when X::Multi::NoMatch
        {
            my rule cannot-resolve-caller-splice-list
            { 'Cannot resolve caller splice(List' }
            if .message() ~~ &cannot-resolve-caller-splice-list
            { die(X::Crane::Replace::RO.new(:typename<List>)) }
        }
        when X::Method::NotFound
        {
            my rule no-such-method-splice
            { No such method \'splice\' for invocant of type \'(\w+)\' }
            if .message() ~~ &no-such-method-splice
            { die(X::Crane::Replace::RO.new(:typename(~$0))) }
        }
    }

    # route replace operation based on path length
    replace(container, :@path, :$value, :$in-place);
}

multi sub replace(
    \container,
    :@path! where *.elems() > 1,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    unless Crane.exists(container, :@path)
    { die(X::Crane::ReplacePathNotFound.new()) }
    my $what = at(container, @path[0..^*-1]).WHAT;
    replace($what, container, :@path, :$value, :$in-place);
}

multi sub replace(
    Associative,
    \container,
    :@path! where *.elems() > 1,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    replace-in-associative(
        container,
        :path(@path[0..^*-1]),
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub replace(
    Positional,
    \container,
    :@path! where *.elems() > 1,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    is-valid-positional-index(@path[*-1]);
    replace-in-positional(
        container,
        :path(@path[0..^*-1]),
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub replace(
    Any,
    \container,
    :@path! where *.elems() > 1,
    :$value!,
    Bool :$in-place = False
    --> Nil
)
{
    die('✗ Crane accident: replace operation failed, invalid path');
}

multi sub replace(
    Associative \container,
    :@path! where *.elems() == 1,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    unless Crane.exists(container, :@path)
    { die(X::Crane::ReplacePathNotFound.new()) }
    replace-in-associative(
        container,
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub replace(
    Positional \container,
    :@path! where *.elems() == 1,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    unless Crane.exists(container, :@path)
    { die(X::Crane::ReplacePathNotFound.new()) }
    is-valid-positional-index(@path[*-1]);
    replace-in-positional(
        container,
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub replace(
    \container,
    :@path! where *.elems() == 1,
    :$value!,
    Bool :$in-place = False
    --> Nil
)
{
    unless Crane.exists(container, :@path)
    { die(X::Crane::ReplacePathNotFound.new()) }
    die('✗ Crane accident: replace operation failed, invalid path');
}

multi sub replace(
    Associative \container,
    :@path! where *.elems() == 0,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    replace-in-associative(container, :$value, :$in-place);
}

multi sub replace(
    Positional \container,
    :@path! where *.elems() == 0,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    replace-in-positional(container, :$value, :$in-place);
}

multi sub replace(
    \container,
    :@path! where *.elems() == 0,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    replace-in-any(container, :$value, :$in-place);
}

# --- type Associative handling {{{

multi sub replace-in-associative(
    \container,
    :@path!,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    at($root, @path){$step} = $value.clone();
    $root;
}

multi sub replace-in-associative(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    at($root, @path){$step} = $value;
    $root;
}

multi sub replace-in-associative(
    \container,
    :@path!,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    at($root, @path){$step} = $value.clone();
    $root;
}

multi sub replace-in-associative(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    at($root, @path){$step} = $value;
    $root;
}

multi sub replace-in-associative(
    \container,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    $root{$step} = $value.clone();
    $root;
}

multi sub replace-in-associative(
    \container,
    :$step!,
    :$value!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    $root{$step} = $value;
    $root;
}

multi sub replace-in-associative(
    \container,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    $root{$step} = $value.clone();
    $root;
}

multi sub replace-in-associative(
    \container,
    :$step!,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    $root{$step} = $value;
    $root;
}

multi sub replace-in-associative(
    \container,
    :$value!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    container = $value;
    container;
}

multi sub replace-in-associative(
    \container,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    $root = $value;
    $root;
}

# --- end type Associative handling }}}
# --- type Positional handling {{{

multi sub replace-in-positional(
    \container,
    :@path!,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    my @value = $value;
    at($root, @path).splice($step, 1, $@value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    at($root, @path).splice($step, 1, $value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :@path!,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    my @value = $value;
    at($root, @path).splice($step, 1, $@value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    at($root, @path).splice($step, 1, $value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    my @value = $value;
    $root.splice($step, 1, $@value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :$step!,
    :$value!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    $root.splice($step, 1, $value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    my @value = $value;
    $root.splice($step, 1, $@value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :$step!,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    $root.splice($step, 1, $value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    container = $value.clone();
    |container;
}

multi sub replace-in-positional(
    \container,
    :$value!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    container = $value;
    |container;
}

multi sub replace-in-positional(
    \container,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    $root = $value;
    |$root;
}

# --- end type Positional handling }}}
# --- type Any handling {{{

multi sub replace-in-any(
    \container,
    :$value!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    container = $value;
    container;
}

multi sub replace-in-any(
    \container,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    $root = $value;
    $root;
}

# --- end type Any handling }}}

# end method replace }}}

# method move {{{

method move(
    \container,
    :@from!,
    :@path!,
    Bool :$in-place = False
    --> Any:D
)
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
        { die(X::Crane::MovePathNotFound.new()) }
        when X::Crane::AddPathOutOfRange
        { die(X::Crane::MovePathOutOfRange.new(:add-path-out-of-range(.message()))) }
        when X::Crane::Add::RO
        { die(X::Crane::MovePath::RO.new(:typename(.typename()))) }
        when X::Crane::GetPathNotFound
        { die(X::Crane::MoveFromNotFound.new()) }
        when X::Crane::Remove::RO
        { die(X::Crane::MoveFrom::RO.new(:typename(.typename))) }
    }

    # a location cannot be moved into one of its children
    if path-is-child-of-from(@from, @path)
    { die(X::Crane::MoveParentToChild.new()) }
    move(container, :@from, :@path, :$in-place);
}

multi sub move(
    Positional \container,
    :@from!,
    :@path!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $value = Crane.get(container, :path(@from), :v);
    my $root := container;
    Crane.remove($root, :path(@from), :in-place);
    Crane.add($root, :@path, :$value, :in-place);
    |$root;
}

multi sub move(
    \container,
    :@from!,
    :@path!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $value = Crane.get(container, :path(@from), :v);
    my $root := container;
    Crane.remove($root, :path(@from), :in-place);
    Crane.add($root, :@path, :$value, :in-place);
    $root;
}

multi sub move(
    Positional \container,
    :@from!,
    :@path!,
    Bool :in-place($)
    --> Any:D
)
{
    my $value = Crane.get(container, :path(@from), :v);
    my $root = container.deepmap(*.clone());
    Crane.remove($root, :path(@from), :in-place);
    Crane.add($root, :@path, :$value, :in-place);
    |$root;
}

multi sub move(
    \container,
    :@from!,
    :@path!,
    Bool :in-place($)
    --> Any:D
)
{
    my $value = Crane.get(container, :path(@from), :v);
    my $root = container.deepmap(*.clone());
    Crane.remove($root, :path(@from), :in-place);
    Crane.add($root, :@path, :$value, :in-place);
    $root;
}

# end method move }}}
# method copy {{{

method copy(
    \container,
    :@from!,
    :@path!,
    Bool :$in-place = False
    --> Any:D
)
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
        { die(X::Crane::CopyPathNotFound.new()) }
        when X::Crane::AddPathOutOfRange
        { die(X::Crane::CopyPathOutOfRange.new(:add-path-out-of-range(.message))) }
        when X::Crane::Add::RO
        { die(X::Crane::CopyPath::RO.new(:typename(.typename))) }
        when X::Crane::GetPathNotFound
        { die(X::Crane::CopyFromNotFound.new()) }
    }

    # a location cannot be copied into one of its children
    if path-is-child-of-from(@from, @path)
    { die(X::Crane::CopyParentToChild.new()) }
    copy(container, :@from, :@path, :$in-place);
}

multi sub copy(
    Positional \container,
    :@from!,
    :@path!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $value = Crane.get(container, :path(@from), :v);
    my $root := container;
    Crane.add($root, :@path, :$value, :in-place);
    |$root;
}

multi sub copy(
    \container,
    :@from!,
    :@path!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $value = Crane.get(container, :path(@from), :v);
    my $root := container;
    Crane.add($root, :@path, :$value, :in-place);
    $root;
}

multi sub copy(
    Positional \container,
    :@from!,
    :@path!,
    Bool :in-place($)
    --> Any:D
)
{
    my $value = Crane.get(container, :path(@from), :v);
    my $root = container.deepmap(*.clone());
    Crane.add($root, :@path, :$value, :in-place);
    |$root;
}

multi sub copy(
    \container,
    :@from!,
    :@path!,
    Bool :in-place($)
    --> Any:D
)
{
    my $value = Crane.get(container, :path(@from), :v);
    my $root = container.deepmap(*.clone());
    Crane.add($root, :@path, :$value, :in-place);
    $root;
}

# end method copy }}}

# method test {{{

method test(
    $container,
    :@path!,
    :$value!
    --> Bool:D
)
{
    unless Crane.exists($container, :@path)
    { die(X::Crane::TestPathNotFound.new()) }
    at($container, @path) eqv $value;
}

# end method test }}}

# method list {{{

method list(
    $container,
    :@path
    --> List:D
)
{
    list($container, :@path);
}

multi sub list(
    Associative:D $container,
    :@path
    --> List:D
)
{
    list('do', at($container, @path));
}

multi sub list(
    Positional:D $container,
    :@path
    --> List:D
)
{
    list('do', at($container, @path));
}

multi sub list(
    $container,
    :path(@)
    --> List:D
)
{
    list('do', $container);
}

multi sub list(
    'do',
    Associative:D $container where *.elems() > 0,
    :@carry = ()
    --> List:D
)
{
    my @tree;
    $container.keys().map(-> $toplevel {
        my @current = |@carry, $toplevel;
        push(@tree, |list('do', at($container, $toplevel), :carry(@current)));
    });
    @tree.sort().List();
}

multi sub list(
    'do',
    Positional:D $container where *.elems() > 0,
    :@carry = ()
    --> List:D
)
{
    my @tree;
    $container.keys().map(-> $toplevel {
        my @current = |@carry, $toplevel;
        push(@tree, |list('do', at($container, $toplevel), :carry(@current)));
    });
    @tree.sort().List();
}

multi sub list(
    'do',
    $container,
    :@carry = ()
    --> List:D
)
{
    List({:path(@carry), :value($container)});
}

# end method list }}}
# method flatten {{{

method flatten(
    $container,
    :@path
    --> Hash[Any:D,List:D]
)
{
    my Any:D %tree{List:D} =
        Crane.list($container, :@path).map({ $_<path> => $_<value> });
}

# end method flatten }}}

# method transform {{{

method transform(
    \container,
    :@path!,
    :&with!,
    Bool :$in-place = False
    --> Any:D
)
{
    unless is-valid-callable-signature(&with)
    { die(X::Crane::TransformCallableSignatureParams.new()) }

    if @path.elems() > 0
    {
        unless Crane.exists(container, :@path)
        { die(X::Crane::TransformPathNotFound.new()) }
    }

    transform(container, :@path, :&with, :$in-place);
}

multi sub transform(
    \container,
    :@path!,
    :&with!,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    transform('do', $root, :@path, :&with);
    $root;
}

multi sub transform(
    \container,
    :@path!,
    :&with!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    transform('do', $root, :@path, :&with);
    $root;
}

multi sub transform(
    'do',
    \container,
    :@path!,
    :&with!,
    --> Any:D
)
{
    my $value = do try
    {
        CATCH { default { die(X::Crane::TransformCallableRaisedException.new()) } }
        with(at(container, @path));
    }

    try
    {
        CATCH
        {
            when X::Crane::Replace::RO
            { die(X::Crane::Transform::RO.new(:typename(.typename))) }
            default
            { die('✗ Crane error: something went wrong during transform') }
        }
        Crane.replace(container, :@path, :$value, :in-place);
    }

    container;
}

# end method transform }}}

# method patch {{{

method patch(
    \container,
    @patch,
    Bool :$in-place = False
    --> Any:D
)
{
    patch(container, @patch, :$in-place);
}

multi sub patch(
    \container,
    @patch,
    Bool:D :in-place($)! where *.so()
    --> Any:D
)
{
    my $root := container;
    patch('do', $root, @patch);
}

multi sub patch(
    \container,
    @patch,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap(*.clone());
    patch('do', $root, @patch);
}

multi sub patch(
    'do',
    \container,
    @patch,
    --> Any:D
)
{
    @patch.map(-> %patch {
        try
        {
            CATCH
            {
                when X::Crane::PatchAddFailed
                { die(X::Crane::Patch.new(:help-text(.message()))) }
                when X::Crane::PatchRemoveFailed
                { die(X::Crane::Patch.new(:help-text(.message()))) }
                when X::Crane::PatchReplaceFailed
                { die(X::Crane::Patch.new(:help-text(.message()))) }
                when X::Crane::PatchMoveFailed
                { die(X::Crane::Patch.new(:help-text(.message()))) }
                when X::Crane::PatchCopyFailed
                { die(X::Crane::Patch.new(:help-text(.message()))) }
                when X::Crane::PatchTestFailed
                { die(X::Crane::Patch.new(:help-text(.message()))) }
                default
                { die('✗ Crane accident: patch operation failed') }
            }
            patch(container, %patch);
        }
    });
    container;
}

# add
multi sub patch(
    \container,
    %patch (:op($)! where {$_ eq 'add'}, :@path!, :$value!)
    --> Any:D
)
{
    CATCH { default { X::Crane::PatchAddFailed.new().throw() } }
    Crane.add(container, :@path, :$value, :in-place);
}

# remove
multi sub patch(
    \container,
    %patch (:op($)! where {$_ eq 'remove'}, :@path!)
    --> Any:D
)
{
    CATCH { default { X::Crane::PatchRemoveFailed.new().throw() } }
    Crane.remove(container, :@path, :in-place);
}

# replace
multi sub patch(
    \container,
    %patch (:op($)! where {$_ eq 'replace'}, :@path!, :$value!)
    --> Any:D
)
{
    CATCH { default { X::Crane::PatchReplaceFailed.new().throw() } }
    Crane.replace(container, :@path, :$value, :in-place);
}

# move
multi sub patch(
    \container,
    %patch (:op($)! where {$_ eq 'move'}, :@from!, :@path!)
    --> Any:D
)
{
    CATCH { default { X::Crane::PatchMoveFailed.new().throw() } }
    Crane.move(container, :@from, :@path, :in-place);
}

# copy
multi sub patch(
    \container,
    %patch (:op($)! where {$_ eq 'copy'}, :@from!, :@path!)
    --> Any:D
)
{
    CATCH { default { X::Crane::PatchCopyFailed.new().throw() } }
    Crane.copy(container, :@from, :@path, :in-place);
}

# test
multi sub patch(
    \container,
    %patch (:op($)! where {$_ eq 'test'}, :@path!, :$value!)
    --> Bool:D
)
{
    Crane.test(container, :@path, :$value)
        or X::Crane::PatchTestFailed.new().throw();
}

# end method patch }}}

# helper functions {{{

# --- sub is-valid-callable-signature {{{

sub is-valid-callable-signature(&c --> Bool:D)
{
    &c.signature().params().elems() == 1
        && &c.signature().params().grep(*.positional()).elems() == 1;
}

# --- end sub is-valid-callable-signature }}}
# --- sub is-valid-positional-index {{{

# INT0P: Int where * >= 0 (valid)
# WEC: WhateverCode (valid)
# INTM: Int where * < 0 (invalid)
# OTHER: everything else (invalid)
my enum Classifier <INT0P INTM OTHER WEC>;

multi sub is-valid-positional-index($step --> Bool:D)
{
    $step
    ==> is-valid-positional-index('classify')
    ==> is-valid-positional-index('do')
}

# classify positional index requests for better error messages
multi sub is-valid-positional-index(
    'classify',
    Int:D $ where * >= 0
    --> Classifier:D
)
{
    INT0P;
}

multi sub is-valid-positional-index(
    'classify',
    Int:D $ where * < 0
    --> Classifier:D
)
{
    INTM;
}

multi sub is-valid-positional-index(
    'classify',
    WhateverCode:D $
    --> Classifier:D
)
{
    WEC;
}

multi sub is-valid-positional-index(
    'classify',
    $
    --> Classifier:D
)
{
    OTHER;
}

multi sub is-valid-positional-index('do', INT0P --> Bool:D)
{
    True;
}

multi sub is-valid-positional-index('do', WEC --> Bool:D)
{
    True;
}

multi sub is-valid-positional-index('do', INTM --> Nil)
{
    die(X::Crane::PositionalIndexInvalid.new(:classifier<INTM>));
}

multi sub is-valid-positional-index('do', OTHER --> Nil)
{
    die(X::Crane::PositionalIndexInvalid.new(:classifier<OTHER>));
}

# --- end sub is-valid-positional-index }}}
# --- sub path-is-child-of-from {{{

multi sub path-is-child-of-from(
    @from,
    @path where { .elems() == @from.elems() }
    --> Bool:D
)
{
    # @path can't be child of @from if both are at the same depth
    False;
}

multi sub path-is-child-of-from(
    @from,
    @path where { .elems() < @from.elems() }
    --> Bool:D
)
{
    # @path can't be child of @from if @path is shallower than @from
    False;
}

# @path is at deeper level than @from
# verify @from[$_] !eqv @path[$_] for 0..@from.end
multi sub path-is-child-of-from(
    @from,
    @path
    --> Bool:D
)
{
    (0..@from.end)
        .map({ @from[$_] eqv @path[$_] })
        .grep(*.so())
        .elems() == @from.elems();
}

# --- end sub path-is-child-of-from }}}

# end helper functions }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
