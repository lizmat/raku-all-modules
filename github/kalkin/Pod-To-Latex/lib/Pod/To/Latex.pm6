use v6;
#`(
Copyright © Bahtiar `kalkin-` Gadimov bahtiar@gadimov.de

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

)

unit class Pod::To::Latex;

my $title;
my $subtitle;
my $verbatim;

constant HEADER = q:to/END/;
\documentclass{scrartcl}
\usepackage{hyperref}
\usepackage{color}
\usepackage{listings}
\usepackage{fontspec}

\definecolor{keyword0}{RGB}{133,153,0}
\definecolor{keyword1}{RGB}{220,50,47}
\definecolor{keyword2}{RGB}{181,137,0}
\definecolor{keyword3}{RGB}{203,75,22}
\definecolor{string}{RGB}{108,113,196}
\definecolor{comment}{RGB}{102,123,131}
\definecolor{background}{RGB}{253,246,227}
\lstdefinelanguage{Perl6} {
    morekeywords={[0]class,role,grammar,method,given,submethod,sub},
    morekeywords={[1]when,rw,required},
    morekeywords={[2]True,False,Bool,Str,Int,Positional,IO},
    morekeywords={[3]has,my,is,unit},
    sensitive=false,
    morecomment=[l]{\#},
    morecomment=[s]{/*}{*/},
    morestring=[b]",
}

\lstset{
    basicstyle=\footnotesize,
    numbers=left,
    keepspaces=true,
    showstringspaces=false,
    showtabs=false,
    keywordstyle={[0]\color{keyword0}\textbf},
    keywordstyle={[1]\color{keyword1}\textbf},
    keywordstyle={[2]\color{keyword2}},
    keywordstyle={[3]\color{keyword3}},
    stringstyle={\color{string}\textit},
    backgroundcolor=\color{background},
    commentstyle=\color{comment}
}
END

method render($pod) {
    my $doc =  HEADER;
    my $result = pod2text $pod;
    $doc ~= $title ~ "\n" if $title;
    $doc ~= $subtitle ~ "\n" if $subtitle;
    $doc ~= '\begin{document}' ~ "\n";
    $doc ~= '\maketitle' ~ "\n" if $title;
    $doc ~= $result;
    $doc ~= '\end{document}';
    return $doc;
}

sub pod2text($pod) is export {
    #say "pod2text: " ~ $pod.WHAT.perl;
    given $pod {
        when Pod::Block::Named { named2text($pod)            }
        when Pod::Heading { heading2text($pod)        }
        when Pod::Block::Code  { code2text($pod)                }
        when Pod::Item         { item2text($pod)      }
        when Pod::Block::Para  { twrap( $pod.contents.map({pod2text($_)}).join("") ) }
        when Pod::FormattingCode { formatting2text($pod)        }
        when Positional        { .flat».&pod2text.grep(?*).join: "\n\n" }
        default                {
            if $verbatim {
                $pod.Str
            } else {
                $pod.Str.subst("\\", '\textbackslash ', :g)
                        .subst('~', '\textasciitilde{}', :g)
                        .subst('^', '\textasciicircum{}', :g)
                        .subst(/(<[$#%&_{}]>)/, -> { "\\$0" } , :g)
                        .subst('...', '…', :g)
            }
        }
    }
}
sub code2text($pod) {
    $verbatim = True;
    my $lang = $pod.config<lang> ?? $pod.config<lang>.tc !! 'Perl6';
    my $result;
    $lang = "sh" if $lang ~~ "Shell";
    $lang = "Perl" if $lang ~~ "Perl5";
    if $lang ~~ 'Text' {
        $result = qq:to/END/;
        \\begin\{verbatim\}
        { $pod.contents>>.&pod2text.join }
        \\end\{verbatim\}
        END
    } else {
        $result = qq:to/END/;
        \\begin\{lstlisting\}[language={$lang}]
        { $pod.contents>>.&pod2text.join }
        \\end\{lstlisting\}
        END
    }
    $verbatim = False;
    return $result;
}

sub item2text($pod) {
    '\begin{itemize}' ~ "\n" ~
    '\item ' ~ pod2text($pod.contents).chomp.chomp ~
    '\end{itemize}' ~ "\n"
}

sub named2text($pod) {
    #say "named2text " ~ $pod.WHAT.perl;
    given $pod.name {
        when 'pod'  { pod2text($pod.contents)     }
        when $pod.name ~~ 'TITLE' {
            $title = '\title{' ~ pod2text($pod.contents) ~ '}'
        }
        when $pod.name ~~ 'SUBTITLE' {
            $subtitle = '\subtitle{' ~ pod2text($pod.contents) ~ '}'
        }
        default     { $pod.name ~ "\n" ~ pod2text($pod.contents) }
    }
}

sub heading2text(Pod::Heading $pod) {
    given $pod.level {
        when 1 { '\section{' ~ pod2text($pod.contents) ~ '}' }
        when 2 { '\subsection{' ~ pod2text($pod.contents) ~ '}' }
        when 3 { '\subsubsection{' ~ pod2text($pod.contents) ~ '}' }
    }
}

sub formatting2text(Pod::FormattingCode $pod) {
    given $pod.type {
        when 'L' { formatting2link $pod }
        when 'I' {
            '\textit{' ~ $pod.contents>>.&pod2text.join ~ '}'
        }
        when 'X' {
            $pod.contents>>.&pod2text.join
        }
        when 'C' {
            '\texttt{' ~ $pod.contents>>.&pod2text.join ~ '}'
        }
        default { $pod.type ~ ' → ' ~ $pod.contents».&pod2text.join }
    }
}

sub formatting2link(Pod::FormattingCode $pod) {

    if $pod.meta.so {
        '\href{' ~ $pod.meta ~ '}{' ~ $pod.contents>>.&pod2text.join ~ '}'
    } else {
        '\url{' ~ $pod.contents>>.&pod2text.join ~ '}'
    }
}

sub twrap($text is copy, :$wrap=75 ) {
    $text ~~ s:g/(. ** {$wrap} <[\s]>*)\s+/$0\n/;
    $text
}

=begin pod

=head1 NAME

Pod::To::Latex - Convert pod to LaTeX.

=head1 SYNOPSIS

  use Pod::To::Latex;

=head1 DESCRIPTION

Pod::To::Latex converts Pod6 documents to latex.

=head1 USAGE

You will need to have C<xelatex>, C<KOMA-Script> & C<listing> package installed

=begin code
perl6 -Ilib --doc=Latex Some-File.pod6 > Some-File.tex

xelatex Some-File.tex

xpdf Some-File.pdf
=end code

=head1 Installing Dependencies

=head2 Fedora

=begin code
sudo dnf install texlive-xetex-bin texlive-koma-script.noarch texlive-listings.noarch texlive-euenc
=end code

=head1 TODO

=item Improve Perl 6 syntax highlighting.
=item Remove pdf generation date from C<\maketitle>
=item Other cosmetic improvements?

=head1 AUTHOR


Bahtiar `kalkin-` Gadimov bahtiar@gadimov.de


=head1 COPYRIGHT AND LICENSE

Copyright © Bahtiar `kalkin-` Gadimov bahtiar@gadimov.de

License GPLv3: The GNU General Public License, Version 3, 29 June 2007
<https://www.gnu.org/licenses/gpl-3.0.txt>

This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.


=end pod
