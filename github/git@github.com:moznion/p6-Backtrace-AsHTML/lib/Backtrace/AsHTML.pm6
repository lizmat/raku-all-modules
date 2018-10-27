use v6;
use MONKEY-TYPING;

unit class Backtrace::AsHTML;

my constant $P6HOME = $*VM.prefix ~ '/..';

augment class Backtrace {
    method as-html(*%opt) returns Str {
        return render(self, %opt);
    }
};

my sub render(Backtrace $bt, %opt) returns Str {
    my $traces = $bt.reverse;

    my $msg = encode-html($traces[0].Str.chomp);
    my $out = sprintf '<!doctype html><head><title>Error: %s</title>', $msg;

    %opt<style> ||= q:heredoc/STYLE/;
    a.toggle { color: #444 }
    body { margin: 0; padding: 0; background: #fff; color: #000; }
    h1 { margin: 0 0 .5em; padding: .25em .5em .1em 1.5em; border-bottom: thick solid #002; background: #444; color: #eee; font-size: x-large; }
    pre.message { margin: .5em 1em; }
    li.frame { font-size: small; margin-top: 3em }
    li.frame:nth-child(1) { margin-top: 0 }
    pre.context { border: 1px solid #aaa; padding: 0.2em 0; background: #fff; color: #444; font-size: medium; }
    pre .match { color: #000;background-color: #f99; font-weight: bold }
    pre.vardump { margin:0 }
    pre code strong { color: #000; background: #f88; }

    table.lexicals, table.arguments { border-collapse: collapse }
    table.lexicals td, table.arguments td { border: 1px solid #000; margin: 0; padding: .3em }
    table.lexicals tr:nth-child(2n) { background: #DDDDFF }
    table.arguments tr:nth-child(2n) { background: #DDFFDD }
    .lexicals, .arguments { display: none }
    .variable, .value { font-family: monospace; white-space: pre }
    td.variable { vertical-align: top }
    STYLE

    $out ~= sprintf '<style type="text/css">%s</style>', %opt<style>;

    $out ~= sprintf q:heredoc/HEAD/, $msg;
    <script language="JavaScript" type="text/javascript">
    function toggleThing(ref, type, hideMsg, showMsg) {
        var css = document.getElementById(type+'-'+ref).style;
        css.display = css.display == 'block' ? 'none' : 'block';

        var hyperlink = document.getElementById('toggle-'+ref);
        hyperlink.textContent = css.display == 'block' ? hideMsg : showMsg;
    }

    function toggleArguments(ref) {
        toggleThing(ref, 'arguments', 'Hide function arguments', 'Show function arguments');
    }

    function toggleLexicals(ref) {
        toggleThing(ref, 'lexicals', 'Hide lexical variables', 'Show lexical variables');
    }
    </script>
    </head>
    <body>
    <h1>Error trace</h1><pre class="message">%s</pre><ol>
    HEAD

    my $i = 0;
    for @$traces -> Backtrace::Frame $frame {
        $i++;
        my Backtrace::Frame $next-frame = $traces[$i]; # peek next

        $out ~= join(
            '',
            '<li class="frame">',
            ($next-frame && $next-frame.subname) ?? encode-html("in " ~ $next-frame.subname) !! '',
            ' at ',
            $frame.file ?? encode-html($frame.file) !! '',
            ' line ',
            $frame.line,
            '<pre class="context"><code>',
            build-context($frame) || '',
            '</code></pre>',
            '</li>',
        );
    }

    $out ~= '</ol>';
    $out ~= '</body></html>';

    return $out;
}

my sub build-context(Backtrace::Frame $frame) returns Str {
    my $file = $frame.file;
    my $linenum = $frame.line;

    unless $file.IO.f {
        # maybe runtime file
        $file = "$P6HOME/$file";
    }

    my Str $code;
    if $file.IO.f {
        my $start = $linenum - 3;
        my $end   = $linenum + 3;
        $start = $start < 1 ?? 1 !! $start;

        my $fh = try { open $file, :bin } or die "cannot open $file: $!";
        my $cur-line = 0;

        my @lines = $fh.lines;
        for @lines -> $line {
            ++$cur-line;

            last if $cur-line > $end;
            next if $cur-line < $start;

            (my $l = $line) ~~ s:global/\t/        /;
            my @tag = $cur-line == $linenum ?? ['<strong class="match">', '</strong>']
                                            !! ['', ''];
            $code ~= sprintf "%s%5d: %s%s\n", @tag[0], $cur-line, encode-html($l), @tag[1];
        }

        CATCH {
            default {
                # probably read bin file...
                $code = '';
            }
        }

        $fh.close;
    }

    return $code;
}

my sub encode-html(Str $str) {
    return $str.trans(
        [ '&',     '<',    '>',    '"',      q{'}    ] =>
        [ '&amp;', '&lt;', '&gt;', '&quot;', '&#39;' ]
    );
}

=begin pod

=head1 NAME

Backtrace::AsHTML - Displays back trace in HTML

=head1 SYNOPSIS

  use Backtrace::AsHTML;

  my $trace = Backtrace.new;
  my $html  = $trace.as-html;

=head1 DESCRIPTION

Backtrace::AsHTML adds C<as-html> method to L<Backtrace> which displays the back trace
in beautiful HTML, with code snippet context.

<img src="https://i.gyazo.com/6ac7f82ef6fb0a05d7de9a11dbdcaa0b.png">

This library is inspired by L<Devel::StackTrace::AsHTML of perl5|https://metacpan.org/release/Devel-StackTrace-AsHTML> and much of code is taken from that.

=head1 METHODS

=item C<as-html>

C<as-html> shows the fully back trace in HTML.

This method will be added into L<Backtrace> class automatically when used this.

=head1 TODO

=item show lexical variables for each frames (How?)

=item show arguments for each frames? (How??)

=head1 AUTHOR

moznion <moznion@gmail.com>

=head1 COPYRIGHT AND LICENSE

    Copyright 2015 moznion

    This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

And license of the original perl5's Devel::StackTrace::AsHTML is

    This library is free software; you can redistribute it and/or modify
    it under the same terms as Perl itself.

=end pod

