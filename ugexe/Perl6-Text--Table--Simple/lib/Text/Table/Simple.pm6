use v6;
unit class Text::Table::Simple;

constant %defaults = {
  rows => {
      column_separator     => '|',
      corner_marker        => '-',
      bottom_border        => '-',
  },
  headers => {
      top_border           => '-',
      column_separator     => '|',
      corner_marker        => 'O',
      bottom_border        => '=',
  },
  footers => {
      column_separator     => 'I',
      corner_marker        => '%',
      bottom_border        => '*',
  },
};


sub lol2table (@header_rows,@body_rows?,@footer_rows?,%options = %defaults) is export {
    _build_table(@header_rows,@body_rows,@footer_rows,%options);
}

sub _build_table (@header_rows,@body_rows?,@footer_rows?,%options = %defaults) is export {
    my @widths = _get_column_widths(@header_rows,@body_rows);  
    my @rows   = flat _build_header(@widths,@header_rows), _build_body(@widths,@body_rows), _build_footer(@widths);
    return @rows.grep(*.so).list;
}

sub _build_header (@widths, @columns, %options = %defaults) is export {
    my @processed;

    # Top border
    @processed.push( %options<headers><corner_marker>  
                    ~ %options<headers><top_border>
                    ~ @widths.map({ %options<headers><top_border> x $_ }).join(%options<headers><top_border>
                        ~ %options<headers><corner_marker>
                        ~ %options<headers><top_border>
                        ) 
                    ~ %options<headers><top_border> 
                    ~ %options<headers><corner_marker> 
                );

    # Column rows
    @processed.push( _row2str(@widths, @$_) ) for @columns; # TODO: pass %options

    # Bottom border
    @processed.push( %options<headers><corner_marker>  
                    ~ %options<headers><bottom_border>
                    ~ @widths.map({ %options<headers><bottom_border> x $_ }).join(%options<headers><bottom_border>
                        ~ %options<headers><corner_marker>
                        ~ %options<headers><bottom_border>
                        ) 
                    ~ %options<headers><bottom_border> 
                    ~ %options<headers><corner_marker> 
                );


    return @processed;
}

sub _build_body (@widths, @rows, %options = %defaults) is export {
    my Str @processed;

    # Process rows
    @processed.push( _row2str(@widths, @$_) ) for @rows; # TODO: pass %options

    # Bottom border
    @processed.push( %options<rows><corner_marker>  
                    ~ %options<rows><bottom_border>
                    ~ @widths.map({ %options<rows><bottom_border> x $_ }).join(%options<rows><bottom_border>
                        ~ %options<rows><corner_marker>
                        ~ %options<rows><bottom_border>
                        ) 
                    ~ %options<rows><bottom_border> 
                    ~ %options<rows><corner_marker> 
                );

    return @processed;
}

sub _build_footer (@widths, @rows?, %options = %defaults) is export {
    return unless @rows.elems;
    my Str @processed;

    # Column rows
    @processed.push( _row2str(@widths, @$_) ) for @rows; # TODO: pass %options

    # Bottom border
    @processed.push( %options<footers><corner_marker>  
                    ~ %options<footers><bottom_border>
                    ~ @widths.map({ %options<footers><bottom_border> x $_ }).join(%options<footers><bottom_border>
                        ~ %options<footers><corner_marker>
                        ~ %options<footers><bottom_border>
                        ) 
                    ~ %options<footers><bottom_border> 
                    ~ %options<footers><corner_marker> 
                );

    return @processed;
}

# returns formatted row
sub _row2str (@widths, @cells, %options = %defaults) {
    my $sep  = '-';
    my $mark = 'O';
    my $csep = '|';

    # sprintf format
    my $format = "$csep " ~ join(" $csep ", @widths.map({"%-{$_}s"}) ) ~ " $csep";
    return sprintf( $format, @cells.map({ $_ // '' }) ); 
}

# Iterate over ([1,2,3],[2,3,4,5],[33,4,3,2]) to find the longest string in each column
sub _get_column_widths ( *@rows ) is export {
    return (0..@rows[0].elems-1).map( -> $col { 
        reduce { max($^a, $^b)}, map { .chars }, @rows[*;$col]; 
    } );
}
