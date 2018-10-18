
use Getopt::Advance::Utils;
use Getopt::Advance::Exception;

unit module Getopt::Advance::Types;

constant WhateverType is export = '*';

my grammar Grammar::Option {
	rule TOP {
		^ <option> $
	}

#`(
	a|action=b [!/]?;
	a=b;
	action=b;
	a|=b;
	|action=b;
	action|=b;
	|a=b;
)
	rule option {
		[
			<name> '=' <type>
			|
			<short>? '|' <long>? '=' <type>
		] [ <optional> | <deactivate> ]? [ <optional> | <deactivate> ]?
	}

	token short {
		<name>
	}

	token long {
		<name>
	}

	token name {
		<-[\|\=]>+
	}

	token type {
		\w+
	}

	token optional {
		'!'
	}

	token deactivate {
		'/'
	}
}

my class Actions::Option {
	has $.opt-deactivate;
	has $.opt-optional = True;
	has $.opt-type;
	has $.opt-long;
	has $.opt-short;

	method option($/) {
		unless $<long>.defined || $<short>.defined {
			my $name = $<name>.Str;

			if $name.chars > 1 {
				$!opt-long = $name;
			} else {
				$!opt-short = $name
			}
		}
	}

	method short($/) {
		$!opt-short = $/.Str;
	}

	method long($/) {
		$!opt-long = $/.Str;
	}

	method type($/) {
		$!opt-type = $/.Str;
	}

	method optional($/) {
		$!opt-optional = False;
	}

	method deactivate($/) {
		$!opt-deactivate = True;
	}
}

class TypesManager does RefOptionSet is export {
    has %.types handles <AT-KEY keys values>;

    method has(Str $name --> Bool) {
        %!types{$name}:exists;
    }

    method innername(Str:D $name) {
        %!types{$name}.type;
    }

    method type(Str $name) {
        %!types{$name};
    }

    method registe(Str:D $name, Mu:U $type --> ::?CLASS:D) {
        unless $type.^lookup("type") {
            &ga-raise-error("Implement a type method as the identification of type {$type.^name}");
        }
        if not self.has($name) {
            %!types{$name} = $type;
        }
        self;
    }

	multi method unregiste(Str:D $name --> ::?CLASS:D) {
		if self.has($name) {
			%!types{$name}:delete;
		}
	}

	multi method unregiste(--> ::?CLASS:D) {
		%!types = %{};
	}

    sub parseOptString(Str $str) {
        my $action = Actions::Option.new;
        unless Grammar::Option.parse($str, :actions($action)) {
            &ga-raise-error("Unable to parse option string: {$str}!");
        }
		if $action.opt-deactivate && $action.opt-type ne "b" {
			&ga-raise-error("Deactivate style only support boolean option: {$str}!");
		}
        return $action;
    }

    method create(Str $str, *%args) {
        my $setting = &parseOptString($str);
        my $option;
        my %realargs;

        unless self.has($setting.opt-type) {
           &ga-raise-error("Invalid option type: {$setting.opt-type}");
        }

        if %args<owner>:exists {
            Debug::warn("Choose another name, owner is a reversed named argument of TypesManager");
        }

        if not $str.contains("|") {
            %realargs<name> = %args<name> // $setting.opt-short // $setting.opt-long // "";
        }
        %realargs<owner>        = $!owner;
        %realargs<short>        = %args<short> // $setting.opt-short // "";
        %realargs<long>         = %args<long>  // $setting.opt-long  // "";
        %realargs<optional>     = %args<optional> // $setting.opt-optional;
        %realargs<deactivate>   = %args<deactivate> // $setting.opt-deactivate;
        %args< short long optional deactivate >:delete;
        Debug::debug("Construct <{$str}> with `{%realargs.map({ "{.key}={.value // ""}" })}`");
        $option = self.type($setting.opt-type).new(
            |%realargs,
            |%args,
        );
		$option.init();
        return $option;
    }

	method clone() {
		nextwith(
			types => %_<types> // %!types.clone,
			|%_
		);
	}
}
