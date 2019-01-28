use ENIGMA::Machine::Error;
unit module ENIGMA::Machine::Keyfile is export;

sub get-daily-settings( 
    Str $key-sheet-content, 
    $day is copy = Nil,
) is export {

    my Bool $found = False;

    # get today's day if no day is supplied
    $day = DateTime.now.day unless $day;

    for $key-sheet-content.lines -> $row {

        # skip empty or commented lines
        next if $row.chars == 0 or $row.match(/\#/);

        # get all columns in row
        my @cols = $row.words;

        unless @cols.elems (<) (18, 20) {
            X::Error.new(
                source => @cols.elems,
                reason => 'Wrong number of columns',
                suggestion => 'Each row must have either 18 or 20 columns',
            );
        }

        my $r_num = @cols == 18 ?? 3 !! 4;

        my $day_sheet = @cols[0];
        unless $day_sheet ~~ / ^\d**1..2$ <?{ $/.Int <= 31 && $/.Int >= 1 }> / {
            X::Error.new(
                source => $day_sheet,
                reason => 'Wrong day number',
                suggestion => 'Day must be in the range 1-31',
            );
        }

        # keep looking until day is found in key sheet
        next unless $day == $day_sheet;

        my %settings = %(
            rotors            => @cols[1..$r_num].join(' '),
            ring-settings     => @cols[$r_num + 1..$r_num * 2].join(' '),
            plugboard-setting => @cols.tail(11).head(10).join(' '),
            reflector-setting => @cols.tail.join(' '),
        );

        $found = True;

        return %settings;
    }

    unless $found {
        X::Error.new(
            source => $day,
            reason => "No entry found for day",
            suggestion => "Provide setting for day $day in key sheet or use a different day",
        );

    }

}


=begin pod
=head1 ENIGMA::Machine::Keyfile

=head1 PREAMBLE

A key file is expected to be formatted as one line per day of the month. Each
line consists of a sequence of space separated columns as follows:

=item day number - the first column is the day number (1-31). The lines can be in any order.

=item rotor list - the next 3 or 4 columns should be rotor names.

=item ring settings - the next 3 or 4 columns should be ring settings. They can be in either alphabetic (A-Z) or numeric (0-25) formats.

=item plugboard settings - the next 10 columns should be plugboard settings. They can be in either alphabetic (AB CD EF ...) or numeric (1/2 3/4 ...) formats.

=item reflector - the last column must be the reflector name.

Comment lines have a # character in the first column. Blank lines are ignored.

Each line must either have exactly 18 or 20 columns to be valid.

=head1 SYNOPSIS

=begin code
use v6;
use ENIGMA::Machine::Keyfile;

my $file-content = 'data'.IO.slurp;

# Get setting for day 12 (if exists) in key sheet
my $s = get-daily-settings($file-content, 12);
=end code

=head1 DESCRIPTION

=begin item
C<get-daily-settings> can be used to read and parse a key
file for daily key settings.

=begin item
C<key-sheet> - a string representing (not a file handle) the entire key file.
=end item

=begin item
C<day> - specifies the day number to look for in the file (1-31). If day is
C<Nil>, the day number from today is used.
=end item

Returns a hash of keyword arguments that can be fed directly to
ENIGMA::Machine.from-key-sheet.
=end item
=end pod


