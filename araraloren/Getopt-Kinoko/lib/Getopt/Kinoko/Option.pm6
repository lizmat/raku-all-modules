
use v6;

use Getopt::Kinoko::DeepClone;
use Getopt::Kinoko::Exception;

role Option {
    has $!sn;       #= option long name
    has $!ln;       #= option short name
    has &!cb;       #= option callback signature(Option -->)
    has $!force;    #= option optional
    has $!cm;      #= option usage comment

    #| public initialize method
    method !initialize(:$sn, :$ln, :$force, :&cb, :$cm) {
        unless $sn.defined || $ln.defined {
            X::Kinoko.new(msg => 'Need option name.').throw();
        }

        my %build;

        %build<sn>      = $sn       if $sn;
        %build<ln>      = $ln       if $ln;
        %build<cb>      = &cb       if &cb;
        %build<cm>      = $cm       if $cm;
        %build<force>   = ?$force;

        return self.bless(|%build);
    }

    submethod BUILD(:$!sn, :$!ln, :&!cb, :$!force, :$!cm) { }

    #| has short name
    method is-short {
        $!sn.defined;
    }

    #| has long name
    method is-long {
        $!ln.defined;
    }

    #| optional ?
    method is-force {
        ?$!force;
    }

    #| is integer option
    method is-integer() {
        False;
    }

    #| is string option
    method is-string() {
        False;
    }

    #| is boolean option
    method is-boolean() {
        False;
    }

    #| is array option
    method is-array() {
        False;
    }

    #| is hash option
    method is-hash() {
        False;
    }

    #| has callback
    method has-callback {
        &!cb.defined;
    }

    #| get short name of this option;
    #| return null string when not have a short name
    method short-name {
        self.is-short ?? $!sn !! "";
    }

    #| get long name of this option;
    #| return null string when not have a long name
    method long-name {
        self.is-long ?? $!ln !! "";
    }

    #| get callback
    method callback {
        &!cb;
    }

    #| get usage comment
    method comment {
        $!cm // "";
    }

    #| set callback
    method set-callback(&cb) {
        &!cb = &cb;
    }

    #| set comment
    method set-comment(Str $cm) {
        $!cm = $cm;
    }

    #| match with short or long name
    #| :long and :short both not set equivalent to :long and :short both set
    method match-name(Str $name, :$long, :$short) {
        my ($lb, $sb) = ($name eq self.long-name, $name eq self.short-name);

        return ($lb || $sb) if ($long && $short || !$long && !$short);

        return $lb if $long;

        return $sb if $short;
    }

    method usage {
        my $usage = "";

        $usage ~= '-'  ~ self.short-name if self.is-short;
        $usage ~= '|'  if self.is-long && self.is-short;
        $usage ~= '--' ~ self.long-name  if self.is-long;
        $usage ~= '=<' ~ self.major-type ~ '>' if self.major-type ne "boolean";

        $usage;
    }

    method perl {
        my $perl = self.^name ~ '.new(';

        $perl ~= "sn => " ~ (self.is-short ?? $!sn !! "Any");
        $perl ~= ', ';
        $perl ~= "ln => " ~ (self.is-long  ?? $!ln !! "Any");
        $perl ~= ', ';
        $perl ~= "cb => " ~ (self.has-callback ?? &!cb.perl !! "Any");
        $perl ~= ', ';
        $perl ~= "force => " ~ $!force.perl;
        $perl ~= ', ';
        $perl ~= "value => " ~ (self.has-value ?? self.value.perl !! 'Any');
        $perl ~= ')';

        $perl;
    }

    method has-value { ... }

    #| set value
    #| "set" is mean push when option is hash or array
    method set-value($value) { ... }

    #| set value and then call callback
    method set-value-callback($value) { ... }

    method value { ... }

    #| reset value
    method reset { ... }

    #| get option type
    #| will return long option type such as "string", "boolean" ..
    method major-type { ... }
}

#=[
    inetger option
]
class Option::Integer does Option does DeepClone {
    has Int $!value;

