use License::Software::Holder;
use License::Software::Year;
unit role License::Software::Abstract;

has Str $.works-name = 'This program';
has  @.holders = Array.new;

multi method new(Str:D $name,
                 License::Software::Year $year = DateTime.new(time).year) {
    my @holders = [License::Software::Holder.new: $name, $year];
    self.bless(:@holders);
}

multi method new(Str:D $works-name, %h) {
    my @holders = %h.pairs.map: {
        License::Software::Holder.new: :name(.key), :year(.value)
    };
    self.bless(:$works-name, :@holders);
}

multi method new(%h) {
    my @holders = %h.pairs.map: {
        License::Software::Holder.new: :name(.key), :year(.value)
    };
    self.bless(:@holders);
}

multi method copyright-note returns Str
{
    die "No @.holders set" if @.holders ~~ Empty;
    return join "\n", ($.copyright «~» @.holders».name);
}

multi method copyright-note(License::Software::Holder $holder) returns Str {
    my Str $copyright = $.copyright;
    my $year;
    given $holder.year {
        when Dateish { $year = self.dateish-to-str($_) }
        when Range { $year = self.range-to-str($_) }
        default { $year = $_ }
    }

    $copyright ~= ' ' ~ $year ~ " " ~ $holder.name;
    return $copyright.join('');
}

multi method copyright-note(Str $holder) returns Str {
    return self.copyright-note(License::Software::Holder.new($holder))
}

method range-to-str(Range $range) returns Str:D { $range.gist.trans('.' => '-', :squash) }

method dateish-to-str(Dateish $date) returns Str:D { $date.year.Str }

submethod aliases returns Array[Str]  { … }
method files returns Hash:D { … }
method header returns Str:D  { … }
method full-text returns Str:D  { … }
method name returns Str:D { … }
method note returns Str:D  { … }
method short-name returns Str:D  { … }
submethod url returns Str:D  { … }
method copyright returns Str:D { "Copyright © " }
