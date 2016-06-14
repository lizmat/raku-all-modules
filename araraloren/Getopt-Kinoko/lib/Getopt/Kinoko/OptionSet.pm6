
use v6;

use Getopt::Kinoko::Group;
use Getopt::Kinoko::Option;
use Getopt::Kinoko::NonOption;
use Getopt::Kinoko::DeepClone;
use Getopt::Kinoko::Exception;

#| OptionSet can manager a variety of options
class OptionSet does DeepClone {
	has $!front; 	# front processer which process first non-option argument
	has @!radio;	# radio option groups
	has @!multi;	# multi option groups
	has $!normal;	# normal option groups
	has $!all;	# readall prcesser which process all option after last option
	has $!each;	# readall prcesser which process each option after last option

	#| for deep-clone
	submethod BUILD(
		:$!front,
		:@!radio,
		:@!multi,
		:$!normal,
		:$!all,
		:$!each
	)
	{}

	#| for traversal 
	method !allgroup() {
		($!normal, @!multi, @!radio).flat
	}

	method has-option(Str $name, :$long, :$short) {
		for self!allgroup -> $group {
			return True if $group.has-option($name, :$long, :$short);
		}
		False;
	}

	method has-value(Str $name, :$long, :$short) {
		for self!allgroup -> $group {
			return True if $group.has-value($name, :$long, :$short);
		}
		False;
	}

	method set-value(Str $name, $value, :$long, :$short) {
		for self!allgroup -> $group {
			return True if $group.set-value($name, $value, :$long, :$short);
		}
		False;
	}

	method set-value-callback(Str $name, $value, :$long, :$short) {
		for self!allgroup -> $group {
			return True if $group.set-value-callback($name, $value, :$long, :$short);
		}
		False;
	}

	method set-callback(Str $name, &callback, :$long, :$short) {
		for self!allgroup -> $group {
			return True if $group.set-callback($name, &callback, :$long, :$short);
		}
		False;
	}

	method AT-KEY(::?CLASS::D: Str \key) {
		for self!allgroup -> $group {
			my $opt = $group.get-option(key);
			return $opt.value if $opt.defined;
		}
	}

	method ASSIGN-KEY(::?CLASS::D: Str \key, $value) {
		for self!allgroup -> $group {
			last if $group.set-value(key, $value);
		}
	}

	method EXISTS-KEY(Str \key) {
		self.has-option(key);
	}

	method values() {
		my $values = [];
		for self!allgroup -> $group {
			$values.append: $group.options();
		}
		$values;
	}

	method keys() {
		my $names = [];
		for self!allgroup -> $group {
			for $group.options() -> $opt {
				$names.push: $opt.short-name if $opt.is-short;
				$names.push: $opt.long-name if $opt.is-long;
			}
		}
		$names;
	}

	method has-front() {
		$!front.defined;
	}

	method has-all() {
		$!all.defined;
	}

	method has-each() {
		$!each.defined;
	}

	method has-radio() {
		+@!radio > 0;
	}

	method has-multi() {
		+@!multi > 0;
	}

	method has-normal() {
		$!normal.defined;
	}

	method get-front() {
		$!front;
	}

	method get-all() {
		$!all;
	}

	method get-each() {
		$!each;
	}

	multi method get-multi() {
		@!multi;
	}

	multi method get-radio() {
		@!radio;
	}

	method get-normal() {
		$!normal;
	}

	method insert-front(&callback) {
		$!front = create-non-option(&callback, :front);
		self;
	}

	method insert-radio(Str $opts, :$force = False) {
		@!radio.push: create-group($opts, :$force, :radio);
		self;
	}

	method insert-multi(Str $opts) {
		@!multi.push: create-group($opts, :multi);
		self;
	}

	method insert-normal(Str $opts) {
		$!normal = create-group($opts, :normal);
		self;
	}

	method insert-all(&callback) {
		$!all = create-non-option(&callback, :all);
		self;
	}

	method insert-each(&callback) {
		$!each = create-non-option(&callback, :each);
		self;
	}

	method check-force-value() {
		for self!allgroup -> $group {
			$group.check();
		}
	}

	method generate-method(Str $prefix) {
		for @(self.values()) -> $opt {
            if $opt.is-long {
                self.^add_method($prefix ~ $opt.long-name, my method { $opt; });
                self.^compose();
            }
            if $opt.is-short {
                self.^add_method($prefix ~ $opt.short-name, my method { $opt; });
                self.^compose();
            }
        }
        self;
	}

	multi method push-option(Str $opt, :&callback, :$normal) {
		$!normal.push($opt, :&callback);
		self;
	}

	multi method push-option(Str $opt, $value, :&callback, :$normal) {
		$!normal.push($opt, $value, :&callback);
		self;
	}

	method !get-option-all(Str $name, :$long, :$short) {
		for self!allgroup -> $group {
			my $opt = $group.get-option($name, :$long, :$short);
			return $opt if $opt.defined;
		}
	}

	method get-option(Str $name, :$long, :$short, :$normal, :$radio, :$multi) {
		if $radio.defined {
			for @!radio -> $group {
				my $opt = $group.get-option($name, :$long, :$short);
				return $opt if $opt.defined;
			}
		}
		elsif $multi.defined {
			for @!multi -> $group {
				my $opt = $group.get-option($name, :$long, :$short);
				return $opt if $opt.defined;
			}
		}
		elsif $normal.defined {
			$!normal.get-option($name, :$long, :$short);
		}
		else {
			self!get-option-all($name, :$long, :$short);
		}
	}

	method append-options(Str $opts, :$normal) {
		$!normal.append($opts);
		self;
	}

	method usage() {
		my Str $usage;

        for @(self.values()) -> $opt {
            $usage ~= ' [';
            $usage ~= $opt.usage;
            $usage ~= '] ';
        }

        $usage;
	}

	method perl {
		unless self.defined {
			return "(OptionSet)";
		}
		my $perl;

		$perl ~= "OptionSet.new(";
		$perl ~= "front => " ~ $!front.perl ~ ", ";
		$perl ~= "radio => [";
		for @!radio -> $group {
			$perl ~= $group.perl ~ ", ";
		}
		$perl ~= '], multi => [';
		for @!multi -> $group {
			$perl ~= $group.perl ~ ", ";
		}
		$perl ~= '], normal => ' ~ $!normal.perl ~ ', ';
		$perl ~= "all => " ~ $!all.perl ~ ', ';
		$perl ~= "each => " ~ $!each.perl ~ ')';
		$perl;
	}

	multi method deep-clone() {
		self.bless( self.CREATE(),
            front 	=> DeepClone.deep-clone($!front),
			radio 	=> DeepClone.deep-clone(@!radio),
			multi 	=> DeepClone.deep-clone(@!multi),
			normal 	=> DeepClone.deep-clone($!normal),
			all 	=> DeepClone.deep-clone($!all),
			each 	=> DeepClone.deep-clone($!each)
        );
	}
}
