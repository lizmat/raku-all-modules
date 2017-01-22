
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


=begin pod

=head1 NAME

	Getopt::Kinoko - A command line parsing module which written in Perl6

=head1 VERSION

	Version 0.1.1

=head1 SYNOPSIS

=begin code

	use Getopt::Kinoko;

	my OptionSet $opts .= new();

	# --file , --read
	$opts.insert-normal("|file=s;|read=b");
	# -h | --help , -v | --version , -?
	$opts.insert-multi("h|help=b;v|version=b;?=b");
	# --quiet or --debug
	$opts.insert-radio("quiet=b;debug=b");
	# push option to normal group
	$opts.push-option(
		"o|output=s",
		"",	# default value
		callback => -> $outputs {
			die "Invalid output file"
				if $outputs.IO !~~ :f;
		}
	);
	# insert a main function
	$opts.insert-all(&main);

	getopt($opts);

	say say $*PROGRAM-NAME ~ $opts.usage if $opts<h>;

	sub main(Argument @arguments) {
		say "Arguments:";
		for @arguments -> $arg {
			say "argument		=> index:{$arg.index} value:{$arg.value}";
		}
		say "Options:";
		for < file read help version ? quiet debug output > -> $opt-name {
			say "option			=> name:{$opt-name} value:'{$opts{$opt-name}.Str}'"
				if $opts.has-value($opt-name);
		}
	}

=end code

=head1 DESCRIPTION

=begin para
	B<Getopt::Kinoko> is a powerful command line parsing module, support function
    style interface C<&getopt> can handle a single C<OptionSet> and OO style interface
    which can handle multi C<OptionSet at> same time(just as overload the MAIN routine).
    C<OptionSet> is a class used to describe a set of C<Option>, It support group the
    Options together with C<Group::Normal> C<Group::Radio> C<Group::Multi> C<Group>,
    and you can also set a C<NonOption::Front> C<NonOption::All> C<NonOption::Each> handle
    user input non-option parameters.
    The option of OptionSet can be one kind of C<Option::String> C<Option::Integer>
    C<Option::Boolean> etc. They use a simple string such as "h|help=b;" describe
    basic configuration, and you can through B<OptionSet's> interface set their
    default value and callback funtion.
    Throw a C<X::Kinoko::Fail> exception inside C<NonOption> tell C<&parser> parse failed,
    so C<&parser> will match next C<OptionSet> of C<Getopt>. You can do same thing in
    callback  which you specify when you push a option into C<OptionSet>.
=end para

=head1 COPYRIGHT

	Copyright 2015 - 2016 loren <blackcatoverwall@gmail.com>

=head1 LICENSE

	You can redistribute it or use, copy, modify it under MIT License.

=head1 USAGE

=head2 Getopt

=item1 class Getopt does Associative { ... };
=begin para
	C<Getopt> class provides an OO style interface. It can manager multi C<OptionSet>.
    C<Getopt> support name-based lookup operator, and the key is C<OptionSet>'s name.
=end para

=item1 method new(:$generate-method, :$gnu-style)
=begin para
	Create a C<Getopt> manager OptionSet. Set I<generate-method> flag if you want
    generate option get method for C<OptionSet>. If you want your program support
    B<gnu-style> please use I<:$gnu-style> flag.
=end para

=item1 multi method push(Str $name, OptionSet $optset) returns Getopt
=begin para
	Add the C<$optset> to C<Getopt>, and set it's name as C<$name>.
=end para

=item1 multi method push(Str $name, Str $optset-string, &callback = Block) returns Getopt;
=begin para
	![deprecated]
=end para

=item1 method current() returns Str
=begin para
	Get current matched C<OptionSet>'s name.
=end para

=item1 method parse(@!args = @*ARGS, Str :$prefix="", :&parser = &kinoko-parse) returns Array
=begin para
	Use C<&parser> parsing command line arguments C<@!args>, use C<$prefix> as method
    prefix if C<$generate-method> flag is True. The method return all I<Non-Option-Argument>.
=end para

=item1 multi method usage(Str $name)
=begin para
	Generate a simple usage message without C<$*PROGRAM-NAME> for OptionSet C<Getopt{$name}>.
=end para

=item1 multi method usage()
=begin para
	Generate a full usage message with I<$*PROGRAM-NAME> for all OptionSet.
