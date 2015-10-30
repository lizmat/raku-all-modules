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


proto sub lol2table(|) {*}
multi sub lol2table (@body_rows, *%options) {
    # no header or footer, just body
    _build_table(:@body_rows, |%options);
}
multi sub lol2table (@header_rows, @body_rows, *%options) {
    # header and body, no footer
    _build_table(:@header_rows, :@body_rows, |%options);
}
multi sub lol2table (@header_rows, @body_rows, @footer_rows, *%options) is export {
    # header, body, and footer
    _build_table(:@header_rows, :@body_rows, :@footer_rows, |%options);
}

sub _build_table (:@header_rows, :@body_rows is raw, :@footer_rows, *%o) is export {
    my %options = _build_options(|%o);
    my @widths  = _get_column_widths(@header_rows, |@body_rows);
    my @rows    = flat   _build_header(@widths, @header_rows, |%options),
                        _build_body(@widths, |@body_rows, |%options),
                        _build_footer(@widths,|%options);
    return @rows.grep(*.so).cache;
}

sub _build_header (@widths, **@rows, *%o) is export {
    my @processed;

    # Top border
    @processed.append( %o<headers><corner_marker>
                    ~ %o<headers><top_border>
                    ~ @widths.map({ %o<headers><top_border> x $_ }).join(%o<headers><top_border>
                        ~ %o<headers><corner_marker>
                        ~ %o<headers><top_border>
                        ) 
                    ~ %o<headers><top_border>
                    ~ %o<headers><corner_marker>
                );

    return @processed unless @rows;

    # Column rows
    @processed.append( _row2str(@widths, $_, :type<headers>, |%o) ) for @rows;

    # Bottom border
    @processed.append( %o<headers><corner_marker>
                    ~ %o<headers><bottom_border>
                    ~ @widths.map({ %o<headers><bottom_border> x $_ }).join(%o<headers><bottom_border>
                        ~ %o<headers><corner_marker>
                        ~ %o<headers><bottom_border>
                        ) 
                    ~ %o<headers><bottom_border>
                    ~ %o<headers><corner_marker>
                );


    return @processed;
}

sub _build_body (@widths, **@rows, *%o) is export {
    my Str @processed;

    # Process rows
    @processed.append( _row2str(@widths, $_, :type<rows>, |%o) ) for @rows;

    # Bottom border
    @processed.append( %o<rows><corner_marker>
                    ~ %o<rows><bottom_border>
                    ~ @widths.map({ %o<rows><bottom_border> x $_ }).join(%o<rows><bottom_border>
                        ~ %o<rows><corner_marker>
                        ~ %o<rows><bottom_border>
                        ) 
                    ~ %o<rows><bottom_border>
                    ~ %o<rows><corner_marker>
                );

    return @processed;
}

sub _build_footer (@widths, **@rows, *%o) is export {
    return unless @rows.elems;
    my Str @processed;

    # Column rows
    @processed.append( _row2str(@widths, $_, :type<headers>, |%o) ) for @rows;

    # Bottom border
    @processed.append( %o<footers><corner_marker>
                    ~ %o<footers><bottom_border>
                    ~ @widths.map({ %o<footers><bottom_border> x $_ }).join(%o<footers><bottom_border>
                        ~ %o<footers><corner_marker>
                        ~ %o<footers><bottom_border>
                        ) 
                    ~ %o<footers><bottom_border> 
                    ~ %o<footers><corner_marker> 
                );

    return @processed;
}

# returns formatted row
sub _row2str (@widths, @cells, :$type where {$_ ~~ any(%defaults.keys)}, *%o) {
    my $csep   = %o{$type}<column_separator> // '|';
    my $format = "$csep " ~ join(" $csep ", @widths.map({"%-{$_}s"}) ) ~ " $csep";
    return sprintf( $format, @cells.map({ $_ // '' }) ); 
}

# Iterate over ([1,2,3],[2,3,4,5],[33,4,3,2]) to find the longest string in each column
sub _get_column_widths (**@rows, *%o)  is export {
    my @r = @rows.grep(*.so);
    return (0..@r[0].end).map( -> $col {
        @r[*;$col].max(*.chars).chars;
    } );
}

sub _build_options(*%o) {
    my %options = %defaults;
    %o.keys.map: -> $type {
        eager %o{$type}.hash.map: {
            %options{$type}{$_.key} = $_.value;
        }
    }
    %options;
}
