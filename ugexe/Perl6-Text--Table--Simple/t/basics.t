use v6;
use Test;
plan 4;

use Text::Table::Simple;


my @columns = <id name email>;
my @rows   = (
    [1,"John Doe",'johndoe@cpan.org'],
    [2,'Jane Doe','mrsjanedoe@hushmail.com'],
);
constant %options = {
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


# Determine max column width
subtest {
    my @widths = _get_column_widths(@columns,|@rows);
    is-deeply @widths, [2,8,23], 'Max column widths';
}, "_get_column_widths";


# Test formatted header output
subtest {
    my @expected = (
        'O----O------O-------O',
        '| id | name | email |',
        'O====O======O=======O',
    );

    my @widths = _get_column_widths( @columns );
    my @output = _build_header(@widths, @columns, |%options);

    is-deeply @output, @expected, 'Create a header'
}, "_build_header";


# Test formatted multi-row header output (2nd longer)
subtest {
    my @columns2 = @columns.map({ $_.map({ $_ ~ '2' }).Slip });
    my @expected = (
        'O-----O-------O--------O',
        '| id  | name  | email  |',
        '| id2 | name2 | email2 |',
        'O=====O=======O========O',
    );

    # Test when first row labels are shorter than others
    {
        my @widths = _get_column_widths( @columns, @columns2 );
        my @output = _build_header( @widths, @columns, @columns2, |%options );

        is-deeply @output, @expected, 'Multi row header with first header row cells as the longest';
    }

    # Test when last row labels are shorter than others
    {
        my @widths = _get_column_widths( @columns2,@columns );
        my @new_expected := @expected;
        (@new_expected[1], @new_expected[2]) = (@new_expected[2], @new_expected[1]);
        my @output = _build_header( @widths, @columns2, @columns, |%options );

        is-deeply @output, @expected, 'Multi row header with last header row cells as the longest';
    }
}, "_build_header with multiple header rows";


# Test formatted table
subtest {
    my @expected = (
        'O----O----------O-------------------------O',
        '| id | name     | email                   |',
        'O====O==========O=========================O',
        '| 1  | John Doe | johndoe@cpan.org        |',
        '| 2  | Jane Doe | mrsjanedoe@hushmail.com |',
        '-------------------------------------------',
    );
    my @output = _build_table( :header_rows(@columns), :body_rows(@rows) );

    is @output, lol2table(@columns, @rows), 'Public api matches private api';
    is-deeply @output, @expected, 'Create a table (header + body)'
}, "_build_table";
