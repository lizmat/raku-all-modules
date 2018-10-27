use v6;

unit module DateTime::Format;

## Default list of Month names.
## Add more by loading DateTime::Format::Lang::* modules.
our $month-names = {
    en => <
        January
        February
        March
        April
        May
        June
        July
        August
        September
        October
        November
        December
    >
};

## Default list of Day names.
## Add more by loading DateTime::Format::Lang::* modules.
## ISO 8601 says that Monday is the first day of the week,
## which I think is wrong, but who am I to argue with ISO.
our $day-names = {
    en => <
        Monday
        Tuesday
        Wednesday
        Thursday
        Friday
        Saturday
        Sunday
    >
};

## The default language, change with set-datetime-format-lang().
our $datetime-format-lang = 'en';

## strftime, is exported by default.
multi sub strftime (
  Str $format is copy, 
  DateTime $dt=DateTime.now, 
  Str :$lang=$datetime-format-lang,
  Bool :$subseconds,
) is export {
    my %substitutions =
        # Standard substitutions for yyyy mm dd hh mm ss output.
        'Y' => { $dt.year.fmt(  '%04d') },
        'm' => { $dt.month.fmt( '%02d') },
        'd' => { $dt.day.fmt(   '%02d') },
        'H' => { $dt.hour.fmt(  '%02d') },
        'M' => { $dt.minute.fmt('%02d') },
        'S' => { $dt.whole-second.fmt('%02d') },
        # Special substitutions (Posix-only subset of DateTime or libc)
        'a' => { day-name($dt.day-of-week, $lang).substr(0,3) },
        'A' => { day-name($dt.day-of-week, $lang) },
        'b' => { month-name($dt.month, $lang).substr(0,3) },
        'B' => { month-name($dt.month, $lang) },
        'C' => { ($dt.year/100).fmt('%02d') },
        'e' => { $dt.day.fmt('%2d') },
        'F' => { $dt.year.fmt('%04d') ~ '-' ~ $dt.month.fmt(
                  '%02d') ~ '-' ~ $dt.day.fmt('%02d') },
        'I' => { (($dt.hour+23)%12+1).fmt('%02d') },
        'j' => { $dt.day-of-year.fmt('%03d') },
        'k' => { $dt.hour.fmt('%2d') },
        'l' => { (($dt.hour+23)%12+1).fmt('%2d') },
        'n' => { "\n" },
        'N' => { (($dt.second % 1)*1000000000).fmt('%09d') },
        'p' => { ($dt.hour < 12) ?? 'AM' !! 'PM' },
        'P' => { ($dt.hour < 12) ?? 'am' !! 'pm' },
        'r' => { (($dt.hour+23)%12+1).fmt('%02d') ~ ':' ~
                  $dt.minute.fmt('%02d') ~ ':' ~ $dt.whole-second.fmt('%02d')
                  ~ (($dt.hour < 12) ?? 'am' !! 'pm') },
        'R' => { $dt.hour.fmt('%02d') ~ ':' ~ $dt.minute.fmt('%02d') },
        's' => { $dt.posix.fmt('%d') },
        't' => { "\t" },
        'T' => { $dt.hour.fmt('%02d') ~ ':' ~ $dt.minute.fmt('%02d') ~ ':' ~ $dt.whole-second.fmt('%02d') },
        'u' => { ~ $dt.day-of-week.fmt('%d') },
        'w' => { ~ (($dt.day-of-week+6) % 7).fmt('%d') },
        'x' => { $dt.year.fmt('%04d') ~ '-' ~ $dt.month.fmt('%02d') ~ '-' ~ $dt.day.fmt('%2d') },
        'X' => { $dt.hour.fmt('%02d') ~ ':' ~ $dt.minute.fmt('%02d') ~ ':' ~ $dt.whole-second.fmt('%02d') },
        'y' => { ($dt.year % 100).fmt('%02d') },
        '%' => { '%' },
        '3N' => { (($dt.second % 1)*1000).fmt('%03d') },
        '6N' => { (($dt.second % 1)*1000000).fmt('%06d') },
        '9N' => { (($dt.second % 1)*1000000000).fmt('%09d') },
        'z' => {
            my $o = $dt.offset;
            $o
            ?? sprintf '%s%02d%02d',
               $o < 0 ?? '-' !! '+',
               ($o.abs / 60 / 60).floor,
               ($o.abs / 60 % 60).floor
            !! 'Z' 
        },
        'Z' => {
            my $o = $dt.offset;
            $o
            ?? sprintf '%s%02d%02d',
               $o < 0 ?? '-' !! '+',
               ($o.abs / 60 / 60).floor,
               ($o.abs / 60 % 60).floor
            !! '+0000' 
        },
    ; ## End of %substitutions

    $format .= subst( /'%'(\dN|\w|'%')/, -> $/ { (%substitutions{~$0}
            // die "Unknown format letter '$0'").() }, :global );
    return ~$format;
}

## Parse a string and return a DateTime, uses the same format strings
## as strftime().
## TODO: implement me.
sub strptime ($string, $format, :$lang=$datetime-format-lang) is export {
 !!!
}

## Returns the language-specific day name.
sub day-name ($i, $lang) is export(:ALL) {
    # ISO 8601 says Monday is the first day of the week.
    $day-names{$lang.lc}[$i - 1];
}

## Returns the language-specific month name name.
sub month-name ($i, $lang) is export(:ALL) {
    $month-names{$lang.lc}[$i - 1];
}

## Add month names.
sub add-datetime-format-month-names ($lang, @defs) is export(:ALL) {
    $month-names{$lang.lc} = @defs;
}

## Add day names.
sub add-datetime-format-day-names ($lang, @defs) is export(:ALL) {
    $day-names{$lang.lc} = @defs;
}

## Set the default language.
sub set-datetime-format-lang ($lang) is export {
    $datetime-format-lang = $lang.lc;
}

