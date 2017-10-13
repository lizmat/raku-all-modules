use v6;
use CommandLine::Usage::Header;
use CommandLine::Usage::Subcommands;
use CommandLine::Usage::Options;
use CommandLine::Usage::Positionals;

class CommandLine::Usage {

    has Str $.name is required;
    has Sub $.func is required;
    has Str $.desc is required;
    has Sub $.conf;
    has @.filter;
    has Str $.text is rw = q:to/END/;
        <% USAGE-TEXT %>:<% COMMAND-NAME %><% SUBCOMMANDS-TEXT %><% OPTIONS-TEXT %><% POSITIONALS-TEXT %>
        <% DESCRIPTION %>
        <% OPTIONS-LIST %>
        <% SUBCOMMANDS-LIST %>
        END

    submethod TWEAK {
        $!text ~~ s:g/\n//;
    }

    method parse {
        CommandLine::Usage::Header.apply(self);
        CommandLine::Usage::Subcommands.apply(self, @.filter);
        CommandLine::Usage::Options.apply(self, @.filter);
        CommandLine::Usage::Positionals.apply(self, @.filter);
        self.clean: $.text;
    }

    method replace(*%data) {
        for %data.kv -> $key, $val {
            $.text ~~ s/ '<%' \s* $key \s* '%>' \n ? /$val/;
        }
    }

    method clean(Str $text) returns Str {
        my $out = $text;
        $out ~~ s:g/ '<%' .*? '%>' \n ? //;
        $out ~~ s:g/ \n ** 2..* $/\n/;
        $out;
    }

}
