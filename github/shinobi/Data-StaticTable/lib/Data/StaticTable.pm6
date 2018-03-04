use v6;
use X::Data::StaticTable;
unit module Data;

subset StaticTable::Position of Int where * >= 1;

class StaticTable {
    has Position $.columns;
    has Position $.rows;
    has @!data;
    has Str @.header;
    has %.ci; #-- Gets the heading (Str) for a column number (Position)
    has $!filler;

    method perl {
        my @all-cells;
        for (1 .. $.rows) -> $i { push @all-cells, |self.row($i); }
        return
            'Data::StaticTable.new(' ~
            @.header.perl ~ ', ' ~
            @all-cells.perl ~ ')';
    }

    method display {
        my Str $out;
        for (1 .. $!rows) -> $row-num {
            $out ~= "\n";
            for (1 .. $!columns) -> $col-num {
                my $cell = self!cell-by-position($col-num, $row-num).perl;
                $out ~= "[" ~ $cell ~ "]\t";
            }
        }
        my Str $header;
        $header = join("\t", @.header);
        my Str @u;
        for (@.header) -> $h {
            @u.append("⋯" x $h.chars);
        }
        return $header ~ "\n" ~ join("\t", @u) ~ $out;
    }

    submethod BUILD (
    :@!data, :@!header, :%!ci, Position :$!columns, Position :$!rows
    ) { }
    method !calculate-dimensions(Position $columns, Int $elems, $filler) {
        my $extra-cells = $elems % $columns;
        $extra-cells = $columns - $extra-cells if ($extra-cells > 0);
        my @additional-cells = $filler xx $extra-cells; #'Nil' objects to fill an incomplete row, will appear as 'Any'
        my Position $rows = ($elems + $extra-cells) div $columns;
        return $rows, |@additional-cells;
    }

    multi method new(@header!, +@new-data, :$filler = Nil) {
        if (@header.elems < 1) {
            X::Data::StaticTable.new("Header is empty").throw;
        }
        if (@new-data.elems < 1) {
            X::Data::StaticTable.new("No data available").throw;
        }
        my ($rows, @additional-cells) = self!calculate-dimensions(@header.elems, @new-data.elems, $filler);
        my Int $col-num = 1;
        my %column-index = ();
        for (@header) -> $heading { %column-index{$heading} = $col-num++; }
        if (@header.elems != %column-index.keys.elems) {
            X::Data::StaticTable.new("Header has repeated elements").throw;
        };

        @new-data.append(@additional-cells);
        return self.bless(
            columns => @header.elems,
            rows    => $rows,
            data    => @new-data,
            header  => @header.map(*.Str),
            ci      => %column-index
        );
    }
    multi method new(Position $columns!, +@new-data, :$filler = Nil) {
        my @header = ('A', 'B' ... *)[0 ... $columns - 1].list;
        self.new(@header, @new-data);
    }

