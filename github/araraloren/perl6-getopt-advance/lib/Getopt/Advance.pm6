
use Getopt::Advance::Helper;
use Getopt::Advance::Types;
use Getopt::Advance::Parser;
use Getopt::Advance::Group;
use Getopt::Advance::Option;
use Getopt::Advance::Argument;
use Getopt::Advance::Exception;
use Getopt::Advance::NonOption;

class OptionSet { ... }

proto sub getopt(|) { * }

#`(
    :$gnu-style, :$unix-style, :$x-style, :$bsd-style,
)
multi sub getopt (
    *@optsets where all(@optsets) ~~ OptionSet,
    *%args) is export {
    samewith(
        @*ARGS ?? @*ARGS.clone !! $[],
        |@optsets,
        |%args
    );
}

multi sub getopt(
    Str $optstring,
    *%args ) is export {
    samewith(
        @*ARGS ?? @*ARGS.clone !! $[],
        OptionSet.new-from-optstring($optstring),
        |%args
    );
}

multi sub getopt(
    @args,
    Str $optstring,
    *%args ) is export {
    samewith(
        @args,
        OptionSet.new-from-optstring($optstring),
        |%args
    );
}

multi sub getopt (
    @args,
    *@optsets where all(@optsets) ~~ OptionSet,
    :&helper = &ga-helper,
    :$stdout = $*OUT,
    :$stderr = $*ERR,
    :&parser = &ga-parser,
    :$strict = True,
    :$autohv = False,
    :$version,
    :$bsd-style,
    :$x-style, #`(giving priority to x-style) ) of Getopt::Advance::ReturnValue is export {
    our $*ga-bsd-style = $bsd-style;
    my ($index, $count, @noa, $optset) = (0, +@optsets, []);
    my $ret;
    my &auto-helper = -> |c {
        with &helper {
            &helper(|c, $stdout);
        }
    };

    while $index < $count {
        $optset := @optsets[$index];
        try {
            $ret = &parser(
                @args,
                $optset,
                :$strict,
                :$bsd-style,
                :$x-style,
                :$autohv,
            );
            last;
            CATCH {
                when X::GA::ParseFailed {
                    $index++;
                    if $index == $count {
                        if +@optsets > 1 {
                            &auto-helper(@optsets);
                        } else {
                            &auto-helper(@optsets[0]);
                        }
                        $stderr.say(.message);
                        .throw;
                    }
                }

                when X::GA::WantPrintHelper {
                    &auto-helper($optset);
                    exit (0);
                }

				when X::GA::WantPrintAllHelper {
                    &auto-helper(@optsets);
                    exit (0);
                }

                default {
                    &auto-helper($optset);
                    $stderr.say(.message);
                    .throw;
                }
            }
        }
    }

	if $index == $count {
        if +@optsets > 1 {
            &auto-helper(@optsets);
        } else {
            &auto-helper(@optsets[0]);
        }
        exit (0);
	}

    if $autohv {
        &ga-versioner($version, $stdout);
        &auto-helper($optset);
    }

    return $ret;
}

class OptionSet {
    has @.main;
    has %!cache;
    has @.radio;
    has @.multi;
    has %.no-all;
    has %.no-pos;
    has %.no-cmd;
    has $!types;
    has $!counter;

    method new-from-optstring(Str $optstring is copy) {
        $optstring ~~ s:g/(\w)<!before \:>/$0=b;/;
        $optstring ~~ s:g/(\w)\:/$0=s;/;

        OptionSet.new().append($optstring);
    }

    submethod TWEAK() {
        $!types = Types::Manager.new;
        $!types.register('b', Option::Boolean)
              .register('i', Option::Integer)
              .register('s', Option::String)
              .register('a', Option::Array)
              .register('h', Option::Hash)
              .register('f', Option::Float);
    }

    method keys(::?CLASS::D:) {
        my @keys = [];
        for @!main {
            @keys.push(.long) if .has-long;
            @keys.push(.short)if .has-short;
        }
        @keys;
    }

    method values(::?CLASS::D:) {
        @!main;
    }

    method get(::?CLASS::D: Str:D $name) of Option {
        if %!cache{$name}:exists {
            return %!cache{$name};
        } else {
            for @!main {
                if .match-name($name) {
                    %!cache{.long}  := $_ if .has-long;
                    %!cache{.short} := $_ if .has-short;
                    return $_;
                }
            }
        }
        return Option;
    }

    multi method has(::?CLASS::D: Str:D @names ) of Bool {
        [&&] [self.has($_) for @names];
    }

    multi method has(::?CLASS::D: Str:D $name) of Bool {
        if %!cache{$name}:exists {
            return True;
        } else {
            for @!main {
                if .match-name($name) {
                    %!cache{.long}  := $_ if .has-long;
                    %!cache{.short} := $_ if .has-short;
                    return True;
                }
            }
        }
        return False;
    }

    multi method remove(::?CLASS::D: Str:D @names) of Bool {
        [&&] [self.remove($_) for @names];
    }

