=NAME
Pod::To::Markdown - Render Pod as Markdown

=begin SYNOPSIS
From command line:

    $ perl6 --doc=Markdown lib/To/Class.pm

From Perl6:
=begin code :lang<perl6>
use Pod::To::Markdown;

=NAME
foobar.pl

=SYNOPSIS
    foobar.pl <options> files ...

say pod2markdown($=pod);
=end code
=end SYNOPSIS

=for EXPORTS
    class Pod::To::Markdown
    sub pod2markdown

=DESCRIPTION


class Pod::To::Markdown {

use Pod::To::HTML;

my Bool $in-code-block = False;

multi sub pod2markdown(Pod::Heading $pod, Bool :$no-fenced-codeblocks) is export {
    my Str $head = pod2markdown(
        $pod.contents,
        # Collapse contents without newlines, is this correct behaviour?
        :positional-separator(' '),
        :$no-fenced-codeblocks,
    );
    head2markdown($pod.level, $head);
}

multi sub pod2markdown(Pod::Block::Code $pod, Bool :$no-fenced-codeblocks) is export {
    temp $in-code-block = True;
    if $pod.config<lang> and !$no-fenced-codeblocks {
        ("```", $pod.config<lang>, "\n", $pod.contents.join, "```").join;
    }
    else {
        $pod.contents>>.&pod2markdown(:$no-fenced-codeblocks).join.trim-trailing.indent(4);
    }
}

multi sub pod2markdown(Pod::Block::Named $pod, Bool :$no-fenced-codeblocks) is export {
    given $pod.name {
        when 'pod'    { pod2markdown($pod.contents, :$no-fenced-codeblocks) }
        when 'para'   { $pod.contents>>.&pod2markdown(:$no-fenced-codeblocks).join(' ') }
        when 'defn'   { pod2markdown($pod.contents, :$no-fenced-codeblocks) }
        when 'config' { }
        when 'nested' { }
        default       { head2markdown(1, $pod.name) ~ "\n\n" ~ pod2markdown($pod.contents, :$no-fenced-codeblocks); }
    }
}

multi sub pod2markdown(Pod::Block::Para $pod, Bool :$no-fenced-codeblocks) is export {
    $pod.contents>>.&pod2markdown(:$no-fenced-codeblocks).join
}

sub entity-escape($str) {
    $str.trans([ '&', '<', '>' ] => [ '&amp;', '&lt;', '&gt;' ])
}

multi sub pod2markdown(Pod::Block::Table $pod, Bool :$no-fenced-codeblocks) is export {
    return node2html($pod).trim;
}

multi sub pod2markdown(Pod::Block::Declarator $pod, Bool :$no-fenced-codeblocks) {
    my $lvl = 2;
    next unless $pod.WHEREFORE.WHY;
    my $ret = '';
    my $what = do given $pod.WHEREFORE {
        when Method {
            my $returns = ($_.signature.returns.WHICH.perl eq 'Mu')
                ?? ''
                !! (' returns ' ~ $_.signature.returns.perl);
            my @params = $_.signature.params[1..*];
               @params.pop if @params[*-1].name eq '%_';
            my $name = $_.name;
            $ret ~= head2markdown($lvl+1, "method $name") ~ "\n\n";
            $ret ~= $no-fenced-codeblocks
            ?? ("method $name" ~ signature2markdown(@params) ~ "$returns").indent(4)
            !! "```\nmethod $name" ~ signature2markdown(@params) ~ "$returns\n```";
        }
        when Sub {
            my $returns = ($_.signature.returns.WHICH.perl eq 'Mu')
                ?? ''
                !! (' returns ' ~ $_.signature.returns.perl);
            my @params = $_.signature.params;
            my $name = $_.name;
            $ret ~= head2markdown($lvl+1, "sub $name") ~ "\n\n";
            $ret ~= $no-fenced-codeblocks
            ?? ("sub $name" ~ signature2markdown(@params) ~ "$returns").indent(4)
            !! "```\nsub $name" ~ signature2markdown(@params) ~ "$returns\n```";
        }
        when .HOW ~~ Metamodel::ClassHOW {
            if ($_.WHAT.perl eq 'Attribute') {
                my $name = $_.gist.subst('!', '.');
                $ret ~= head2markdown($lvl+1, "has $name");
            }
            else {
                my $name = $_.perl;
                $ret ~= head2markdown($lvl, "class $name");
            }
        }
        when .HOW ~~ Metamodel::ModuleHOW {
            my $name = $_.perl;
            $ret ~= head2markdown($lvl, "module $name");
        }
        when .HOW ~~ Metamodel::PackageHOW {
            my $name = $_.perl;
            $ret ~= head2markdown($lvl, "package $name");
        }
        default {
            ''
        }
    }
    "$what\n\n{$pod.WHEREFORE.WHY.contents}";
}

multi sub pod2markdown(Pod::Block::Comment $pod, Bool :$no-fenced-codeblocks) is export { }

multi sub pod2markdown(Pod::Item $pod, Bool :$no-fenced-codeblocks) is export {
    my $level = $pod.level // 1;
    my $markdown = '* ' ~ pod2markdown($pod.contents[0], :$no-fenced-codeblocks);
    $markdown ~= "\n\n" ~ pod2markdown($pod.contents[1..Inf], :$no-fenced-codeblocks).indent(2)
        if $pod.contents.elems > 1;
    $markdown.indent($level * 2);
}

my %formats =
  C => "bold",
  L => "underline",
  D => "underline",
  R => "inverse"
;

my %Mformats =
    U => '_',
    I => '*',
    B => '**',
    C => '`';

my %HTMLformats =
    R => 'var';

multi sub pod2markdown(Pod::FormattingCode $pod, Bool :$no-fenced-codeblocks) is export {
    return '' if $pod.type eq 'Z';
    my $text = $pod.contents>>.&pod2markdown(:$no-fenced-codeblocks).join;

    # It is safer to strip formatting in code blocks
    return $text if $in-code-block;

    if $pod.type eq 'L' {
        if $pod.meta.elems > 0 {
            $text =  '[' ~ $text ~ '](' ~ $pod.meta[0] ~ ')';
        } else {
            $text = '[' ~ $text ~ '](' ~ $text ~ ')';
        }
    }
    # If the code contains a backtick, we need to do more work
    if $pod.type eq 'C' and $text.contains('`') {
        # We need to open and close with some number larger than the largest
        # contiguous number of backticks
        my $length = $text.match(/'`'*/, :g).sort.tail.chars + 1;
        my $symbol = %Mformats{$pod.type} x $length;
        # If text starts with a backtick we need to pad it with a space
        my $begin = $text.starts-with('`')
            ?? $symbol ~ ' '
            !! $symbol;
        # likewise if it ends with a backtick that must be padded as well
        my $end = $text.ends-with('`')
            ?? ' ' ~ $symbol
            !! $symbol;
        $text = $begin ~ $text ~ $end
    }
    else {
        $text = %Mformats{$pod.type} ~ $text ~ %Mformats{$pod.type}
            if %Mformats.EXISTS-KEY: $pod.type;
    }

    $text = sprintf '<%s>%s</%s>',
        %HTMLformats{$pod.type},
        $text,
        %HTMLformats{$pod.type}
        if %HTMLformats.EXISTS-KEY: $pod.type;

    $text;
}

multi sub pod2markdown(Positional $pod, Str :$positional-separator = "\n\n", Bool :$no-fenced-codeblocks) is export {
    $pod>>.&pod2markdown(:$no-fenced-codeblocks).join($positional-separator)
}

multi sub pod2markdown(Pod::Config $pod, Bool :$no-fenced-codeblocks) is export { }

#| Render Pod as Markdown
multi sub pod2markdown($pod, Str :$positional-separator? = "\n\n", Bool :$no-fenced-codeblocks) returns Str is export {
    $pod.Str
}
=begin pod
To render without fenced codeblocks (C<```>), as some markdown engines
don't support this, use the :no-fenced-codeblocks option. If you want to
have code show up as C<```perl6> to enable syntax highlighting on
certain markdown renderers, use:

=begin code
=begin code :lang<perl6>
=end code

=end pod

method render($pod, Bool :$no-fenced-codeblocks) {
    pod2markdown($pod, :$no-fenced-codeblocks);
}

sub head2markdown(Int $lvl, Str $head) {
    my $level = ($lvl < 6) ?? $lvl !! 6;
    given $level {
        when 1  { $head ~ "\n" ~ ('=' x $head.chars) }
        when 2  { $head ~ "\n" ~ ('-' x $head.chars) }
        default { '#' x $level ~ ' ' ~ $head }
    }
}

# sub table2markdown($pod) {
#     my @rows = $pod.contents;
#     my @maxes;
#     for @rows, $pod.headers.item -> @row {
#       for 0..^@row -> $i {
#           @maxes[$i] = max @maxes[$i], @row[$i].chars;
#       }
#     }
#     my $fmt = Arr@maxes>>.sprintf('%%-%ds)
#     @rows.map({
#       my @cols = @_;
#       my @ret;
#       for 0..@_ -> $i {
#           @ret.push: sprintf('%-'~$i~'s',

#     if $pod.headers {
#       @rows.unshift([$pod.headers.item>>.chars.map({'-' x $_})]);
#       @rows.unshift($pod.headers.item);
#     }
#     @rows>>.join(' | ') ==> join("\n");
# }

sub signature2markdown($params) {
      $params.elems ??
      "(\n    " ~ $params.map({ $_.perl }).join(",\n    ") ~ "\n)"
      !! "()";
}

=LICENSE
This is free software; you can redistribute it and/or modify it under the terms of the L<Artistic License 2.0|http://www.perlfoundation.org/artistic_license_2_0>.

}

# Trying to process this file itself results in the following:
# $ perl6 --doc=Markdown lib/Pod/To/Markdown.pm6
# ===SORRY!===
# P6M Merging GLOBAL symbols failed: duplicate definition of symbol Markdown
#
# Here's a hack to generate README.md from this POD:
# perl6 lib/Pod/To/Markdown.pm6 > README.md

sub MAIN() {
    print Pod::To::Markdown.render($=pod);
}

# vim: ts=8
