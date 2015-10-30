# GrammarError.pm6 --- role for handling errors in grammar parsing

unit module Grammar::Parsefail;

use v6;

use Grammar::Parsefail::Exceptions;

class Grammar::Parsefail is Grammar {
    has @!nl-list;

#### Overriding parsing methods

    method parse($target, :$filename = '<unspecified file>', *%opts) {
        my @*SORROWS;
        my @*WORRIES;
        my $*SORRY_LIMIT = 10;
        my $*FILENAME = $filename;

        nextwith($target, |%opts);
    }

    method subparse($target, :$filename = '<unspecified file>', *%opts) {
        my @*SORROWS;
        my @*WORRIES;
        my $*SORRY_LIMIT = 10;
        my $*FILENAME = $filename;

        nextwith($target, |%opts);
    }

    method parsefile(Str(Cool) $filename, *%opts) {
        my @*SORROWS;
        my @*WORRIES;
        my $*SORRY_LIMIT = 10;
        my $*FILENAME = $filename;

        nextwith($filename, |%opts);
    }

#### Methods for handling errors.

    method set_filename(Str(Stringy:D) $fn) { $*FILENAME = $fn }

    method limit_sorrows(UInt() $num) {
        $*SORRY_LIMIT = $num;
    }

    # like HLL::Compiler.lineof, but gives a column too
    method !linecol($text, $at) {
        # fill the nl-list if it's not yet
        unless @!nl-list {
            for $text.lines {
                @!nl-list.push($_.chars);
                @!nl-list[*-1]++ if +@!nl-list - 1; # count newlines on the next line (so skip for first line)
            }

            # we want cumulative position numbers in the list, so triangle
            # reduce it is! The list now contains the number of characters by
            # the end of that line (so a first line with 2 chars will have the
            # Int 2 in @!nl-list[0], for example)
            @!nl-list = [\+] @!nl-list;
        }

        # now to find the right line number
        my $line-number = $at == $text.chars ?? +@!nl-list !! @!nl-list.first-index(* >= $at) + 1; # +1 for zero-index to line numbers

        # and now the column
        my $col-number = $line-number == 1 ?? $at !! @!nl-list[$line-number - 1] - $at - 1;

        # hackish correction for EOF pointer
        $col-number = $text.lines[*-1].chars if $col-number < 0;

        return ($line-number, $col-number);
    }

    method !takeline(Str $fromthis, Int $lineno) { $fromthis.lines[$lineno - 1] }

    method !make-ex($/, Exception $type, %opts is copy) {
        my $linecol = self!linecol($/.orig, $/.to);

        my $fled-line = self!takeline($/.orig, $linecol[0]);

        %opts<goodpart> = $fled-line.substr(0, $linecol[1]);
        %opts<badpart>  = $fled-line.substr($linecol[1]);

        %opts<err-point> = ExPointer.new(file => $*FILENAME // "<unspecified file>",
                                         line => $linecol[0],
                                         col  => $linecol[1]);

        if %opts<HINT-MATCH>:exists {
            my $hint = %opts<HINT-MATCH>;

            my $hintlc = self!linecol($hint.orig, $hint.from);

            my $hint-line = self!takeline($hint.orig, $hintlc[0]);

            %opts<hint-beforepoint> = $hint-line.substr(0, $hintlc[1]);
            %opts<hint-afterpoint>  = $hint-line.substr(0, $hintlc[1]);

            %opts<hint-point> = ExPointer.new(file => $*FILENAME // "<unspecified file>",
                                              line => $hintlc[0],
                                              col  => $hintlc[1]);

            %opts<HINT-MATCH>:delete;
            %opts<hint-but-no-pointer> = 0;
        } else {
            %opts<hint-but-no-pointer> = 1;
        }

        $type.new(|%opts);
    }

    #| Use this for things that are possibly concerning, but don't cause
    #| problems for your ability to parse something
    method typed_worry(Exception $type, *%exnameds) {
        @*WORRIES.push(self!make-ex(self.MATCH, $type, %exnameds));
        self;
    }

    #| This is for stuff that keeps you from parsing something (that is, the
    #| text you're parsing is now considered to have invalid syntax), but you
    #| could still theoretically parse more, to maybe find more issues.
    method typed_sorry(Exception $type, *%exnameds) {
        @*SORROWS.push(self!make-ex(self.MATCH, $type, %exnameds));

        if +@*SORROWS >= ($*SORRY_LIMIT // 10) { # we've got too much to be sorry for, bail
            self!give-up-ghost();
        }
        self;
    }

    #| For when you've not only got invalid syntax, but you can't possibly try
    #| to parse beyond that.
    method typed_panic(Exception $type, *%exnameds) {
        my $ex = self!make-ex(self.MATCH, $type, %exnameds);
        if +@*SORROWS || +@*WORRIES {
            self!give-up-ghost($ex);
        } else {
            $ex.throw;
        }
        self;
    }

    #| For worrying without constructing your own exception object
    method worry(Str $string) {
        self.typed_worry(X::Grammar::AdHoc, payload => $string);
    }

    #| For being sorry without making a specific exception object
    method sorry(Str $string) {
        self.typed_sorry(X::Grammar::AdHoc, payload => $string);
    }

    #| For panicking without making a specific exception object
    method panic(Str $string) {
        self.typed_panic(X::Grammar::AdHoc, payload => $string);
    }

    #| Use this at the end of your TOP rule to get any sorrows and worries out
    #| of the way
    method express_concerns() {
        if +@*SORROWS == 1 && !+@*WORRIES {
            @*SORROWS[0].throw;
        } elsif +@*SORROWS || +@*WORRIES {
            self!give-up-ghost();
        }
        self;
    }

    method !give-up-ghost(Exception $panic?) {
        my $ghost;
        with $panic {
            $ghost = X::Grammar::Epitaph.new(:$panic,
                                             worries     => @*WORRIES,
                                             sorrows     => @*SORROWS,
                                             sorry_limit => $*SORRY_LIMIT);
        } else {
            $ghost = X::Grammar::Epitaph.new(worries     => @*WORRIES,
                                             sorrows     => @*SORROWS,
                                             sorry_limit => ($*SORRY_LIMIT // 10));
        }

        if +@*SORROWS || $panic.defined {
            $ghost.throw;
        } else {
            note $ghost.gist;
        }
    }
}