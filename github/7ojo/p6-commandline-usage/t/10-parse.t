use v6;
use lib 'lib';
use Test;
use CommandLine::Usage;

plan 2;

{
    #| My explanation here
    multi my-main('one', 'two') { ... }
    multi my-main('one', 'three') { ... }
    multi my-main('three') { ... }
    multi my-main('four') { ... }
    my $usage = CommandLine::Usage.new(
        :name( 'my-command' ),
        :desc( &my-main.candidates[0].WHY.Str ),
        :func( &my-main ),
        :filter<one two>
        );
    my $text = $usage.parse;
    my $versus = qq:to/END/;
    
    Usage:\tmy-command one two

    My explanation here
    END
    is $text, $versus, 'my-command one two --help';
}
{
    #| Explanation of subcommand run and it's options
    multi my-main('run',
        Str :$project,
        Str :$network = 'acme',
        Str :$domain = 'localhost',
        Str :$data-path = '~/.platform'
        ) { ... }

    multi my-main('stop',
        Str :$project,
        Str :$data-path = '~/.platform'
        ) { ... }

    my $usage = CommandLine::Usage.new(
        :name( 'my-command' ),
        :desc( &my-main.candidates[0].WHY.Str ),
        :func( &my-main ),
        :filter<run>
        );
    
    my $text = $usage.parse;
    my $versus = qq:to/END/;
    
    Usage:\tmy-command run [OPTIONS]

    Explanation of subcommand run and it's options

    Options:
          --project string     
          --network string     (default "acme")
          --domain string      (default "localhost")
          --data-path string   (default "~/.platform")
    END
    is $text, $versus, "my-command run --help";
}

