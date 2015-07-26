# Term::ColorText --- As it says. Temporary only though.

use v6;

use Term::ANSIColor;

unit module Term::ColorText;

sub cfmt($color, *@things) {
    my @ar = color($color) X @things;
    @ar.push(color("reset"));
    return @ar;
}

sub HEADER(*@things) is export { [~] cfmt("black on_white", @things) }
sub DOING(*@things)  is export { [~] cfmt("yellow", @things, " ") }
sub CHK(*@things)    is export { [~] cfmt("green", @things ?? @things !! "✔") }
sub INFO(*@things)   is export { [~] cfmt("cyan", @things) }
sub VAL(*@things)    is export { [~] cfmt("bold magenta", @things) }

sub DONE(*@things)   is export { [~] cfmt("green", "\r\e[K", @things) }

sub TODO(*@things)   is export { [~] cfmt("white on_red", "XXX"), cfmt("red on_white", @things) }

sub DEBUG(*@things)  is export { note [~] cfmt("bold white on_yellow", @things) if $*YES_DEBUG }

sub FRAC($num, $den) is export {
    if $num > $den {
        return colored(~$num, "bold blue") ~ "/" ~ colored(~$den, "green");
    } elsif $num == $den {
        return colored(~$num, "green") ~ "/" ~ colored(~$den, "green");
    } elsif $num == 0 {
        return colored(~$num, "red") ~ "/" ~ colored(~$den, "green");
    } elsif $num < $den {
        return colored(~$num, "yellow") ~ "/" ~ colored(~$den, "green");
    } else {
        return colored("$num/$den (⚠)", "bold white on_red");
    }
}
