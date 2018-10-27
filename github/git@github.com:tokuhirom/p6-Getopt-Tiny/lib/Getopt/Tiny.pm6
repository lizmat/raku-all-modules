use v6;
unit class Getopt::Tiny;

use Pod::To::Text;

has $.pass-through;

my class X::Usage is Exception {
    has $.message;
    method new(Str $message) {
        self.bless(message => $message)
    }
}

my class IntOption {
    has $.short;
    has $.long;
    has $.callback;

    method usage() {
        if $.short.defined {
            return "-{$.short}=Int"
        }
        if $.long.defined {
            return "--{$.long}=Int"
        }
        return '';
    }

    method match($a) {
        if $.short.defined {
            return True if self!match-short($a);
        }
        if $.long.defined {
            return True if self!match-long($a);
        }
        return False;
    }

    method !match-long($a) {
        my $opt = $.long;

        my $val = do {
            if $a[0] eq "--$opt" {
                $a.shift;
                if $a.elems == 0 {
                    X::Usage.new("--$opt requires integer parameter").throw;
                }
                $a.shift;
            } elsif $a[0] ~~ /^\-\-$opt\=(.*)$/ { # -h=3
                my $val = $/[0].Str;
                $a.shift;
                $val;
            } else {
                return False;
            }
        };

        unless $val ~~ /^<[0..9]>+$/ {
            X::Usage.new("-$opt requires int parameter, but got $val").throw;
        }
        $.callback()($val.Int);
        True
    }

    method !match-short($a) {
        my $opt = $.short;

        my $val = do {
            if $a[0] eq "-$opt" {
                $a.shift;
                if $a.elems == 0 {
                    X::Usage.new("-$opt requires int parameter").throw;
                }
                $a.shift;
            } elsif $a[0] ~~ /^\-$opt(.*)$/ { # -h=3
                my $val = $/[0].Str;
                $a.shift;
                $val;
            } else {
                return False;
            }
        };

        unless $val ~~ /^<[0..9]>+$/ {
            X::Usage.new("-$opt requires int parameter, but got $val").throw;
        }
        $.callback()($val.Int);
        True
    }
}

my class StrOption {
    has $.short;
    has $.long;
    has $.callback;

    method usage() {
        if $.short.defined {
            return "-{$.short}=Str"
        }
        if $.long.defined {
            return "--{$.long}=Str"
        }
        return '';
    }

    method match($a) {
        if $.short.defined {
            return True if self!match-short($a);
        }
        if $.long.defined {
            return True if self!match-long($a);
        }
        return False;
    }

    method !match-long($a) {
        my $opt = $.long;

        my $val = do {
            if $a[0] eq "--$opt" {
                $a.shift;
                if $a.elems == 0 {
                    X::Usage.new("--$opt requires string parameter").throw;
                }
                $a.shift;
            } elsif $a[0] ~~ /^\-\-$opt\=(.*)$/ { # -h=3
                my $val = $/[0].Str;
                $a.shift;
                $val;
            } else {
                return False;
            }
        };

        $.callback()($val);
        True
    }

    method !match-short($a) {
        my $opt = $.short;

        my $val = do {
            if $a[0] eq "-$opt" {
                $a.shift;
                if $a.elems == 0 {
                    X::Usage.new("-$opt requires string parameter").throw;
                }
                $a.shift;
            } elsif $a[0] ~~ /^\-$opt(.*)$/ { # -h=3
                my $val = $/[0].Str;
                $a.shift;
                $val;
            } else {
                return False;
            }
        };

        $.callback()($val);
        True
    }
}

my class BoolOption {
    has $.short;
    has $.long;
    has $.callback;

    method usage() {
        if $.short.defined {
            return "-{$.short}"
        }
        if $.long.defined {
            return "--{$.long}"
        }
        return '';
    }

    method match($a) {
        if $.short.defined {
            return True if self!match-short($a);
        }
        if $.long.defined {
            return True if self!match-long($a);
        }
        return False;
    }

    method !match-long($a) {
        my $opt = $.long;

        if $a[0] eq "--$opt" {
            $a.shift;
            $.callback()(True);
            True;
        } elsif $a[0] eq "--no-$opt" {
            $a.shift;
            $.callback()(False);
            True;
        } else {
            return False;
        }
    }

    method !match-short($a) {
        my $opt = $.short;

        if $a[0] eq "-$opt" {
            $a.shift;
            $.callback()(True);
            True
        } else {
            return False;
        }
    }
}