    method new(:$sn, :$ln, :$force, :&cb, :$value, :$cm) {
        self!initialize(:$sn, :$ln, :$force, :&cb, :$cm)!initialize-value($value);
    }

    method !initialize-value($value, :$use-default = True, :$callcb = False) {
        my $name = self.is-long ?? '--' ~ self.long-name !! '-' ~ self.short-name;
        my Int $int;

        if $value.defined {
            if $value !~~ Int {
                try {
                    $int = $value.Int; # or use subset ?
                    CATCH {
                        default {
                            X::Kinoko.new(msg => "$value: Option $name need integer.").throw();
                        }
                    }
                }
            }
            else {
                $int = $value;
            }
        }
        elsif $use-default {
            $int = self!default-value;
        }
        else {
            X::Kinoko.new(msg => ": Option $name need a value.").throw();
        }
        $!value = $int;
        self.callback()($!value) if $callcb && self.has-callback;
        self;
    }

    method !default-value {
        Int
    }

    method has-value {
        $!value.defined;
    }

    method set-value($value) {
        self!initialize-value($value, :!use-default);
    }

    method set-value-callback($value) {
        self!initialize-value($value, :!use-default, :callcb);
    }

    method value {
        $!value;
    }

    method reset {
        $!value = self!default-value;
    }

    method major-type {
        "integer";
    }

    method is-integer() {
        True;
    }

    multi method deep-clone() {
        #| call initialize-value !!!
        self.bless(:$!sn, :$!ln, :&!cb, :$!force, :$!cm)!initialize-value(DeepClone.deep-clone($!value));
    }
}

class Option::String does Option does DeepClone {
    has Str $!value ;

    method new(:$sn, :$ln, :$force, :&cb, :$value, :$cm) {
        self!initialize(:$sn, :$ln, :$force, :&cb, :$cm)!initialize-value($value);
    }

    method !initialize-value($value, :$use-default = True, :$callcb = False) {
        my $name = self.is-long ?? '--' ~ self.long-name !! '-' ~ self.short-name;
        my Str $string;

        if $value.defined {
            if $value !~~ Str {
                try {
                    $string = $value.Str;
                    CATCH {
                        default {
                            X::Kinoko.new(msg => "$value: Option $name need string.").throw();
                        }
                    }
                }
            }
            else {
                $string = $value;
            }
        }
        elsif $use-default {
            $string = self!default-value;
        }
        else {
            X::Kinoko.new(msg => ": Option $name need a value.").throw();
        }
        $!value = $string;
        self.callback()($!value) if $callcb && self.has-callback;
        self;
    }

    method !default-value {
        Str
    }

    method has-value {
        $!value.defined;
    }

    method set-value($value) {
        self!initialize-value($value, :!use-default);
    }

    method set-value-callback($value) {
        self!initialize-value($value, :!use-default, :callcb);
    }

    method value {
        $!value;
    }

    method reset {
        $!value = self!default-value;
    }

    method major-type {
        "string";
    }

    method is-string() {
        True;
    }

    multi method deep-clone() {
        self.bless(:$!sn, :$!ln, :&!cb, :$!force, :$!cm)!initialize-value(DeepClone.deep-clone($!value));
    }
}

class Option::Array does Option does DeepClone {
    has @!value;

    method new(:$sn, :$ln, :$force, :&cb, :$value, :$cm) {
        self!initialize(:$sn, :$ln, :$force, :&cb, :$cm)!initialize-value($value);
    }

    method !initialize-value($value, :$use-default = True, :$callcb = False) {
        my $name = self.is-long ?? '--' ~ self.long-name !! '-' ~ self.short-name;
        my @array;

        if $value.defined {
            if $value !~~ Array {
                try {
                    @array = $value.Array;
                    CATCH {
                        default {
                            X::Kinoko.new(msg => "$value: Option $name need array.").throw();
                        }
                    }
                }
            }
            else {
                @array = @$value;
            }
        }
        elsif $use-default {
            @array = self!default-value;
        }
        else {
            X::Kinoko.new(msg => ": Option $name need a value.").throw();
        }
        @!value.append: @array;
        self.callback()(@!value) if $callcb && self.has-callback;
        self;
    }