    #== Rowset constructor: just receive an array and do our best to handle it ==
    multi method new(@new-data,         #-- By default, @new-data is an array of arrays
        Bool :$set-of-hashes = False,   #-- Receiving an array with hashes in each element
        Bool :$data-has-header = False, #-- Asume an array of arrays. First row is the header
        :$rejected-data is raw = Nil,   #-- Rejected rows or cells will be returned here
        :$filler = Nil
    ) {
        if ($set-of-hashes && $data-has-header) {
            X::Data::StaticTable.new("Contradictory flags using the 'rowset' constructor").throw;
        }
        my (@data, @xeno-hash, %xeno-array); #-- @xeno will be used ONLY if rejected-rows is provided
        my @header;

        #-----------------------------------------------------------------------
        if ($set-of-hashes) { #--- HASH MODE -----------------------------------
            # Pass 1: Weed out not-hashes and determine an optimal header
            my %column-frequency;
            my @hashable-data;
            for (@new-data) -> $row-ref {
                if ($row-ref ~~ Hash) { # Sort Columns so most common ones appear at first
                    my %row = %$row-ref;
                    for (%row.keys) { %column-frequency{$_}++ }
                    push @hashable-data, $row-ref;
                } else {
                    push @xeno-hash, $row-ref if ($rejected-data.defined);
                }
            }
            if (@hashable-data.elems == 0) {
                X::Data::StaticTable.new("No data available").throw;
            }
            @header = %column-frequency.sort({ -.value, .key }).map: (*.keys[0]);
            # Pass 2: Populate with data
            for (@hashable-data) -> $hash-ref {
                my %row = %$hash-ref;
                for (@header) -> $heading {
                    push @data, (%row{$heading}.defined) ?? %row{$heading} !! $filler;
                }
            }
            @$rejected-data = @xeno-hash if ($rejected-data.defined);
        } else { #--- ARRAY MODE -----------------------------------------------
            my Data::StaticTable::Position $columns;
            my $first-data-row = 0;
            if ($data-has-header) {
                @header = @new-data[0];
                @header = @header>>[].flat; #-- Completely flatten the header
                $columns = @header.elems;
                $first-data-row = 1;
            } else {
                $columns = @new-data.max(*.elems).elems;
                @header = ('A', 'B' ... *)[0 ... $columns - 1].list;
            }
            my $i = 1;
            for (@new-data[$first-data-row ... *]) -> $row-ref {
                my @row = @$row-ref;
                %xeno-array{$i} = @row.splice($columns) if (@row.elems > $columns);
                push @row, |($filler xx $columns - @row.elems) if @row.elems < $columns;
                push @data, |@row;
                $i++;
            }
            %$rejected-data = %xeno-array if ($rejected-data.defined);
        } #---------------------------------------------------------------------
        return self.new(@header, @data);
    }

    #-- Accessing cells directly
    method !cell-by-position(Position $col!, Position $row!) {
        my $pos = ($!columns * ($row-1)) + $col - 1;
        if ($pos < @!data.elems) { return @!data[$pos]; }
        X::Data::StaticTable.new("Out of bounds").throw;
    }
    method cell(Str $column-header, Position $row) {
        my Position $column-number = self!column-number($column-header);
        return self!cell-by-position($column-number, $row);
    }

    #-- Retrieving a column by its name
    method !column-number(Str $heading) {
        if (%!ci{$heading}:exists) { return %!ci{$heading}; }
        X::Data::StaticTable.new("Heading $heading not found").throw;
    }

    method column(Str $heading) {
        my Position $column-number = self!column-number($heading);
        my Int $pos = $column-number - 1;
        return @!data[$pos+($!columns*0), $pos+($!columns*1) ... *];
    }

    #-- Retrieving specific rows
    method row(Position $row) {
        if (($row < 1) || ($row > $.rows)) {
            X::Data::StaticTable.new("Out of bounds").throw;
        }
        return @!data[($row-1) * $!columns ... $row * $!columns - 1];
    }
    method !rows(@rownums) {
        my @result = gather for (@rownums) -> $num { take self.row($num) };
        return @result;
    }

    #-- Shaped arrays
    #-- Perl6 shaped arrays:  @a[3;2] <= 3 rows and 2 columns, starts from 0
    #-- This method returns the data only (not headers)
    method shaped-array() {
        my @shaped;
        my @rows = self!rows(1 .. $.rows);
        for (1 .. $.rows) -> $r {
            my @row = @rows[$r];
            for (1 .. $.columns) -> $c {
                @shaped[$r - 1;$c - 1] = self!cell-by-position($c, $r);
            }
        }
        return @shaped;
    }

    #==== Positional =====
    multi method elems(::?CLASS:D:) {
        return @!data.elems;
    }

    method AT-POS(::?CLASS:D: Position $row) {
        return @.header.list if ($row == 0);
        my @row = self.row($row);
        my %full-row;
        for (0 .. $.columns - 1) -> $i {
            %full-row{@.header[$i]} = @row[$i];
        }
        return %full-row;
    }