=end para

=item1  other
=begin para
	AT-KEY EXISTS-KEY keys values kv
=end para



=head2 OptionSet

=item1 class OptionSet does DeepClone { ... };
=begin para
	C<OptionSet> manager multi C<Option>, it provide many interface handle C<Option> add or access.
=end para
=begin code
	my OptionSet $optset .= new(); # create a OptionSet
=end code

=item1 method insert-normal(Str $opts) returns OptionSet
=begin para
	Insert a normal group into C<OptionSet>. Normal group is main/default group of the
    C<OptionSet>, it has many Option can set by user at the same time.
=end para
=begin code
	$optset.insert-normal("h|help=b;v|version=b;?=b;|usage=b;");
=end code

=item1 method get-normal() returns Group::Normal
=begin para
	Return current normal group.
=end para

=item1 method has-normal() returns Bool
=begin para
	Return normal group exists or not.
=end para

=item1 method insert-multi(Str $opts) returns OptionSet
=begin para
	Insert a multi group into C<OptionSet>. Multi group has many C<Option> can set by user at the same time.
=end para

=item1 method get-multi() returns Array[Group::Multi]
=begin para
	Return all multi group.
=end para

=item1 method has-multi() returns Bool
=begin para
	Return has multi group or not.
=end para

=item1 method insert-radio(Str $opts, :$force = False) returns OptionSet
=begin para
	Insert a radio group into C<OptionSet>. Radio group hold many C<Option> but
    can set only one at the same time. This group must be have value when C<:$force> is True.
=end para

=item1 method get-radio() returns Array[Group::Radio]
=begin para
	Return all radio group.
=end para

=item1 method has-radio() returns Bool
=begin para
	Return has radio group or not.
=end para

=item1 method insert-all(&callback) returns OptionSet
=begin para
	Insert a handler can process all-NOA(non-option argument). It should call by parser when parse complete.
    Callback signature can be either (Argument @arg) or (Argument @arg, OptionSet $opts).
=end para

=item1 method get-all() returns Callable
=begin para
	Return all-NOA handler callback.
=end para

=item1 method has-all() returns Bool
=begin para
	Return has all-NOA handler or not.
=end para

=item1 method insert-front(&callback) returns OptionSet
=begin para
	Insert a handler process the first NOA(non-option argument). It should call by parser when got first NOA.
    Callback signature can be either (Argument $arg) or (Argument $arg, OptionSet $opts).
=end para

=item1 method get-front() returns Callable
=begin para
	Return front-NOA handler callback.
=end para

=item1 method has-front() returns Bool
=begin para
	Return has front-NOA handler or not.
=end para

=item1 method insert-each(&callback) returns OptionSet
=begin para
	Insert a handler process every NOA(non-option argument). It should call by parser when got an NOA everytime.
    Callback signature can be either (Argument $arg) or (Argument $arg, OptionSet $opts).
=end para

=item1 method get-each() returns Callable
=begin para
	Return each-NOA handler callback.
=end para

=item1 method has-each() returns Bool
=begin para
	Return has each-NOA handler or not.
=end para

=item1 multi method push-option(Str $opt, :&callback, :$comment, :$normal) returns OptionSet
=begin para
	Insert a C<Option> into normal group. C<&callback> will be call When option set by user.
=end para

=item1 multi method push-option(Str $opt, $value, :&callback, :$comment, :$normal) returns OptionSet
=begin para
	Insert a C<Option> has a default value into normal group. C<&callback> will be call When option set by user.
=end para

=item1 method append-options(Str $opts, :$normal) returns OptionSet
=begin para
	Insert multi C<Option> into normal group.
=end para

=item1 method get-option(Str $name, :$long, :$short, :$normal, :$radio, :$multi) returns Option
=begin para
	Get a C<Option> by its name and option type from normalã€radio or multi group.
=end para

=item1 method has-option(Str $name, :$long, :$short) returns Bool
=begin para
	Return C<True> if C<Option> C<$name> exists.
=end para

=item1 method set-value(Str $name, $value, :$long, :$short) returns Bool
=begin para
	Set C<Option> C<$name> value to C<$value>. Return C<False> if value check failed or
    C<Option> not exists. The method not call C<&callback> associate with C<Option> C<$name>.
=end para

