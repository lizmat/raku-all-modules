
use Getopt::Advance::Option;
use Getopt::Advance::Exception;

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

class Types::Manager {
    has %.types handles <AT-KEY keys values kv pairs>;

    method has(Str $name --> Bool) {
        %!types{$name}:exists;
    }

    method innername(Str:D $name) {
        %!types{$name}.type;
    }

    method register(Str:D $name, Mu:U $type --> ::?CLASS:D) {
        if not self.has($name) {
            %!types{$name} = $type;
        }
        self;
    }

    sub opt-string-parse(Str $str) {
        my $action = Actions::Option.new;
        unless Grammar::Option.parse($str, :actions($action)) {
            ga-raise-error("{$str}: Unable to parse option string!");
        }
		if $action.opt-deactivate && $action.opt-type ne "b" {
			ga-raise-error("{$str}: Deactivate style only support boolean option!");
		}
        return $action;
    }

    #`( Option::Base
        has @.name;
        has &.callback;
        has $.optional;
        has $.annotation;
        has $.value;
        has $.default-value;
    )
    multi method create(Str $str, :$value, :&callback) {
        my $setting = &opt-string-parse($str);
        my $option;

        unless %!types{$setting.opt-type} ~~ Option {
            ga-raise-error("{$setting.opt-type}: Invalid option type!");
        }
        $option = %!types{$setting.opt-type}.new(
			short 		=> $setting.opt-short // "",
            long        => $setting.opt-long // "",
            callback    => &callback,
            optional    => $setting.opt-optional,
            value       => $value,
            deactivate  => $setting.opt-deactivate,
        );
        $option;
    }

    multi method create(Str $str,  Str:D $annotation, :$value, :&callback) {
        my $setting = &opt-string-parse($str);
        my $option;

        unless %!types{$setting.opt-type} ~~ Option {
            ga-raise-error("{$setting.opt-type}: Invalid option type!");
        }
        $option = %!types{$setting.opt-type}.new(
			short 		=> $setting.opt-short // "",
			long        => $setting.opt-long // "",
            callback    => &callback,
            optional    => $setting.opt-optional,
            value       => $value,
            annotation  => $annotation,
            deactivate  => $setting.opt-deactivate,
        );
        $option;
    }

	method clone(*%_) {
		nextwith(
			types => %_<types> // %!types.clone,
			|%_,
		);
	}
}
