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