    multi method remove(::?CLASS::D: Str:D $name) of Bool {
        my $find = -1;
        if %!cache{$name}:exists {
            for ^+@!main -> $index {
                if @!main[$index] === %!cache{$name} {
                    $find = $index;
                    last;
                }
            }
            %!cache{$name}:delete;
        } else {
            for ^+@!main -> $index {
                if @!main[$index].match-name($name) {
                    $find = $index;
                    last;
                }
            }
        }
        if $find == -1 {
            return False;
        } else {
            my $option := @!main[$find];
            if $option.long eq $name {
                $option.reset-long;
            } elsif $option.short eq $name {
                $option.reset-short;
            }
            unless $option.has-long || $option.has-short {
                @!main.splice($find, 1);
            }
            for (@!radio, @!multi) -> @groups {
                for @groups -> $group {
                    if $group.has($name) {
                        $group.remove($name);
                    }
                }
            }
            return True;
        }
    }

    multi method reset(::?CLASS::D: Str:D @names) of ::?CLASS {
        self.reset($_) for @names;
        self;
    }

    multi method reset(::?CLASS::D: Str:D $name) of ::?CLASS {
        if %!cache{$name}:exists {
            %!cache{$name}.reset-value;
        } else {
            for ^+@!main -> $index {
                if @!main[$index].match-name($name) {
                    @!main[$index].reset-value;
                    last;
                }
            }
        }
        self;
    }

    multi method EXISTS-KEY(::?CLASS::D: Str:D \key where * !~~ /^\s+$/) of Bool {
        return self.has(key);
    }

    multi method EXISTS-KEY(::?CLASS::D: Str:D @key) of Bool {
        return [&&] [ self.has($_) for @key ];
    }

    # NOTICE: this return the value of option
    multi method AT-KEY(::?CLASS::D: Str:D \key where * !~~ /^\s+$/) {
        self.get(key) andthen return .value;
    }

    multi method AT-KEY(::?CLASS::D: Str:D @key) {
        return [for @key { self.has($_) ?? self.get($_).value !! Option }];
    }

    method set-value(::?CLASS::D: Str:D $name, $value, :$callback = True) of ::?CLASS {
        with self.get($name) -> $opt {
            $opt.set-value($value, :$callback);
        }
        self;
    }

    method set-annotation(::?CLASS::D: Str:D $name, Str:D $annotation) of ::?CLASS {
        with self.get($name) -> $opt {
            $opt.set-annotation($annotation);
        }
        self;
    }

    method set-callback(::?CLASS::D: Str:D $name, &callback) of ::?CLASS {
        with self.get($name) -> $opt {
            $opt.set-callback(&callback);
        }
        self;
    }

    multi method push(::?CLASS::D: Str:D $opt, :$value, :&callback) of ::?CLASS {
        @!main.push(
            $!types.create( $opt, :$value, :&callback)
        );
        self;
    }

    multi method push(::?CLASS::D: Str:D $opt, Str:D $annotation, :$value, :&callback) of ::?CLASS {
        @!main.push(
            $!types.create($opt, $annotation, :$value, :&callback)
        );
        self;
    }

    multi method append(::?CLASS::D: Str:D $opts) of ::?CLASS {
        for $opts.split(';', :skip-empty) {
            @!main.push($!types.create($_));
        }
        self;
    }

    multi method append(::?CLASS::D: *@optpairs where all(@optpairs) ~~ Pair, :$radio where :!so, :$multi where :!so) of ::?CLASS {
        for @optpairs {
            @!main.push($!types.create(.key, .value));
        }
        self;
    }

    multi method append(::?CLASS::D: Str:D $opts, :$optional = True, :$radio!) of ::?CLASS {
        my @opts = [$!types.create($_) for $opts.split(';', :skip-empty)];
        ga-raise-error("Can not create radio group for only one option") if +@opts <= 1;
        @!radio.push(
            Group::Radio.new(options => @opts, :$optional, :optsetref(self))
        );
        @!main.append(@opts);
        self;
    }

    multi method append(::?CLASS::D: Str:D $opts, :$optional = True, :$multi!) of ::?CLASS {
        my @opts = [$!types.create($_) for $opts.split(';', :skip-empty)];
        ga-raise-error("Can not create multi group for only one option") if +@opts <= 1;
        @!multi.push(
            Group::Multi.new(options => @opts, :$optional, :optsetref(self))
        );
        @!main.append(@opts);
        self;
    }

    multi method append(::?CLASS::D: :$optional = True, :$radio!, *@optpairs where all(@optpairs) ~~ Pair) of ::?CLASS {
        my @opts = [ $!types.create(.key, .value) for @optpairs];
        ga-raise-error("Can not create radio group for only one option") if +@opts <= 1;
        @!radio.push(
            Group::Radio.new(options => @opts, :$optional, :optsetref(self))
        );
        @!main.append(@opts);
        self;
    }