    #==== Index ====
    method generate-index(Str $heading) {
        my %index;
        my Position $row-num = 1;
        my @full-column = self.column($heading);
        for (@full-column) -> $item {
            if ($item.defined) {
                if (%index{$item}:exists == False) {
                    my Position @a = ();
                    %index{$item} = @a;
                }
                push %index{$item}, $row-num++;
            }
        }
        return %index;
    }

    #--- Returns raw data cells from a set of rows
    #--- Any repeated row is ignored (recovers only one)
    method !gather-rowlist(@rownums) {
        if (@rownums.elems == 0) {
            X::Data::StaticTable.new("No data available").throw;
        }
        #-- If we are receiving the output from generate-index, it might be
        #-- possible that elements of @rownums are also arrays
        @rownums = @rownums>>[].flat;
        if any(@rownums) > $.rows {
            X::Data::StaticTable.new("No data available").throw;
        }
        my @result = ();
        if (@rownums.elems == 1) {
            @result = self.row(@rownums[0])
        } else {
            #--- Instead of getting row by row, we
            #--- get whole blocks of continous rows.
            my @block;
            my @rowsets;
            @rownums.rotor(2 => -1).map: -> ($a,$b) {
                push @block, $a;
                if ($a+1 != $b) {
                    @rowsets.push( $(@block.clone) );
                    @block = ();
                };
                LAST {
                	push @block, $b;
                	@rowsets.push( $(@block.clone) );
                }
            };
            #-- TODO: get a little bit more speed? We only need the min and
            #-- max of each block when populating above, hence avoiding to use
            #-- .min and .max functions below
            for (@rowsets) -> $block-num {
                my $min-row = $block-num.min;
                my $max-row = $block-num.max;
                my $start = ($!columns * ($min-row - 1)); #1st element of the first row
                my $end = ($!columns * ($max-row - 1)) + $!columns - 1; #last element of the last row
                @result.append(@!data[$start ... $end]);
            }
        }
        return @result;
    }

    multi method take(@rownums where .all ~~ Position) {
         return self.new(@!header, self!gather-rowlist(@rownums));
    }
    multi method take(*@rownums where .all ~~ Position) { return self.take(@rownums) }

    method clone() {
        return self.new(@.header, @!data, filler => $!filler);
    }
}

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#

class StaticTable::Query {
    has %!indexes handles <keys elems values kv AT-KEY EXISTS-KEY>;
    has Data::StaticTable $!T;
    submethod BUILD (:$!T) { }

    method perl {
        my @indexes = %!indexes.keys;
        my $out = 'Data::StaticTable::Query.new(' ~ $!T.perl;
        $out ~=  ", " ~ @indexes.perl if (@indexes.elems > 0);
        $out ~= ")";
        return $out;
    }

    multi method new(Data::StaticTable $T, *@to-index) {
        my $q = self.bless(T => $T);
        return $q if (@to-index.elems == 0);
        for (@to-index) -> $heading {
            $q.add-index($heading);
        }
        return $q;
    }

    method grep(Mu $matcher where { -> Regex {}($_); True }, Str $heading,
        Bool :$n = False,  # Row numbers
        Bool :$r = False,  # Array of array
        Bool :$h = False,   # Array of hashes (Default)
        Bool :$nr = False, # Row numbers => row data (array)
        Bool :$nh = False, # Row numbers => row data (hash)
    ) {
        my $default = $h;
        $default = True if all($n, $r, $h, $nr, $nh) == False;
        X::Data::StaticTable.new("Method grep only accepts one adverb at a time").throw unless one($n, $r, $default, $nr, $nh) == True;
        my Data::StaticTable::Position @rownums;
        if (%!indexes{$heading}:exists) { #-- Search in the index if it is available. Should be faster.
            my @keysearch = grep {.defined and $matcher}, %!indexes{$heading}.keys;
            for (@keysearch) -> $k {
                @rownums.push(|%!indexes{$heading}{$k});
            }
        } else {;
            @rownums = 1 <<+>> ( grep {.defined and $matcher}, :k, $!T.column($heading) );
        }
        if ($n) { # Returning rowlist
            return @rownums.sort.list                           #-- :n
        } elsif ($r || $default) { # Returning an array of arrays or array of hashes
                my @rows;
                for @rownums.sort -> $row-num {
                    if ($r) { push @rows, $!T.row($row-num) } #-- :r
                    else    { push @rows, $!T[$row-num]     } #-- :h
                }
                return @rows;
        } else { # A hash of row-num => data in the row or row-num => a row hash
            my %hash;
            for @rownums.sort -> $row-num {
                if ($nh) { %hash{$row-num} = $!T[$row-num]     } #-- :nh
                else     { %hash{$row-num} = $!T.row($row-num) } #-- :nr
            }
            return %hash;
        }
    }

