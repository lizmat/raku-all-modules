use Text::Table::Simple;

my @columns = <id name email>;
my @rows    = (
    [1,"John Doe",'johndoe@cpan.org'],
    [2,'Jane Doe','mrsjanedoe@hushmail.com'],
);

my @table = lol2table(@columns,@rows);
.say for @table;
