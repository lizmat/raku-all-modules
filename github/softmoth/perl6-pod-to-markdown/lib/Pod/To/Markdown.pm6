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

# Trying to process this file itself results in the following:
# $ perl6 --doc=Markdown lib/Pod/To/Markdown.pm6
# ===SORRY!===
# P6M Merging GLOBAL symbols failed: duplicate definition of symbol Markdown
#
# Here is a hack to generate README.md from this Pod:
# perl6 lib/Pod/To/Markdown.pm6 > README.md

sub MAIN() {
    print ::('Pod::To::Markdown').render($=pod);
}


unit class Pod::To::Markdown;

use Pod::To::HTML;


#| Render Pod as Markdown
multi sub pod2markdown($pod, Bool :$no-fenced-codeblocks)
returns Str
is export
{
    my Bool $*FENCED-CODEBLOCKS = !$no-fenced-codeblocks;
    my Bool $*IN-CODE-BLOCK = False;
    my $*POSITIONAL-SEPARATOR = "\n\n";
    node2md($pod);
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


#| Render Pod as Markdown, see pod2markdown
method render($pod, Bool :$no-fenced-codeblocks)
returns Str
{
    pod2markdown($pod, :$no-fenced-codeblocks);
}


multi sub node2md(Pod::Heading $pod) {
    # Collapse contents without newlines, is this correct behaviour?
    my $*POSITIONAL-SEPARATOR = ' ';
    my Str $head = node2md($pod.contents);
    head2md($pod.level, $head);
}

multi sub node2md(Pod::Block::Code $pod) {
    my $*IN-CODE-BLOCK = True;
    if $pod.config<lang> and $*FENCED-CODEBLOCKS {
        ("```", $pod.config<lang>, "\n", $pod.contents.join, "```").join;
    }
    else {
        $pod.contents>>.&node2md.join.trim-trailing.indent(4);
    }
}

multi sub node2md(Pod::Block::Named $pod) {
    given $pod.name {
        when 'pod'    { node2md($pod.contents) }
        when 'para'   { $pod.contents>>.&node2md.join(' ') }
        when 'defn'   { node2md($pod.contents) }
        when 'config' { }
        when 'nested' { }
        default       { head2md(1, $pod.name) ~ "\n\n" ~ node2md($pod.contents); }
    }
}

multi sub node2md(Pod::Block::Para $pod) {
    $pod.contents>>.&node2md.join
}

sub entity-escape($str) {
    $str.trans([ '&', '<', '>' ] => [ '&amp;', '&lt;', '&gt;' ])
}

multi sub node2md(Pod::Block::Table $pod) {
    return node2html($pod).trim;
}

multi sub node2md(Pod::Block::Declarator $pod) {
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
            $ret ~= head2md($lvl+1, "method $name") ~ "\n\n";
            $ret ~= $*FENCED-CODEBLOCKS
                ?? "```\nmethod $name" ~ signature2md(@params) ~ "$returns\n```"
                !! ("method $name" ~ signature2md(@params) ~ "$returns").indent(4)
            ;
        }
        when Sub {
            my $returns = ($_.signature.returns.WHICH.perl eq 'Mu')
                ?? ''
                !! (' returns ' ~ $_.signature.returns.perl);
            my @params = $_.signature.params;
            my $name = $_.name;
            $ret ~= head2md($lvl+1, "sub $name") ~ "\n\n";
            $ret ~= $*FENCED-CODEBLOCKS
                ?? "```\nsub $name" ~ signature2md(@params) ~ "$returns\n```"
                !! ("sub $name" ~ signature2md(@params) ~ "$returns").indent(4)
                ;
        }
        when .HOW ~~ Metamodel::ClassHOW {
            if ($_.WHAT.perl eq 'Attribute') {
                my $name = $_.gist.subst('!', '.');
                $ret ~= head2md($lvl+1, "has $name");
            }
            else {
                my $name = $_.perl;
                $ret ~= head2md($lvl, "class $name");
            }
        }
        when .HOW ~~ Metamodel::ModuleHOW {
            my $name = $_.perl;
            $ret ~= head2md($lvl, "module $name");
        }
        when .HOW ~~ Metamodel::PackageHOW {
            my $name = $_.perl;
            $ret ~= head2md($lvl, "package $name");
        }
        default {
            ''
        }
    }
    "$what\n\n{$pod.WHEREFORE.WHY.contents}";
}

multi sub node2md(Pod::Block::Comment $pod) { }

multi sub node2md(Pod::Item $pod) {
    my $level = $pod.level // 1;
    my $markdown = '* ' ~ node2md($pod.contents[0]);
    $markdown ~= "\n\n" ~ node2md($pod.contents[1..Inf]).indent(2)
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

multi sub node2md(Pod::FormattingCode $pod) {
    return '' if $pod.type eq 'Z';
    my $text = $pod.contents>>.&node2md.join;

    # It is safer to strip formatting in code blocks
    return $text if $*IN-CODE-BLOCK;

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

multi sub node2md(Positional $pod) {
    $pod>>.&node2md.join($*POSITIONAL-SEPARATOR)
}

multi sub node2md(Pod::Config $pod) { }

multi sub node2md($pod) returns Str {
    $pod.Str
}


sub head2md(Int $lvl, Str $head) {
    my $level = ($lvl < 6) ?? $lvl !! 6;
    given $level {
        when 1  { $head ~ "\n" ~ ('=' x $head.chars) }
        when 2  { $head ~ "\n" ~ ('-' x $head.chars) }
        default { '#' x $level ~ ' ' ~ $head }
    }
}

sub signature2md($params) {
      $params.elems ??
      "(\n    " ~ $params.map({ $_.perl }).join(",\n    ") ~ "\n)"
      !! "()";
}

=begin comment
This isn't useful as long as all tables are rendered as HTML. It
could still come in handy if, esthetically, we'd want simple
tables rendered as plain Markdown.

sub table2md(Pod::Block::Table $pod) {
    my @rows = $pod.contents;
    my @maxes;
    for @rows, $pod.headers.item -> @row {
      for 0..^@row -> $i {
          @maxes[$i] = max @maxes[$i], @row[$i].chars;
      }
    }
    my $fmt = Arr@maxes>>.sprintf('%%-%ds)
    @rows.map({
      my @cols = @_;
      my @ret;
      for 0..@_ -> $i {
          @ret.push: sprintf('%-'~$i~'s',

    if $pod.headers {
      @rows.unshift([$pod.headers.item>>.chars.map({'-' x $_})]);
      @rows.unshift($pod.headers.item);
    }
    @rows>>.join(' | ') ==> join("\n");
}
=end comment

=LICENSE
This is free software; you can redistribute it and/or modify it under the terms of the L<Artistic License 2.0|http://www.perlfoundation.org/artistic_license_2_0>.

# vim: ts=8
