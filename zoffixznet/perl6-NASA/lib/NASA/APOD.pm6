use NASA::UA;
unit role NASA::APOD does NASA::UA;

my subset APODDate of Str
    where { m/^ \d**4 '-' \d**2 '-' \d**2 $/ or warn 'Date format is YYYY-MM-DD' };

multi method apod (APODDate $date, Bool :$hd = True) {
    self.apod: Date.new($date), :$hd;
}

multi method apod (Dateish $date?, Bool :$hd = True) {
    self!request: 'GET', 'https://api.nasa.gov/planetary/apod',
        |( date => ($date.year, $date.month, $date.day).join('-') if $date ),
        :$hd;
}

method Str {
    my $res = self.apod: |($*NASA-TESTING-TODAY // Empty);
    return "$res<title>: $res<hdurl>";
}

method gist {
    my $res = self.apod: |($*NASA-TESTING-TODAY // Empty);
    return "$res<title>: $res<url>";
}