has $!options = [];

multi method str(Str $opt, $callback) {
    my $type = $opt.chars == 1 ?? 'short' !! 'long';
    $!options.append: StrOption.new(
        |($type    => $opt),
        callback => $callback,
    );
    self;
}

multi method str($short, $long, $callback) {
    $!options.append: StrOption.new(
        short    => $short,
        long     => $long,
        callback => $callback,
    );
    self;
}

multi method bool(Str $opt, $callback) {
    my $type = $opt.chars == 1 ?? 'short' !! 'long';
    $!options.append: BoolOption.new(
        |($type    => $opt),
        callback => $callback,
    );
    self;
}

multi method bool($short, $long, $callback) {
    $!options.append: BoolOption.new(
        short    => $short,
        long     => $long,
        callback => $callback,
    );
    self;
}

multi method int(Str $opt, $callback) {
    my $type = $opt.chars == 1 ?? 'short' !! 'long';
    $!options.append: IntOption.new(
        |($type    => $opt),
        callback => $callback,
    );
    self;
}

multi method int($short, $long, $callback) {
    if $short.defined {
        $!options.append: IntOption.new(
            short    => $short,
            callback => $callback,
        );
    }
    if $long.defined {
        $!options.append: IntOption.new(
            long     => $long,
            callback => $callback,
        );
    }
    self;
}

my sub pod2usage($pod) {
    given $pod {
        when Pod::Block::Named {
            for 0..^$pod.contents.elems-1 -> $i {
                if $pod.contents[$i] ~~ Pod::Heading && pod2text($pod.contents[$i].contents) eq 'SYNOPSIS' {
                    return pod2text($pod.contents[$i+1]);
                }
            }
        }
        when Array {
            for @$_ {
                my $got = pod2usage($_);
                return $got if $got;
            }
        }
    }
}

method !print-usage(Str $msg='') {
    say "$msg\n" if $msg;

    my $pod = callframe(callframe().level).my<$=pod>;
    my $usage = pod2usage($pod);
    if $usage {
        say "\nUsage:\n$usage\n";
        exit 1;
    }

    my $prog-name = $*PROGRAM-NAME eq '-e'
        ?? '-e "..."'
        !! $*PROGRAM-NAME;

    # I want to show more verbose usage message. patches welcome.
    say("Usage: $prog-name " ~ @$!options.map({ .usage }).join(" "));

    exit 1
}

method parse($args is copy) {
    my @positional;

    LOOP: while +@$args {
        if $args[0] eq '--' {
            $args.shift;
            @positional.append: @$args;
            last;
        }

        for @$!options -> $opt {
            if $opt.match($args) {
                next LOOP
            }
        }
        CATCH {
            when X::Usage {
                self!print-usage($_.message);
            }
        }

        if $args[0] eq '-h' || $args[0] eq '--help' {
            self!print-usage();
        }

        if $args[0] ~~ /^\-/ && !$.pass-through {
            self!print-usage("Unknown option '$args[0]'");
        }

        @positional.push: $args.shift;
    }

    return @positional;
}


my grammar GetoptionsGrammar {
    token TOP { <key> '=' <type> }
    token key { <short> [ '|' <long> ]?  | <long> }

    token short { <[a..z A..Z]> }
    token long { <[a..z A..Z]> <[a..z A..Z 0..9]>+ }

    token type {
        's'  | # str
        's@' | # array of string
        '!'  | # bool
        'i'    # int
    }
};

my class GetoptionsAction {
    method type($/)  { $/.make: ~$/ }
    method short($/) { $/.make: ~$/ }
    method long($/)  { $/.make: ~$/ }
    method key($/)   { $/.make: ($<short>.made, $<long>.made) }
    method TOP($/)   { $/.make: (|$<key>.made, $<type>.made) }
}