=item1 method set-value-callback(Str $name, $value, :$long, :$short) returns Bool
=begin para
	Set C<Option> C<$name> value to C<$value> and call C<&callback> associate with
    C<Option> C<$name>. Return C<False> if value check failed or C<Option> not exists.
=end para

=item1 method set-callback(Str $name, &callback, :$long, :$short) returns Bool
=begin para
	Set C<Option> C<$name> callback to &callback.
=end para

=item1 method set-comment(Str $name, $comment, :$long, :$short) returns Bool
=begin para
    Set C<Option> comment.
=end para

=item1 method has-value(Str $name, :$long, :$short) returns Bool
=begin para
	Return C<True> if C<Option> C<$name> has value.
=end para

=item1 method AT-KEY(::?CLASS::D: Str \key)
=begin para
	Return C<Option> C<key> value.
=end para
=begin code
	say $optset<h>; # equal to "say $optset{'help'}"
=end code

=item1 method ASSIGN-KEY(::?CLASS::D:D Str \key, $value)
=begin para
	Set C<Option> C<key> value to C<$value>.
=end para
=begin code
	$optset<h> = False;
=end code

=item1 method EXISTS-KEY(Str \key) returns Bool
=begin para
	Return C<True> if C<Option> C<key> exists.
=end para

=item1 method keys() returns Array
=begin para
	Return all C<Option>s name.
=end para

=item1 method values() returns Array
=begin para
	Return all C<Option> value.
=end para

=item1 method check-force-value()
=begin para
	The force C<Option> must be has value. When check failed C<X::Kinoko> will be throw.
=end para

=item1 method generate-method(Str $prefix)
=begin para
	Generate a get-method for evrey C<Option>. The method name will use giving C<$prefix> as their prefix.
=end para

=item1 method usage() returns Str
=begin para
	Generate a simple usage without C<$*PROGRAM-NAME>.
=end para

=item1 method deep-clone() returns OptionSet
=begin para
	Return a copy of current C<OptionSet>.
=end para

=item1 method comment() returns Array
=begin para
    Return a B<Array> contains B<Option's> I<long-name> in the first column or
    I<short-name> in the middle column and I<comment> in the last column, that
    is ("--long-option", "-short-option", "option comment").
=end para

=item1 method comment($indent) returns Array
=begin para
    Return a table-formated B<Array> contains B<Option's> name in the first column and
    I<comment> in the second column, that is ("-short-option|--long-option", "option comment").
=end para



=head2 Option

=item1 role Option { ... };
=begin para
    An option instance is represent a command line option.
=end para

=item1 is-short returns Bool
=begin para
    Return True if the option support short name access.
=end para

=item1 is-long returns Bool
=begin para
    Return True if the option support long name access.
=end para

=item1 is-force returns Bool
=begin para
    Return True if the option is a force option.
=end para

=item1 is-integer returns Bool
=begin para
    Return True if the option is a integer option.
=end para

=item1 is-string returns Bool
=begin para
    Return True if the option is a string option.
=end para

=item1 is-boolean returns Bool
=begin para
    Return True if the option is a boolean option.
=end para

=item1 is-array returns Bool
=begin para
    Return True if the option is a array option.
=end para

=item1 is-hash returns Bool
=begin para
    Return True if the option is a hash option.
=end para

=item1 major-type returns Str
=begin para
    Return the type of option.
=end para

=item1 has-callback returns Bool
=begin para
    Return True if the option has a callback.
=end para

=item1 has-value returns Bool
=begin para
    Return True if the option has a value.
=end para

=item1 short-name returns Str
=begin para
    Return the option's short name.
=end para

=item1 long-name returns Str
=begin para
    Return the option's long name.
=end para

=item1 callback
=begin para
    Return the option's callback.
=end para

=item1 value
=begin para
    Return the option's value.
=end para

=item1 set-callback(&cb)
=begin para
    Set the option's callback.
=end para

=item1 set-comment(Str $cm)
=begin para
    Set the option's comment.
=end para

=item1 set-value($value)
=begin para
    Set the option's value
=end para

=item1 set-value-callback($value)
=begin para
    Set the option's value and call the callback of it.
=end para

=item1 comment returns Str
=begin para
    Return the comment of the option.
=end para

=item1 usage returns Str
=begin para
    Return a usage such as `short|long=<type>` of the option.
=end para

=end pod