    method !default-value {
        @[]
    }

    method has-value {
        @!value.elems > 0;
    }

    method set-value($value) {
        self!initialize-value($value, :!use-default);
    }

    method set-value-callback($value) {
        self!initialize-value($value, :!use-default, :callcb);
    }

    method value {
        @!value;
    }

    method major-type {
        "array";
    }

    method reset {
        @!value = self!default-value;
    }

    method is-array() {
        True;
    }

    multi method deep-clone() {
        self.bless(:$!sn, :$!ln, :&!cb, :$!force, :$!cm)!initialize-value(DeepClone.deep-clone(@!value));;
    }
}

class Option::Hash does Option does DeepClone {
    has %!value;

    method new(:$sn, :$ln, :$force, :&cb, :$value, :$cm) {
        self!initialize(:$sn, :$ln, :$force, :&cb, :$cm)!initialize-value($value);
    }

    method !initialize-value($value, :$use-default = True, :$callcb = False) {
        my $name = self.is-long ?? '--' ~ self.long-name !! '-' ~ self.short-name;
        my %hash;

        if $value.defined {
            if $value !~~ Hash {
                %hash = self!parse-as-hash($value);
                unless %hash {
                    X::Kinoko.new(msg => "$value: Option $name need hash.").throw();
                }
            }
            else {
                %hash = %$value;
            }
        }
        elsif $use-default {
            %hash = self!default-value;
        }
        else {
            X::Kinoko.new(msg => ": Option $name need a value.").throw();
        }
        %!value.append: %hash;
        self.callback()(%!value) if $callcb && self.has-callback;
        self;
    }

