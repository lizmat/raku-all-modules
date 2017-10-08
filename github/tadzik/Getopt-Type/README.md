# Getopt::Type

## MAIN? Getopt semantics? Why not both?

    use Getopt::Type;
    
    sub MAIN(*%opts where getopt(<f|force v|verbose>)) {
        say "Forcing!"   if %opts<force>;
        say "Verbosing!" if %opts<verbose>;
        say %opts.perl;
    }

    # try `perl6 -Ilib README.md -fv`
