# NAME

Text::Table::Simple - Create basic tables from a two dimensional array.


# SYNOPSIS

    use Text::Table::Simple;

    my @columns = $(['id','name','email']);
    my @rows   = (
        [1,"John Doe",'johndoe@cpan.org'],
        [2,'Jane Doe','mrsjanedoe@hushmail.com'],
    );

    my @table = lol2table(@columns,@rows);
    $_.say for @table;

    # O----O----------O-------------------------O
    # | id | name     | email                   |
    # O====O==========O=========================O
    # | 1  | John Doe | johndoe@cpan.org        |
    # | 2  | Jane Doe | mrsjanedoe@hushmail.com |
    # -------------------------------------------


# DESCRIPTION

Output table headers and rows. Take showing your Benchmark output for example:

    use Text::Levenshtein::Damerau; 
    use Text::Table::Simple;
    use Benchmark;

    my %results = timethese($runs, {
        'dld     ' => sub { Text::Levenshtein::Damerau::{"&dld($str1,$str2)"} },
        'ld      ' => sub { Text::Levenshtein::Damerau::{"&ld($str1,$str2)"}  },
    });

    my @headers = ['func','start','end','diff','avg'];
    my @rows    = %results.map({ [.key,.value.list] });

    my @table = lol2table(@headers,@rows);

    $_.say for @table;


# METHODS

### lol2table (@header_rows,@body_rows?,@footer_rows?,%options?)

Create a an array of strings that can be printed line by line to create a table view of the data.

##### %options
    # default values
    %options = {
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

# BUGS

Please report bugs to:

[https://github.com/ugexe/Perl6-Text--Table--Simple/issues](https://github.com/ugexe/Perl6-Text--Table--Simple/issues)

# AUTHOR

Nick Logan <`nlogan@gmail.com`\>