    method !parse-as-hash($value) {
        my regex hkey { .* };
        my regex comma { '=>' };
        my regex hvalue { .* };

        if $value.Str ~~
            /^ <.ws> [\' <hkey> \' || <hkey> ] <.ws> <.&comma>
                <.ws> [\' <hvalue> \' || <hvalue> ]
            |
            \:<hkey>\<<hvalue>\>
            |
            \:<hkey> \{[ \' <hvalue> \' || <hvalue> ]\}/ {
            return %($<hkey>.Str => $<hvalue>.Str);
        }
        else {
            return Hash;
        }
    }

    method !default-value {
        %{};
    }

    method has-value {
        %!value.elems > 0;
    }

    method set-value($value) {
        self!initialize-value($value, :!use-default);
    }

    method set-value-callback($value) {
        self!initialize-value($value, :!use-default, :callcb);
    }

    method value {
        %!value;
    }

    method reset {
        %!value = self!default-value;
    }

    method major-type {
        "hash";
    }

    method is-hash() {
        True;
    }

    multi method deep-clone() {
        self.bless(:$!sn, :$!ln, :&!cb, :$!force, :$!cm)!initialize-value(DeepClone.deep-clone(%!value));;
    }
}

#=[
    boolean option
]
class Option::Boolean does Option does DeepClone {
    has Bool $!value;

    method new(:$sn, :$ln, :$force, :&cb, :$value, :$cm) {
        self!initialize(:$sn, :$ln, :$force, :&cb, :$cm)!initialize-value($value);
    }

    method !initialize-value($value, :$use-default = True, :$callcb = False) {
        my $name = self.is-long ?? '--' ~ self.long-name !! '-' ~ self.short-name;
        my Bool $bool;

        if $value.defined {
            if $value !~~ Hash {
                try {
                    $bool = $value.Bool;
                    CATCH {
                        default {
                            X::Kinoko.new(msg => "$value: Option $name need boolean.").throw();
                        }
                    }
                }
            }
            else {
                $bool = $value;
            }
        }
        elsif $use-default {
            $bool = self!default-value;
        }
        else {
            X::Kinoko.new(msg => ": Option $name need a value.").throw();
        }
        $!value = $bool;
        self.callback()($!value) if $callcb && self.has-callback;
        self;
    }

    method !default-value {
        Bool
    }

    method has-value {
        $!value.defined;
    }

    method set-value($value) {
        self!initialize-value($value, :!use-default);
    }

    method set-value-callback($value) {
        self!initialize-value($value, :!use-default, :callcb);
    }

    method value {
        $!value;
    }

    method reset {
        $!value = self!default-value;
    }

    method major-type {
        "boolean";
    }

    method is-boolean() {
        True;
    }

    multi method deep-clone() {
        self.bless(:$!sn, :$!ln, :&!cb, :$!force, :$!cm)!initialize-value(DeepClone.deep-clone($!value));
    }
}

#=[
    return a class type according to $major-type
]
multi sub option-class-factory(Str $major-type) {
    X::Kinoko.new(msg => "type " ~ $major-type ~ " not recognize").throw();
}

multi sub option-class-factory('i') {
    Option::Integer
}

multi sub option-class-factory('a') {
    Option::Array
}

multi sub option-class-factory('s') {
    Option::String
}

multi sub option-class-factory('b') {
    Option::Boolean
}

multi sub option-class-factory('h') {
    Option::Hash
}



#=[
    [short-name] [|] [long-name] = major-type [!];
    you must specify at least one of [*-name]
    if you specify one name, you can moit [|], then [*-name] will determine by [*-name].length
    major-type=[
        s, string,
        i, integer,
        b, boolean,
        h, hash,
        a, array,
    ]
    [!] means a force option
    sample:
        "u|username=s!", same as "u|username=string!"
        "p|port=i", same as "p|port=integer"
        "port|p=i", same as above option, [*-name] determine by [*-name].length
        "password=s!", password will be determine as [long-name]
        "p=s!",p(password) will be determine as [short-name]
]
multi sub create-option(Str:D $option, :$value, :&cb, :$cm) is export {
    my Str $ln;
    my Str $sn;
    my Str $mt;
    my $r = False;

    my regex type { [s|i|h|a|b] };
    my regex name { <-[\|\=\s]>* };
    my regex force { [\!]? }

    my regex option {
    	[
    		<.ws> $<ln> = (<name>) <.ws> \| <.ws> $<rn> = (<name>) <.ws>
    		||
    		<.ws> $<name> = (<name>) <.ws>
    	]
    	\= <.ws>
    	$<mt> = (<type>) <.ws>
    	$<r> = (<force>) <.ws>
    	{
    		if $<name>.defined {
    			if ~$<name>.chars > 1 {
    				$ln = ~$<name>;
    			}
    			else {
    				$sn = ~$<name>;
    			}
    		}
    		elsif $<ln>.defined || $<rn>.defined {
                $sn = ~$<ln> if $<ln>.defined && ~$<ln>.chars > 0;
                $ln = ~$<rn> if $<rn>.defined && ~$<rn>.chars > 0;
            }
    		$mt = ~$<mt>;
    		$r  = True if $<r>.defined && ~$<r> eq '!';
    	}
    };

    my &process = -> $opt-str is copy {
        my %l2s := {
            string  => 's',
            integer => 'i',
            hash    => 'h',
            boolean => 'b',
            array   => 'a',
        };

        $opt-str ~~ s/\=(string|integer|hash|boolean|array)/\={%l2s{$0}}/;
        $opt-str;
    };

    my $opt-str = &process($option);

    if $opt-str ~~ /<option>/ {
        return option-class-factory($mt).new(:$ln, :$sn, :force($r), :$value, :&cb, :$cm);
    }

    X::Kinoko.new(msg => "$option: not a valid option string.").throw();
}

#=[
    *%option
    :$ln,
    :$sn,
    :$force,
    :$value,
    :$cb,
    :$mt,
]
multi sub create-option(*%option) is export {
    return option-class-factory(%option<mt>).new(|%option);
}

multi sub create-option(%option) is export {
    return option-class-factory(%option<mt>).new(|%option);
}