    #==== Index ====
    method add-index(Str $heading) {
        my %index;
        my Data::StaticTable::Position $row-num = 1;
        my @full-column = $!T.column($heading);
        for (@full-column) -> $item {
            if ($item.defined) {
                if (%index{$item}:exists == False) {
                    my Data::StaticTable::Position @a = ();
                    %index{$item} = @a;
                }
                push %index{$item}, $row-num++;
            }
        }
        %!indexes{$heading} = %index;
        my $score = (%index.keys.elems / @full-column.elems).Rat;
        return $score;
    }
}

multi sub infix:<eqv>(StaticTable $t1, StaticTable $t2 --> Bool) {
    return False if !($t1.header eqv $t2.header);
    for ($t1.header.race) -> $heading {
        return False if !($t1.column($heading) eqv $t2.column($heading));
    }
    return True;
}

=begin pod

=head1 Introduction

A StaticTable allows you to handle bidimensional data in a more natural way

Some features:

=over

=item Rows starts at 1 (C<Data::StaticTable::Position> is the datatype used to reference row numbers)

=item Columns have header names

=item Any column can work as an index

=back

If the number of elements provided does not suffice to form a
square or a rectangle, filler cells will be added as filler. (you can define
what goes in these filler cells too)

The module provides two classes: C<StaticTable> and C<StaticTable::Query>.

A StaticTable can be populated, but it can not be modified later. To perform
searchs and create/store indexes, a Query object is provided. You can add
indexes per column, and perform searches (grep) later. If an index exists, it
will be used.

You can get data by rows, columns, and create subsets by taking some
rows from an existing StaticTable.

=head1 Types

=head2 C<Data::StaticTable::Position>

Basically, an integer greater than 0. Used to indicate a row position
in the table. A StaticTable do not have rows on index 0.

=head1 Operators

=head2 C<eqv>

Compares the contents (header and data) of two StaticTable objects. Returns
C<False> as soon as  any difference is detected, and C<True> if finds that
everything is equal.

 say '$t1 and $t2 are ' ~ ($t1 eqv $t2) ?? 'equal' !! 'different';

=head1 C<Data::StaticTable> class

=head2 Positional features

=head3 Brackets []

You can use [n] to get the full Nth row, in the way of a hash of
B<'Column name'> => data


So, for example

 $t[1]

Could return a hash like

 {Column1 => 10, Column2 => 200.4, Column3 => 450}

And a call like

 $t[10]<Column3>

would refer to the data in Row 10, with the heading Column3

=head3 the C<ci> hash

On construction, a public hash called C<ci> (short for B<c>olumn B<i>ndex) is
created. If for some reason, you need to refer the columns by number instead of
name, this hash contains the column numbers as keys, and the heading name as
values.

if your column number B<2> has the name "Weight", you can read the cell in the
third row of that column like this:

 my $val1 = $t.cell('Weight', 3);
 my $val2 = $t[3]<Weight>;

Or by using the C<ci> hash

 my $val1 = $t.cell($t.ci<2>, 3);
 my $val2 = $t[3]{$t.ci<2>};

