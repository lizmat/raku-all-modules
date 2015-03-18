class Data::ICal::Event;

has $.uid;
has $.dtstamp;
has $.organizer;
has $.dtstart-raw;
has $.dtend-raw;
has $.summary;
has $.status;
has $.method;
has $.sequence;
has $.description;

has $.root;

method Str {
    my $ret;

    $ret ~= "BEGIN:VEVENT\n";
    $ret ~= "UID:" ~ $.uid ~ "\n" if $.uid;
    $ret ~= "DTSTAMP:" ~ $.dtstamp ~ "\n" if $.dtstamp;
    if $.organizer {
        $ret ~= "ORGANIZER";
        $ret ~= ";CN=" ~ $.organizer<name> if $.organizer<name>;
        $ret ~= ":MAILTO:" ~ $.organizer<email> ~ "\n";
    }
    $ret ~= "DTSTART:" ~ $.dtstart-raw<value> ~ "\n" if $.dtstart-raw<value>;
    $ret ~= "DTEND:" ~ $.dtend-raw<value> ~ "\n" if $.dtend-raw<value>;
    $ret ~= "SUMMARY:" ~ $.summary ~ "\n" if $.summary;
    $ret ~= "STATUS:" ~ $.status ~ "\n" if $.status;
    $ret ~= "METHOD:" ~ $.method ~ "\n" if $.method;
    $ret ~= "SEQUENCE:" ~ $.sequence ~ "\n" if $.sequence;
    $ret ~= "DESCRIPTION:" ~ $.description ~ "\n" if $.description;
    $ret ~= "END:VEVENT\n";
}

method dtstart {
    my $dts = $.dtstart-raw<value>;
    $dts.substr-rw(13, 0) = ':';
    $dts.substr-rw(11, 0) = ':';
    $dts.substr-rw(6, 0) = '-';
    $dts.substr-rw(4, 0) = '-';
    my $dt = DateTime.new($dts);

    if $.dtstart-raw<tzid> {
        my $offset = $.root.timezones{$.dtstart-raw<tzid>}.offset-for-datetime($dt);

        $offset = $offset / 100 * 60 * 60; # convert to seconds of offset

        $dt = DateTime.new(:year($dt.year),
                           :month($dt.month),
                           :day($dt.day),
                           :hour($dt.hour),
                           :minute($dt.minute),
                           :second($dt.second),
                           :offset($offset));
    }

    $dt;
}

method dtend {
    my $dts = $.dtend-raw<value>;
    $dts.substr-rw(13, 0) = ':';
    $dts.substr-rw(11, 0) = ':';
    $dts.substr-rw(6, 0) = '-';
    $dts.substr-rw(4, 0) = '-';
    my $dt = DateTime.new($dts);

    if $.dtend-raw<tzid> {
        my $offset = $.root.timezones{$.dtend-raw<tzid>}.offset-for-datetime($dt);

        $offset = $offset / 100 * 60 * 60; # convert to seconds of offset

        $dt = DateTime.new(:year($dt.year),
                           :month($dt.month),
                           :day($dt.day),
                           :hour($dt.hour),
                           :minute($dt.minute),
                           :second($dt.second),
                           :offset($offset));
    }

    $dt;
}
