use v6;
use Router::Boost::Node;
use MONKEY-SEE-NO-EVAL; # suppress "Prohibited regex interpolation"

unit class Router::Boost;

has Router::Boost::Node $!root = Router::Boost::Node.new(:key("'/'"));
has Regex $!regexp;
has @!leaves;

# Matcher stuff
my $LEAF-IDX = 0;
my @CAPTURED = [];

# Compiler stuff
has Int $!_PAREN-CNT = 0;
has @!_LEAVES = [];
has @!_PARENS = [];

method !is-captured-group(Str $pattern) returns Bool {
    # True if : ()
    # False if : []
    return $pattern.match(/'('/).defined;
}

my grammar PathGrammar {
    token named-regex-capture { \{ ( [ \{<[0..9 ,]>+\} || <-[{ }]>+ ]+ ) \} } # /blog/{year:\d{4}}
    token named-capture       { ':' ( <[A..Z a..z  0..9 _]>+ ) }              # /blog/:year
    token wildcard            { \* }                                       # /blog/*/*
    token normal-string       { <-[{ : *]>+ }
    token term                { [ <named-regex-capture> || <named-capture> || <wildcard> || <normal-string> ] }

    token TOP {
        ^ <term>* $
    }
}

my class PathActions {
    method named-regex-capture($/) {
        $/.make: $/.list.first(*).Str;
    }
    method named-capture($/) {
        $/.make: $/.list.first(*).Str;
    }
    method wildcard($/) {
        $/.make: ~$/;
    }
    method normal-string($/) {
        $/.make: ~$/;
    }
    method term($/) {
        $/.make: $/;
    }
    method TOP($/) {
        $/.make: $<term>;
    }
}

method add(Router::Boost:D: Str $path, $stuff) {
    my $p = $path;
    $p ~~ s!^'/'!!;

    $!regexp = Nil; # clear cache

    my $node = $!root;
    my @capture;
    my $matched = PathGrammar.parse($p, :actions(PathActions));
    for $matched.made -> $m {
        my $captured = $m.values.first(*).made.values.first(*);
        given $m.hash.keys[0] {
            when 'named-regex-capture' {
                my ($name, $pattern) = $captured.split(':', 2);
                if $pattern.defined && self!is-captured-group($pattern) {
                    die q{You can't include parens in your custom rule.};
                }
                @capture.push($name);
                $pattern = $pattern ?? "($pattern)" !! "(<-[/]>+)";
                $node = $node.add-node($pattern);
            }
            when 'named-capture' {
                @capture.push($captured);
                $node = $node.add-node("(<-[/]>+)");
            }
            when 'wildcard' {
                @capture.push('*');
                $node = $node.add-node("(.+)");
            }
            when 'normal-string' {
                $node = $node.add-node("'$captured'");
            }
            default {
                die 'Unknown type has come';
            }
        }
    }

    $node.leaf = [[@capture], $stuff];
}

method match(Router::Boost:D: Str $path is copy) {
    $path = '/' if $path eq '';

    my $regexp = self!regexp;
    if $path.match($regexp).defined {
        my ($captured, $stuff) = @!leaves[$LEAF-IDX];
        my %captured;
        my $i = 0;
        for @CAPTURED.map({ .Str }) -> $cap {
            %captured{@$captured[$i]} = $cap;
            $i++;
        }

        return {
            stuff    => $stuff,
            captured => %captured
        };
    }

    return {};
}

method !regexp(Router::Boost:D:) {
    unless $!regexp.defined {
        self!build-regexp;
    }
    return $!regexp;
}

method !build-regexp(Router::Boost:D:) {
    temp @!_LEAVES = [];
    temp @!_PARENS = [];
    temp $!_PAREN-CNT = 0;

    my $re = self!to-regexp($!root);

    @!leaves = @!_LEAVES;
    $!regexp = rx{^<$re>};
}

method !to-regexp(Router::Boost:D: Router::Boost::Node $node) {
    temp @!_PARENS = @!_PARENS;

    my $key = $node.key;
    if $key.match(/'('/).defined {
        @!_PARENS.push($!_PAREN-CNT);
        $!_PAREN-CNT++;
    }

    my @re;
    if $node.children.elems > 0 {
        @re.push(| $node.children.map(-> $child { self!to-regexp($child) }));
    }

    if $node.leaf.isa(List) {
        @!_LEAVES.push($node.leaf);
        @re.push(sprintf(
            '${ $LEAF-IDX=%s; @CAPTURED = (%s) }',
            @!_LEAVES.elems - 1,
            @!_PARENS.map(-> $paren { "\$$paren" }).join(',')
        ));
        $!_PAREN-CNT = 0;
    }

    my $regexp = $node.key;
    if @re.elems == 1 {
        $regexp ~= @re[0];
    } elsif @re.elems == 0 {
        # nop
    } else {
        $regexp ~= '[' ~ @re.join('|') ~ ']';
    }

    return $regexp;
}

=begin pod

=head1 NAME

Router::Boost - Routing engine for perl6

=head1 SYNOPSIS

  use Router::Boost;

  my $router = Router::Boost.new();
  $router.add('/',                             'dispatch_root');
  $router.add('/entrylist',                    'dispatch_entrylist');
  $router.add('/:user',                        'dispatch_user');
  $router.add('/:user/{year}',                 'dispatch_year');
  $router.add('/:user/{year}/{month:\d ** 2}', 'dispatch_month');
  $router.add('/download/*',                   'dispatch_download');

  my $dest = $router.match('/john/2015/10');
  # => {:captured(${:month("10"), :user("john"), :year("2015")}), :stuff("dispatch_month")}

  my $dest = $router.match('/access/to/not/existed/path');
  # => {}

=head1 DESCRIPTION

Router::Boost is a routing engine for perl6.
This router pre-compiles a regex for each routes thus fast.

This library is a perl6 port of L<Router::Boom of perl5|https://metacpan.org/pod/Router::Boom>.

=head1 METHODS

=head2 C<add(Router::Boost:D: Str $path, Any $stuff)>

Add a new route.

C<$path> is the path string.

C<$stuff> is the destination path data. Any data is OK.

=head2 C<match(Router::Boost:D: Str $path)>

Match the route. If matching is succeeded, this method returns hash like so;

  {
      stuff    => 'stuff', # matched stuff
      captured => {},      # captured values
  }

And if matching is failed, this method returns empty hash;

=head1 HOW TO WRITE A ROUTING RULE

=head2 plain string

    $router.add('/foo', { controller => 'Root', action => 'foo' });
    ...
    $router.match('/foo');
    # => {:captured(${}), :stuff(${:action("foo"), :controller("Root")})}

=head2 :name notation

    $router.add('/wiki/:page', { controller => 'WikiPage', action => 'show' });
    ...
    $router.match('/wiki/john');
    # => {:captured(${:page("john")}), :stuff(${:action("show"), :controller("WikiPage")})}

':name' notation matches C<rx{(<-[/]>+)}>. You will get captured arguments by C<name> key.

=head2 '*' notation

    $router.add('/download/*', { controller => 'Download', action => 'file' });
    ...
    $router.match('/download/path/to/file.xml');
    # => {:captured(${"*" => "path/to/file.xml"}), :stuff(${:action("file"), :controller("Download")})}

'*' notation matches C<rx{(<-[/]>+)}>. You will get the captured argument as the special key: C<*>.

=head2 '{...}' notation

    $router.add('/blog/{year}', { controller => 'Blog', action => 'yearly' });
    ...
    $router.match('/blog/2010');
    # => {:captured(${:year("2010")}), :stuff(${:action("yearly"), :controller("Blog")})}

'{...}' notation matches C<rx{(<-[/]>+)}>, and it will be captured.

=head2 '{...:<[0..9]>+}' notation

    $router.add('/blog/{year:<[0..9]>+}/{month:<[0..9]> ** 2}', { controller => 'Blog', action => 'monthly' });
    ...
    $router.match('/blog/2010/04');
    # => {:captured(${:month("04"), :year("2010")}), :stuff(${:action("monthly"), :controller("Blog")})}

You can specify perl6 regular expressions in named captures.

Note. You can't include normal capture in custom regular expression. i.e. You can't use C< {year:(\d+)} >.
But you can use C<< {year:[\d+]} >>.

=head1 SEE ALSO

L<Router::Boom of perl5|https://metacpan.org/pod/Router::Boom>

=head1 COPYRIGHT AND LICENSE

    Copyright 2015 moznion <moznion@gmail.com>

    This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

And original perl5's Router::Boom is

    Copyright (C) tokuhirom.

    This library is free software; you can redistribute it and/or modify
    it under the same terms as Perl itself.

=head1 AUTHOR

moznion <moznion@gmail.com>

=end pod