=head2 C<method new>

Depending on how your source data is organized, you can use the 2 B<flat array>
constructors or a B<rowset> constructor.

B<Flat array> allows you to pass a long one dimensional array and order it in
rows and columns, by specifiying a header. You can pass an array of string to
specify the column names, or just a number of columns if you don't care about
the column names.

B<Rowset> works when your data is already bidimensional, and it can include a
first row as header. In the case that your rows contains a hash, you can tell
the constructor, and it will take the hash keys to create a header with the
appropiate column names. In this case, any row that does not contain a hash
will be discarded (You have the option to recover the discarded data).

=head3 The flat array constructor

 my $t1 = StaticTable.new( 3 , (1 .. 15) );
 my $t2 = StaticTable.new(
    <Column1 Column2 Column3> ,
    (
    1, 2, 3,
    4, 5, 6,
    7, 8, 9,
    10,11,12
    13,14,15
    )
 );


This will create a spreadsheet-like table, with numbered rows and labeled
columns.

In the case of C<$t1>, since the first parameter is a number, it will have
columns named automatically, as C<A>, C<B>, C<C>... etc.

C<$t2> has an array as the first parameter. So it will have three columns
labeled C<Column1>, C<Column2> and C<Column3>.

You just need to provide an array to fill the table. The rows and columns will
be automatically cut and filled in a number of rows.

If you do not provide enough data to fill the last row, empty cells will be
appended.

If you already have your data ordered in an array of arrays, use the rowset
constructor described below.

=head3 The rowset constructor

You can also create a StaticTable from an array, with each element representing
a row. The StaticTable will acommodate the values as best as possible, adding
empty values or discarding values that go beyond the boundaries, or data
that is not prepared appropiately

This constructor can be called like this, using an Array of Arrays

 my $t = StaticTable.new(
    (1,2,3),
    (4,5,6),
    (7,8,9)
 );

For a Array of Hashes, you can call it like this

 my $t = StaticTable.new(
 [
  { name => 'Eggplant', color => 'aubergine', type => 'vegetal' },
  { name => 'Egg', color => ('white', 'beige'), type => 'animal' },
  { name => 'Banana', color => 'yellow', type => 'fruit' },
  { name => 'Avocado', color => 'green', type => 'fruit',  class => 'Hass' }
 ]
 );

I<(Note the use of brackets, we needed to explicitly pass an Array of Hashes)>

There is a set of named parameters usable in this constructor

 my $t = StaticTable.new(@ArrayOfArrays):data-has-header

This will use the first row as header. Any value that falls outside the column
boundaries determined by the header will be discarded in each row.

 my $t = StaticTable.new(@ArrayOfHashes):set-of-hashes

This will consider each row as a hash, and will create columns for each key
found. The most populated will be the first columns. Any row that is not a
hash will be discarded

=head3 Recovering discarded data

In some situations, some data can be rejected from your original array passed to
the constructor. This will happen
in two cases, using the rowset constructor:

=over 4

=item You specified C<:data-has-header> but there are rows longer that the
lenght of the header. So, if your first row had 4 elements, any row with more
that 4 elements will be cut and the extra elements will be rejected

=item You specified C<:set-of-hashes> but there are rows that does not contain
hashes. All these rows will be rejected too.

=back

For recovering discarded data from an Array of Arrays:

 my %rejected;
 my $tAoA = StaticTable.new(
   @ArrayOfArrays, rejected-data => %rejected # <--- Note, rejected is a hash
 ):data-has-header

In this case, C<%rejected> is a hash where the key is the row from where the
data was discarded, pointing to an array of the elements discarded in that row.

For recovering discarded data from an Array of Hashes:

 my @rejected;
 my $tAoH = StaticTable.new(
   @ArrayOfHashes, rejected-data => @rejected # <--- rejected is an array
 ):set-of-hashes

In this case, C<@rejected> will have a list of all the rejected rows.

=head3 The C<filler> value

