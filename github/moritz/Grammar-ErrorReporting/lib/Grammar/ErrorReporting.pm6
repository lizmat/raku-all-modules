use v6;
#`(
Copyright © Moritz Lenz moritz.lenz@gmail.com

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

class X::Grammar::ParseError is Exception {
    has $.description;
    has $.line;
    has $.msg;
    has $.target;
    has $.error-position;
    has $.context-string;
    has $.goal;

    method message() {
        qq:to/EOR/
            Cannot parse $.description: $.msg
            at line $.line, around $.context-string.perl()
            (error location indicated by ⏏)
            EOR
    }
}

role Grammar::ErrorReporting[Str :$description = 'input', Int :$context = 10] {
    method error($msg, :$goal) {
        my $parsed = self.target.substr(0, self.pos).trim-trailing;
        my $ctx = $parsed.substr($parsed.chars - $context max 0)
                      ~ '⏏' ~ self.target.substr($parsed.chars, $context);
        my $line = $parsed.lines.elems;
        X::Grammar::ParseError.new(
            :$description,
            :$line,
            :$msg,
            :$.target,
            :error-position($parsed.chars),
            :context-string($ctx),
            :$goal,
        ).throw;
    }

    method FAILGOAL($goal) {
        my $cleaned = $goal.trim;
        self.error("no closing $cleaned", goal => $cleaned);
    }
}


=begin pod

=head1 NAME

Grammar::ErrorReporting - A Role that facilitates error reporting in your grammar

=head1 SYNOPSIS

    use Grammar::ErrorReporting;
    grammar Number does Grammar::ErrorReporting {
        token TOP {
            \d+ || <.error('expected an unsigned integer')>
        }
    }
    Number.parse('not a number');

This produces output like this:

    Cannot parse input: expected an unsigned integer
    at line 0, around "⏏not a numb"
    (error location indicated by ⏏)


=head1 DESCRIPTION

Grammar::ErrorReporting is a parametric role that provides infrastructure
for reporting errors in grammars.

At the moment it provides an `error` method that you can call from a regex
as shown in the SYNOPSIS, and a `FAILGOAL` method that is triggered when
the match of the C<~> parser combinator fails, as in this example:

    grammar Parenthized does Grammar::ErrorReporting {
        token TOP { '(' ~ ')' \d+ }
    }
    Parenthized.parse('(123');


You can provide the following parameters to the role at application time:

=item C<description> (Str): a short description of what the grammar tries to parse. Default C<"input">.
=item C<context> (Int): the number of characters to show left and right of the error marker in the error message.

The exception that C<error> throws is of type C<X::Grammar::ParseError>.

=head1 AUTHOR

Moritz Lenz moritz.lenz@gmail.com 

=head1 COPYRIGHT AND LICENSE

Copyright © Moritz Lenz moritz.lenz@gmail.com

License GPLv3: The GNU General Public License, Version 3, 29 June 2007
<https://www.gnu.org/licenses/gpl-3.0.txt>

This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.


=end pod
