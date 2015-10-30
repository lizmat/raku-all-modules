# GEx.pm6 --- predefined grammar exceptions.

# XXX using this 'unit module' puts all the classes under the name below, so
# e.g. C<ExPointer> becomes C<Grammar::Parsefail::Exceptions::ExPointer>, which
# isn't desired.

#unit module Grammar::Parsefail::Exceptions;

use v6;

class X::Grammar::Epitaph is Exception {
    has $.panic;
    has @.sorrows;
    has @.worries;

    has $.sorry_limit;

    method gist(X::Grammar::Epitaph:D:) {
        my ($redbg, $reset) = !$*DISTRO.is-win ?? ("\e[41;1m", "\e[0m") !! ("", "");

        my $gist;
        $gist = "$redbg===SORRY!===$reset\n" if +@!sorrows || $!panic.defined;

        with $!panic {
            $gist ~= "Main issue:\n";
            $gist ~= $!panic.gist(:!singular).indent(4) ~ "\n";

            if +@!sorrows {
                $gist ~= "\nOther problems:\n";
            }
        } elsif +@!sorrows {
            $gist ~= "Problems:\n";
        }

        for @!sorrows {
            $gist ~= $_.gist(:!singular).indent(4) ~ "\n";
        }

        if +@!worries {
            if +@!sorrows || $!panic.defined {
                $gist ~= "\nOther potential difficulties:\n";
            } else {
                $gist ~= "Potential difficulties:\n";
            }
        }

        for @!worries {
            $gist ~= $_.gist(:!singular).indent(4) ~ "\n";
        }

        with $!panic {
            $gist ~= "\nThe main issue stopped parsing immediately. Please fix it so that we can parse more of the source code."
        } elsif +@!sorrows >= $!sorry_limit {
            $gist ~= "\nThere were too many problems to continue parsing. Please fix some of them so that we can parse more of the source code."
        } elsif +@!sorrows {
            $gist ~= "\nThe problems above prevented the parser from producing something useful (however it was able to parse everything). Fixing them will allow useful output from the parser.";
        } elsif +@!worries {
            $gist ~= "\nThe potential difficulties above may cause unexpected results, since they don't prevent the parser from completing.";
            $gist ~= "\nFix or suppress the issues as needed to avoid any doubt in the results of parsing.";
        } else {
            $gist ~= "\nSomehow threw an Epitaph without anything to actually throw. This likely indicates a deeper problem."
        }

        $gist.chomp
    }
}

class ExPointer {
    has $.file is rw;
    has $.line is rw;
    has $.col is rw;

    method gist(ExPointer:D:) { "$!file:$!line,$!col" }
}

class X::Grammar is Exception {
    has $.goodpart;
    has $.badpart;

    has ExPointer $.err-point;

    has $.hint-message;
    has $.hint-but-no-pointer;
    has $.hint-beforepoint;
    has $.hint-afterpoint;

    has ExPointer $.hint-point;

    method message { "Unspecified grammar error" }

    method gist(X::Grammar:D: :$singular = True) {
        my ($redbg, $red, $green, $yellow, $reset, $eject, $hintat) = !$*DISTRO.is-win
           ??
           ("\e[41;1m", "\e[31m", "\e[32m", "\e[33m", "\e[0m", "\c[EJECT SYMBOL]", "▶")
           !!
           ("", "", "", "", "", "<HERE>", "<THERE>");

        my $gist = $singular ?? "$redbg===SORRY!===$reset Issue in $!err-point.gist():\n" !! "";
        $gist ~= $.message ~ "\n";
        $gist ~= "at $!err-point.gist()\n";
        $gist ~= "------>|$green$.goodpart";
        $gist ~= "$yellow$eject";
        $gist ~= "{$red}{$.badpart.chomp}$reset";

        with $.hint-message {
            my $hint;
            $hint ~= "\n\n$.hint-message\n";
            unless $.hint-but-no-pointer {
                $hint ~= "at $!hint-point.gist()\n";
                $hint ~= "------>|$green$.hint-beforepoint";
                $hint ~= "$yellow$hintat";
                $hint ~= "{$green}{$.hint-afterpoint.chomp}$reset";
            }
            $gist ~= $hint.indent(4);
        }

        $gist.chomp;
    }
}

class X::Grammar::AdHoc is X::Grammar {
    has $.payload;

    method message { "(ad-hoc) $!payload" }
}