use License::Software::Year;

class License::Software::Holder {
    has Str $.name;
    has License::Software::Year $.year;

    multi method new(Str:D $name) { self.bless(:$name) }

    multi method new(Str:D $name, License::Software::Year $year) { 
        self.bless(:$name, :$year)
    }
}

