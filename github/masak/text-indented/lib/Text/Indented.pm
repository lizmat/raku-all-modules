grammar Text::Indented;

class Suite {
    my subset Item where Str | Suite;

    has Item @.items handles <push at_pos Numeric Bool>;
}

class TooMuchIndent is Exception {}
class PartialIndent is Exception {}
class InitialIndent is Exception {}

constant TABSTOP = 4;

regex TOP {
    :my @*SUITES = Suite.new;

    <line>*

    { make root_suite }
}

sub indent { @*SUITES.end }
sub root_suite { @*SUITES[0] }
sub current_suite { @*SUITES[indent] }
sub add_to_current_suite($item) { current_suite.push($item) }

sub increase_indent($new_suite) { @*SUITES.push($new_suite) }
sub decrease_indent { pop @*SUITES }

regex line {
    ^^ (<{ "\\x20" x TABSTOP }>*) (\h*) (\N*) $$ \n?

    {
        my $new_indent = $0.chars div TABSTOP;
        my $partial_indent = ~$1;
        my $line = ~$2;

        die TooMuchIndent.new
            if $new_indent > indent() + 1;
        die PartialIndent.new
            if $partial_indent;
        die InitialIndent.new
            if !root_suite() && $new_indent > 0;

        if $new_indent > indent() {
            my $new_suite = Suite.new;
            add_to_current_suite($new_suite);
            increase_indent($new_suite);
        }
        elsif $new_indent < indent() {
            decrease_indent until indent() == $new_indent;
        }

        add_to_current_suite($line);
    }
}