    multi method append(::?CLASS::D: :$optional = True, :$multi!, *@optpairs where all(@optpairs) ~~ Pair) of ::?CLASS {
        my @opts = [ $!types.create(.key, .value) for @optpairs];
        ga-raise-error("Can not create multi group for only one option") if +@opts <= 1;
        @!multi.push(
            Group::Multi.new(options => @opts, :$optional, :optsetref(self))
        );
        @!main.append(@opts);
        self;
    }

    # non-option operator
    multi method has(::?CLASS::D: Int:D $id ) of Bool {
        my @r = [];
        @r.push((sub (\noref) {
            for @(noref).keys {
                if $id == $_ {
                    return True;
                }
            }
            return False;
        }($_))) for (%!no-all, %!no-pos, %!no-cmd);
        return [||] @r;
    }

    multi method remove(Int:D $id) {
        -> \noref {
            for @(noref).keys {
                if $id == $_ {
                    noref{$id}:delete;
                    last;
                }
            }
        }($_) for (%!no-all, %!no-pos, %!no-cmd);
    }

    multi method EXISTS-KEY(::?CLASS::D: Int:D $id) of Bool {
        self.has($id);
    }

    method get-main(::?CLASS::D:) {
        return %!no-all;
    }

    multi method get-cmd(::?CLASS::D:) {
        %!no-cmd;
    }

    multi method get-cmd(::?CLASS::D: Int $id) {
        %!no-cmd{$id};
    }

    multi method get-cmd(::?CLASS::D: Str $name) {
        for %!no-cmd.values {
            return $_ if .name eq $name;
        }
    }

    multi method get-pos(::?CLASS::D:) {
        %!no-pos;
    }

    multi method get-pos(::?CLASS::D: Int $id) {
        %!no-pos{$id};
    }

    multi method get-pos(::?CLASS::D: Str $name, $index) {
        for %!no-pos.values {
            if .name eq $name && .match-index(4096, $index) {
                return $_;
            }
        }
    }

    multi method reset-cmd(::?CLASS::D: Int $id) {
        %!no-cmd{$id}.reset-success;
    }

    multi method reset-cmd(::?CLASS::D: Str $name) {
        for %!no-cmd.values {
            .reset-success if .name eq $name;
        }
    }

    multi method reset-pos(::?CLASS::D: Int $id) {
        %!no-pos{$id}.reset-success;
    }

    multi method reset-pos(::?CLASS::D: Str $name, $index) {
        for %!no-pos.values {
            if .name eq $name && .match-index(4096, $index) {
                .reset-success;
            }
        }
    }

    multi method insert-main(::?CLASS::D: &callback) of Int {
        my $id = $!counter++;
        %!no-all.push(
            $id => NonOption::All.new( :&callback)
        );
        return $id;
    }

    multi method insert-cmd(::?CLASS::D: Str:D $name) of Int {
        my $id = $!counter++;
        %!no-cmd.push(
            $id => NonOption::Cmd.new( callback => -> Argument $a {}, :$name)
        );
        return $id;
    }

    multi method insert-cmd(::?CLASS::D: Str:D $name, &callback) of Int {
        my $id = $!counter++;
        %!no-cmd.push(
            $id => NonOption::Cmd.new( :&callback, :$name)
        );
        return $id;
    }

    multi method insert-pos(::?CLASS::D: Str:D $name, &callback, :$front!) of Int {
        my $id = $!counter++;
        %!no-pos.push(
            $id => NonOption::Pos.new-front( :&callback, :$name)
        );
        return $id;
    }

    multi method insert-pos(::?CLASS::D: Str:D $name, &callback, :$last!) of Int {
        my $id = $!counter++;
        %!no-pos.push(
            $id => NonOption::Pos.new-last( :&callback, :$name)
        );
        return $id;
    }

    multi method insert-pos(::?CLASS::D: Str:D $name, $index where Int:D | WhateverCode , &callback) of Int {
        my $id = $!counter++;
        %!no-pos.push(
            $id => NonOption::Pos.new( :$name, :$index, :&callback)
        );
        return $id;
    }

    method check(::?CLASS::D:) {
        for (@!radio, @!multi) -> @groups {
            for @groups -> $group {
                $group.check();
            }
        }
        .check unless .optional for @!main;
    }

    method annotation(::?CLASS::D:) {
		return [] if @!main.elems == 0;
		if (require Terminal::Table <&array-to-table>) || 1 {
			my @annotation;

			for @!main -> $opt {
				@annotation.push([
					$opt.usage,
					$opt.annotation ~ (do {
						if $opt.default-value.defined {
							"[{$opt.default-value}]";
						} else {
							"";
						}
					})
				]);
			}
			&array-to-table(@annotation, style => 'none');
		}
    }

    method clone(*%_) {
        nextwith(
            main => %_<main> // @!main.clone,
            radio => %_<radio> // @!radio.clone,
            multi => %_<multi> // @!multi.clone,
            no-all => %_<no-all> // %!no-all.clone,
            no-pos => %_<no-pos> // %!no-pos.clone,
            no-cmd => %_<no-cmd> // %!no-cmd.clone,
            |%_,
        );
    }
}