There is another named parameter, called C<filler>. This is used to complete
rows that needs more cells, so the table has every row with the same number of
elements.

By default, it uses C<Nil>.

Example:

 my $t = Data::StaticTable.new(
   <A B C>,
   (1,2,3,
    4,5,6,
    7),     # 2 last cells will be fillers, so the 3rd row is complete
   filler => 'N/A'
 );

 print $t[3]<C>; #This will print N/A

=head2 C<method perl>

Returns a representation of the StaticTable. Can be used for serialization.

=head2 C<method clone>

Returns a newly created StaticTable with the same attributes. It does not copy
attributes to clone. Instead, runs the constructor again.

=head2 C<method display>

Shows a 'visual' representation of the contents of the StaticTable. Used for
debugging, B<not for serialization>.

It would look like this:

 A   B   C
 ⋯  ⋯  ⋯
 [1] [2] [3]
 [4] [5] [6]
 [7] [8] [9]

However, you could save the output of this method to a tab-separated csv file.

=head2 C<method cell(Str $column-heading, Position $row)>

Retrieves the content of a cell.

=head2 C<method column(Str $column-heading)>

Retrieves the content of a column like a regular C<List>.

=head2 C<method row(Position $row)>

Retrieves the content of a row as a regular C<List>.

=head2 C<method shaped-array()>

Retrieves the content of the table as a multiple dimension array.

=head2 C<method elems()>

Retrieves the number of cells in the table

=head2 C<method generate-index(Str $heading)>

Generate a C<Hash>, where the key is the value of the cell, and the value
is a list of row numbers (of type C<Data::StaticTable::Position>).

=head2 C<method take(@rownums where .all ~~ Position)>

Generate a new C<StaticTable>, using a list of row numbers
(using the type C<Data::StaticTable::Position>)

The order of the rows will be kept, and you can consider repeated rows. You can
use .uniq and .sort on the row numbers list. A sorted, unique list will make
the construction of the new table B<faster>. Consider this is you want to use
a lot of rownums.

 #-- Order and repeated rows will be kept
 my $new-t1 = $t.take(@list);
 #-- Consider this if @list is big, not sorted and has repeated elements
 my $new-t2 = $t.take(@list.uniq.sort)

You can combine this with C<generate-index>

 my %i-Status = $t.generate-index("Status");
 # We want a new table with rows where Status = "Open"
 my $t-open = $t.take(%i-Status<Open>);
 # We want another where Status = "Awaiting feedback"
 my $t-waiting = $t.take(%i-Status{'Awaiting feedback'});

Also works with the C<grep> method from the C<StaticTable::Query> object. This
allows to you do more complex searches in the columns.

An identical, but slurpy version of this method is also available for convenience.

=head1 C<Data::StaticTable::Query> class

Since StaticTable is immutable, a helper class to perform searches is provided.
It can contain generated indexes. If an index is provided, it will be used if a
search is performed.

=head2 Associative features

You can use hash-like keys, to get a specific index for a column

 $Q1<Column1>
 $Q1{'Column1'}

Both can get you the index (the same you could get by using C<generate-index> in a
C<StaticTable>).


=head2 C<method new(Data::StaticTable $T, *@to-index)>

You need to specify an existing C<StaticTable> to create this object. Optionally
you can pass a list with all the column names you want to consider as indexes.

Examples:

 my $q1 = Data::StaticTable::Query.new($t);            #-- No index at construction
 my $q2 = Data::StaticTable::Query.new($t, 'Address'); #-- Indexing column 'Address'
 my $q3 = Data::StaticTable::Query.new($t, $t.header); #-- Indexing all columns

If you don't pass any column names in the constructor, you can always use the
method C<add-index> later

=head2 C<method perl>

Returns a representation of the StaticTable::Query object. Can be used for
serialization.

B<Note:> This value will contain I<the complete> StaticTable for this index.

=head2 C<method keys>

Returns the name of the columns indexed.

=head2 C<method values>

