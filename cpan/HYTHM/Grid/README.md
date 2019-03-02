NAME
====

Grid - Role for Arrays.

SYNOPSIS
========

    use Grid;

    my @grid = < a b c d e f g h i j k l m n o p q r s t u v w x >;

    @grid does Grid[:4columns];


DESCRIPTION
===========

Grid is a `Role` that transforms an `Array` to `Array+{Grid}`, And provides additional methods (e.g flip, rotate, transpose).

To flip a `Grid` horizontaly or vertically:

    @grid.flip: :horizontal
    @grid.flip: :vertical
    
It is also possible to apply methods to a subgrid of `Grid`, provided a valid subgrid indices:

    my @indices  = 9, 10, 13, 14; @grid.flip: :vertical(@indices); # or
    my @vertical = 9, 10, 13, 14; @grid.flip: :@vertical;`

`Grid` preserves the overall shape, So some operations require `is-square` to be `True`  for `Grid` (or Subgrid), otherwise fails and returns `self`.


EXAMPLES
========

### grid

<pre>
<code>

    @grid.grid;

    a b c d
    e f g h
    i j k l
    m n o p
    q r s t
    u v w x

</code>
</pre>


### flip

<pre>
<code>

    a b c d                          <b>d c b a</b> 
    e f g h                          <b>h g f e</b>
    i j k l       :horizontal        <b>l k j i</b>
    m n o p    ----------------->    <b>p o n m</b>
    q r s t                          <b>t s r q</b>
    u v w x                          <b>x w v u</b>


    a b c d                          <b>u v w x</b>
    e f g h                          <b>q r s t</b>
    i j k l        :vertical         <b>m n o p</b>
    m n o p    ----------------->    <b>i j k l</b>
    q r s t                          <b>e f g h</b>
    u v w x                          <b>a b c d</b>


    a b c d                          a b c d
    e f g h                          <b>e i m q</b>
    i j k l       :@diagonal         <b>f j n r</b>
    m n o p    ----------------->    <b>g k o s</b>
    q r s t    subgrid [ 4 ... 19 ]  <b>h l p t</b>
    u v w x                          u v w x


    a b c d                          a b c d
    e f g h                          <b>t p l h</b>
    i j k l     :@antidiagonal       <b>s o k g</b>
    m n o p    ----------------->    <b>r n j f</b>
    q r s t      [ 4 ... 19 ]        <b>q m i e</b>
    u v w x                          u v w x


    a b c d                          a b c d
    e f g h                          e f g h
    i j k l        :diagonal         i j k l
    m n o p    ----------------->    m n o p
    q r s t                          q r s t
    u v w x                          u v w x
    
    # fails becuase Grid.is-square === False


</code>
</pre>


### rotate

<pre>
<code>

    a b c d
    e f g h                          <b>u q m i e a</b>
    i j k l       :clockwise         <b>v r n j f b</b>
    m n o p    ----------------->    <b>w s o k g c</b>
    q r s t                          <b>x t p l h d</b>
    u v w x


    a b c d                          a b c d
    e f g h                          e f g h
    i j k l     :@anticlockwise      i <b>k o</b> l
    m n o p    ----------------->    m <b>j n</b> p
    q r s t    [ 9, 10, 13, 14 ]     q r s t
    u v w x                          u v w x


    a b c d                          <b>d a b c</b> 
    e f g h                          <b>h e f g</b>
    i j k l         :right           <b>l i j k</b>
    m n o p    ----------------->    <b>p m n o</b>
    q r s t                          <b>t q r s</b>
    u v w x                          <b>x u v w</b>


    a b c d                          <b>c d a b</b> 
    e f g h                          <b>g h e f</b>
    i j k l         :2left           <b>k l i j</b>
    m n o p    ----------------->    <b>o p m n</b>
    q r s t                          <b>s t q r</b>
    u v w x                          <b>w x u v</b>


    a b c d                          <b>m n o p</b> 
    e f g h                          <b>q r s t</b>
    i j k l         :3down           <b>u v w x</b>
    m n o p    ----------------->    <b>a b c d</b>
    q r s t                          <b>e f g h</b>
    u v w x                          <b>i j k l</b>


    a b c d                          <b>e f g h</b> 
    e f g h                          <b>i j k l</b>
    i j k l          :7up            <b>m n o p</b>
    m n o p    ----------------->    <b>q r s t</b>
    q r s t                          <b>u v w x</b>
    u v w x                          <b>a b c d</b>


</code>
</pre>

### transpose

<pre>
<code>

    a b c d
    e f g h                          <b>a e i m q u</b>
    i j k l                          <b>b f j n r v</b>
    m n o p    ----------------->    <b>c g k o s w</b>
    q r s t                          <b>d h l p t x</b>
    u v w x


    a b c d                          a b c d
    e f g h                          e f g h
    i j k l        :@indices         i <b>j n</b> l
    m n o p    ----------------->    m <b>k o</b> p
    q r s t    [ 9, 10, 13, 14 ]     q r s t
    u v w x                          u v w x


    a b c d                          a b c d
    e f g h                          e f g h
    i j k l       :@indices          i j k l
    m n o p    ---------------->     m n o p
    q r s t  [ 5, 6, 9, 10, 13, 14 ] q r s t
    u v w x                          u v w x
    
    # fails becuase Subgrid.is-square === False


</code>
</pre>

### append

<pre>
<code>

    a b c d                          a b c d
    e f g h                          e f g h
    i j k l       :@rows             i j k l
    m n o p    ----------------->    m n o p
    q r s t    [ 0, 1, 2, 3 ]        q r s t
    u v w x                          u v w x
                                     <b>0 1 2 3</b>

    a b c d                          a b c d <b>0</b>
    e f g h                          e f g h <b>1</b>
    i j k l       :@columns          i j k l <b>2</b>
    m n o p    ----------------->    m n o p <b>3</b>
    q r s t   [ 0, 1, 2, 3, 4, 5 ]   q r s t <b>4</b>
    u v w x                          u v w x <b>5</b>
  

</code>
</pre>

### prepend

<pre>
<code>

    a b c d                          <b>0 1 2 3</b>
    e f g h                          a b c d
    i j k l         :@rows           e f g h
    m n o p    ----------------->    i j k l
    q r s t      [ 0, 1, 2, 3 ]      m n o p
    u v w x                          q r s t
                                     u v w x

    a b c d                          <b>0</b> a b c d
    e f g h                          <b>1</b> e f g h
    i j k l       :@columns          <b>2</b> i j k l
    m n o p    ----------------->    <b>3</b> m n o p
    q r s t   [ 0, 1, 2, 3, 4, 5 ]   <b>4</b> q r s t
    u v w x                          <b>5</b> u v w x

</code>
</pre>


### pop

<pre>
<code>

    a b c d
    e f g h                          a b c d
    i j k l        :2rows            e f g h
    m n o p    ----------------->    i j k l
    q r s t                          m n o p
    u v w x


    a b c d                          a b c
    e f g h                          e f g
    i j k l       :1columns          i j k
    m n o p    ----------------->    m n o
    q r s t                          q r s
    u v w x                          u v w


</code>
</pre>

### shift

<pre>
<code>

    a b c d
    e f g h                          i j k l
    i j k l         :2rows           m n o p
    m n o p    ----------------->    q r s t 
    q r s t                          u v w x
    u v w x


    a b c d                          d
    e f g h                          h
    i j k l        :3columns         l
    m n o p    ----------------->    p
    q r s t                          t
    u v w x                          x

</code>
</pre>


METHODS
=======

### grid

    method grid { ... }

Prints a `:$!columns` `Grid`.


### columns

    method columns { ... }

Returns `Grid`'s  columns count.


### rows

    method columns { ... }

Returns `Grid`'s  rows count.


### check

    multi method check ( :@rows! --> Bool:D ) { ... }
Check if Rows can fit in `Grid`.

    multi method check ( :@columns! --> Bool:D ) { ... }
Check if Columns can fit in `Grid`.


### reshape

    method reshape ( Grid:D:  Int :$columns! where * > 0 --> Grid:D ) { ... }


### flip

    multi method flip ( Grid:D: Int:D :$horizontal! --> Grid:D ) { ... }
Horizontal Flip.

    multi method flip ( Grid:D: Int:D :$vertical! --> Grid:D ) { ... }
Verical Flip.

    multi method flip ( Grid:D: Int:D :$diagonal! --> Grid:D ) { ... }
Diagonal Flip.

    multi method flip ( Grid:D: Int:D :$antidiagonal! --> Grid:D ) { ... }
Anti-Diagonal Flip.

    multi method flip ( Grid:D: :@horizontal! --> Grid:D ) { ... }
Horizontal Flip (Subgrid).

    multi method flip ( Grid:D: :@vertical! --> Grid:D ) { ... }
Vertical Flip (Subgrid).

    multi method flip ( Grid:D: :@diagonal! --> Grid:D ) { ... }
Diagonal Flip (Subgrid).

    multi method flip ( Grid:D: :@antidiagonal! --> Grid:D ) { ... }
Anti-Diagonal Flip (Subgrid).


### rotate

    multi method rotate ( Grid:D:  Int:D :$left! --> Grid:D ) { ... }
Left Rotate. (Columns)

    multi method rotate ( Grid:D:  Int:D :$right! --> Grid:D ) { ... }
Right Rotate. (Columns)

    multi method rotate ( Grid:D:  Int:D :$up! --> Grid:D ) { ... }
Up Rotate. (Rows)

    multi method rotate ( Grid:D:  Int:D :$down! --> Grid:D ) { ... }
Up Rotate. (Rows)

    multi method rotate ( Grid:D: Int:D :$clockwise! --> Grid:D ) { ... }
Clockwise Rotate.

    multi method rotate ( Grid:D: Int:D :$anticlockwise! --> Grid:D ) { ... }
Anti-Clockwise Rotate.

    multi method rotate ( Grid:D: :@clockwise! --> Grid:D ) { ... }
Clockwise Rotate (Subgrid)

    multi method rotate ( Grid:D: :@anticlockwise! --> Grid:D ) { ... }
Clockwise Rotate (Subgrid)


### transpose

    multi method transpose ( Grid:D: --> Grid:D ) { ... }
Transpose.

    multi method transpose ( Grid:D: :@indices! --> Grid:D ) { ... }
Transpose (Subgrid)


### append

    multi method append ( Grid:D: :@rows! --> Grid:D ) { ... }
Append Rows.

    multi method append ( Grid:D: :@columns! --> Grid:D ) { ... }
Append Columns.


### Prepend

    multi method prepend ( Grid:D: :@rows! --> Grid:D ) {
Prepend Rows.

    multi method prepend ( Grid:D: :@columns! --> Grid:D ) { ... }
Prepend Columns.


### push

    multi method push ( Grid:D: :@rows! --> Grid:D ) { ... }
Push Rows.

    multi method push ( Grid:D: :@columns! --> Grid:D ) {
Push Columns.


### pop

    multi method pop ( Grid:D:  Int :$rows! --> Grid:D ) { ... }
Pop Rows.

    multi method pop ( Grid:D:  Int :$columns! --> Grid:D ) { ... }
Pop Columns.


### shift

    multi method shift ( Grid:D:  Int :$rows! --> Grid:D ) { ... }
Shift Rows.

    multi method shift ( Grid:D:  Int :$columns! --> Grid:D ) { ... }
Shift Columns.


### unshift

    multi method unshift ( Grid:D: :@rows! --> Grid:D ) { ... }
Unshift Rows.

    multi method unshift ( Grid:D: :@columns! --> Grid:D ) {
Unshift Columns.


### has-subgrid

    method has-subgrid( :@indices!, :$square = False --> Bool:D ) { ... }
Returns `True` if `:@indices` is a subgrid of `Grid`, `False` otherwise.


### is-square

    method is-square ( --> Bool:D ) { ... }
Returns `True` if `Grid` is a square, False otherwise.


AUTHOR
======

Haytham Elganiny <elganiny.haytham@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2019 Haytham Elganiny

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

