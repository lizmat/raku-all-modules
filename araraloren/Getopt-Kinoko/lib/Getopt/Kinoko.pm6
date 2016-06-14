
use v6;

use Getopt::Kinoko::Parser;
use Getopt::Kinoko::Option;
use Getopt::Kinoko::OptionSet;
use Getopt::Kinoko::Exception;

#| Getopt can manager multi OptionSet
class Getopt does Associative {
    has OptionSet   %!optionsets handles <AT-KEY EXISTS-KEY keys values kv>;
    has             $!current;
    has Bool        $!generate-method;
    has Bool        $!gnu-style;
    has             @!args;

    #| new can take two named parameters
    method new(:$generate-method, :$gnu-style) {
        self.bless(:generate-method(?$generate-method), :gnu-style(?$gnu-style));
    }

    submethod BUILD(:$!generate-method, :$!gnu-style) { }


    #| name: a not null string;
    multi method push(Str $name, OptionSet $optset) {
        %!optionsets.push: $name => $optset;
        self;
    }

    #| name: a not null string;
    #| optset-string: a option string;
    #| &callback: a sub or Block for porcess not option args.
    multi method push(Str $name, Str $optset-string, &callback = Block) {
        %!optionsets.push: $name => OptionSet.new($optset-string, &callback);
        self;
    }

    #| get current name of OptionSet
    method current() {
        $!current;
    }

    #| method used for parse args method
    method parse(@!args = @*ARGS, Str :$prefix = "", :&parser = &kinoko-parser) returns Array {
    #= C<@!args> default value is C<@*ARGS>;
    #= C<$prefix> specify name prefix of generated method for option if Getopt's
    #= C<$!generate-method> is True;
    #= C<&parser> is the parser you want to use parse command, default value is
    #= C<&kinoko-parser>.
        my @noa;
        my $optset;

        #= Method will traveral all OptionSet;
        for %!optionsets.keys -> $key {
            try {
                $optset := %!optionsets{$key};

                #= &parser should return an Array of NOA, and should has two overload,
                #= one can handle gnu-style command parse.
                @noa := $!gnu-style ??
                    &parser(@!args, $optset, True) !! &parser(@!args, $optset);

                $optset.check-force-value();

                # generate method when needed
                $optset.generate-method(:$prefix) if $!generate-method;

                # store current OptionSet name
                $!current := $key;

                last;

                CATCH {
                    #= When parse failed, &parser should throw expection
                    #= X::Kinoko::Fail.
                    when X::Kinoko::Fail {
                        $!current = "";
                    }
                    default {
                        note .message;
                        ...
                    }
                }
            }
        }

        #= Method returns NOA when parse end.
        @noa;
    }

    #| Generate simple usage without C<$*PROGRAM-NAME>,
    multi method usage(Str $name) {
        #= i. e. "[--boolean]", "[-s|--string=<string>]"
        return "" unless %!optionsets{$name}:exists;
        return %!optionsets{$name}.usage();
    }

    #| generate full usage
    multi method usage() {
        my Str $usage = "Usage:\n";

        for %!optionsets.values {
            $usage ~= $*PROGRAM-NAME ~ .usage ~ "\n";
        }
        $usage.chomp;
    }
}

#| getopt process one OptionSet
sub getopt(OptionSet \opset, @args = @*ARGS, Str :$prefix = "", :&parser = &kinoko-parser, :$gnu-style, :$generate-method) is export returns Array {
    my @noa;

    @noa := $gnu-style ?? &parser(@args, opset, True) !! &parser(@args, opset);

    opset.check-force-value();

    opset.generate-method($prefix) if $generate-method;

    @noa;
}
