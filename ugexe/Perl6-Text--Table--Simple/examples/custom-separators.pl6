use Text::Table::Simple;

my %options = %(
  rows => {
      column_separator     => '?', # non-default
  },
  headers => {
      bottom_border        => '~', # non-default
  },
);

my @columns = <id name email>;
my @rows    = (
    [1,"John Doe",'johndoe@cpan.org'],
    [2,'Jane Doe','mrsjanedoe@hushmail.com'],
);

my @table = lol2table(@columns, @rows, |%options);
$_.say for @table;