Returns the values indexed.

=head2 C<method kv>

Returns the hash of the same indexes in the C<Query> object.

=head2 C<method grep(Mu $matcher where { -E<gt> Regex {}($_); True }, Str $heading, Bool :$h = True, Bool :$n = False, Bool :$r = False, Bool :$nr = False, Bool :$nh = False)>

Allows to use grep over a column. Depending on the flags used, returns the resulting
row information for all that rows where there are matches. You can not only use
a regxep, but a C<Junction> of C<Regex> elements.

Examples of Regexp and Junctions:

 # Get the rownumbers where the column 'A' contains '9'
 my Data::StaticTable::Position @rs1 = $q.grep(rx/9/, "A"):n;
 # Get the rownumbers where the column 'A' contains 'n' and 'e'
 my Data::StaticTable::Position @rs2 = $q.grep(all(rx/n/, rx/e/), "A"):n;

When you use the flag C<:n>, you can use these results later with the method C<take>

=head3 Flags

Similar to the default grep method, this contains flags that allows you to
receive the information in various ways.

Consider this StaticTable and its Query:

 my $t = Data::StaticTable.new(
    <Countries  Import      Tons>,
    (
    'US PE CL', 'Copper',    100, # Row 1
    'US RU',    'Alcohol',   50,  # Row 2
    'IL UK',    'Processor', 12,  # Row 3
    'UK',       'Tuxedo',    1,   # Row 4
    'JP CN',    'Tuna',      10,  # Row 5
    'US RU CN', 'Uranium',   0.01 # Row 6
    )
 );
 my $q = Data::StaticTable::Query.new($t)

=over 4

=item C<:n>

Returns only the row numbers.

This is very useful to combine with the C<take> method.

 my @a = $q.grep(all(rx/US/, rx/RU/), 'Countries'):n;
 # Result: The array (2, 6)

=item C<:r>

Returns the rows, just data, no headers

 my @a = $q.grep(all(rx/US/, rx/RU/), 'Countries'):r;
 # Result: The array
 # [
 #       ("US RU", "Alcohol", 50),
 #       ("US RU CN", "Uranium", 0.01)
 # ]

=item C<:h>

Returns the rows as a hash with header information

This is the default mode. You don't need to use the C<:h> flag to get this result

 my @a1 = $q.grep(all(rx/US/, rx/RU/), 'Countries'):h; # :h is the default
 my @a2 = $q.grep(all(rx/US/, rx/RU/), 'Countries');   # @a1 and @a2 are identical
 # Result: The array
 # [
 #      {:Countries("US RU"), :Import("Alcohol"), :Tons(50)},
 #      {:Countries("US RU CN"), :Import("Uranium"), :Tons(0.01)}
 # ]

=item C<:nr>

Like C<:r> but in a hash, with the row number as the key

 my %h = $q.grep(all(rx/US/, rx/RU/), 'Countries'):nr;
 # Result: The hash
 # {
 #    "2" => $("US RU", "Alcohol", 50),
 #    "6" => $("US RU CN", "Uranium", 0.01)
 # }

=item C<:nh>

Like C<:h> but in a hash, with the row number as the key

 my %h = $q.grep(all(rx/US/, rx/RU/), 'Countries'):nh;
 # Result: The hash
 # {
 #    "2" => ${:Countries("US RU"), :Import("Alcohol"), :Tons(50)},
 #    "6" => ${:Countries("US RU CN"), :Import("Uranium"), :Tons(0.01)}
 # }

=back

=head2 C<method add-index($column-heading)>

Creates a new index, and it will return a score indicating the index quality. Values of 1, or very close to zero are the less ideals.

Nevertheless, even an index with a score 1 will help.

Example:

 my $q1 = Data::StaticTable::Query.new($t); #-- Creates index and ...
 $q1.add-index('Address');                  #-- indexes the column 'Address'


When an index is created, it is used automatically in any further C<grep> calls.


=end pod

# vim: ft=perl6