sub get-options($opts is rw, $defs, $args=[@*ARGS], Bool :$pass-through=False) is export {
    my $getopt = Getopt::Tiny.new(
        pass-through => $pass-through,
    );
    for @$defs -> $def {
        my ($short, $long, $type) = @(GetoptionsGrammar.parse($def, :actions(GetoptionsAction)).made);
        given $type {
            when 's' { # str
                $getopt.str($short, $long, -> $v { $opts{$long // $short} = $v });
            }
            when 's@' { # string array
                $getopt.str($short, $long, -> $v {
                    $opts{$long // $short} //= [];
                    $opts{$long // $short}.append: $v;
                });
            }
            when 'i' { # int
                $getopt.int($short, $long, -> $v { $opts{$long // $short} = $v });
            }
            when '!' { # bool
                $getopt.bool($short, $long, -> $v { $opts{$long // $short} = $v });
            }
            default { die "unknown type: $type" }
        }
    }

    @*ARGS = $getopt.parse($args);
    $PROCESS::ARGFILES = IO::ArgFiles.new(:args(@*ARGS));

    Nil;
}

=begin pod

=head1 NAME

Getopt::Tiny - Tiny option parser for Perl6

=head1 SYNOPSIS

    use v6;

    use Getopt::Tiny;

    my $opts = { host => '127.0.0.1', port => 5000 };

    get-options($opts, <
        e=s
        I=s@
        p=i
        h|host=s
    >);

=head1 DESCRIPTION

Getopt::Tiny is tiny command line option parser library for Perl6.

=head1 FEATURES

=item Fluent interface

=item Built-in pod2usage feature

=head1 MOTIVATION

Perl6 has a great built-in command line option parser. But it's not flexible.
It's not perfect for all cases.

=head1 Function interface

=head2 C<get-options(Hash $opts, Array[Str] $definitions, Bool :$pass-through=False)>

Here is a synopsis code:

    get-options($args, <
        e=s
        I=s@
        p=i
        h|host=s
    >);

C<$definitions>' grammar is here:

    token TOP { <key> '=' <type> }
    token key { <short> [ '|' <long> ]?  | <long> }

    token short { <[a..z A..Z]> }
    token long { <[a..z A..Z]> <[a..z A..Z 0..9]>+ }

    token type {
        's'  | # str
        's@' | # array of string
        '!'  | # bool
        'i'    # int
    }

Parse options from C<@*ARGS>.

C<$opts> should be Hash. This function writes result to C<$opts>.

C<$definitions> should be one of following style.

If you want to pass-through unknown option, you can pass C<:pass-through> as a named argument like following:

    get-options($x, $y, :pass-through);

This function modifies C<@*ARGS> and C<$PROCESS::ARGFILES>.

=head1 OO Interface

=head2 METHODS

=head3 C<my $opt = Getopt::Tiny.new()>

Create new instance of the parser.

=head3 C<$opt.str($opt, $callback)>

If C<$opt> has 1 char, it's equivalent to C<$opt.str($opt, Nil, $callback)>,
C<$opt.str(Nil, $opt, $callback)> otherwise.

=head3 C<$opt.str($short, $long, $callback)>

Add string option.

C<$short> accepts C<-Ilib> or C<-I lib> form.
C<$long> accepts C<--host=lib> or C<--host lib> form.

Argument of C<$callback> is C<Str>.

=head3 C<$opt.int($opt, $callback)>

If C<$opt> has 1 char, it's equivalent to C<$opt.int($opt, Nil, $callback)>,
C<$opt.int(Nil, $opt, $callback)> otherwise.

=head3 C<$opt.int($short, $long, $callback)>

Add integer option.

C<$short> accepts C<-I3> or C<-I 3> form.
C<$long> accepts C<--port=5963> or C<--port 5963> form.

Argument of C<$callback> is C<Int>.

=head3 C<$opt.bool($opt, $callback)>

If C<$opt> has 1 char, it's equivalent to C<$opt.bool($opt, Nil, $callback)>,
C<$opt.bool(Nil, $opt, $callback)> otherwise.

=head3 C<$opt.bool($short, $long, $callback)>

Add boolean option.

C<$short> accepts C<-x> form.
C<$long> accepts C<--man-pages> or C<--no-man-pages> form.

Argument of C<$callback> is C<Bool>.

=head3 C<$opt.parse(@args)>

Run the option parser. Return values are positional arguments.

This operation does *not* modify C<@*ARGS> and C<$PROCESS::ARGFILES>.

=head1 pod2usage

This library shows POD's SYNOPSIS section in your script as help message, when it's available.

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Tokuhiro Matsuno <tokuhirom@gmail.com>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
