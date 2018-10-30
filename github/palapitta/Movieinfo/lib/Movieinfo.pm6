use JSON::Fast;
use Net::HTTP::GET;

class Movieinfo {

my $result;
my $x;

multi method getinfo($name) {
   my $n = $name;
   my $na = trim($n);
   $na ~~ tr/" "/"+"/;
  my $t = "http://www.omdbapi.com/?t=$na";
    $result = Net::HTTP::GET($t);
    $x = from-json $result.content;
}

multi method getinfo($name, $year) {
   my $n = $name;
   my $na = trim($n);
  $na ~~ tr/" "/"+"/;
  my $t = "http://www.omdbapi.com/?t=$na&y=$year";
    $result = Net::HTTP::GET($t);
    $x = from-json $result.content;
}

method actors() {
  $x<Actors>;
}

method awards() {
  $x<Awards>;
}

method country() {
  $x<Country>;
}

method director() {
  $x<Director>;
}

method genre() {
  $x<Genre>;
}

method language() {
  $x<Language>;
}

method metascore() {
  $x<Metascore>;
}

method plot() {
  $x<Plot>;
}

method posterurl() {
  $x<Poster>;
}

method rated() {
  $x<Rated>;
}

method releasedate() {
  $x<Released>;
}

method runtime() {
  $x<Runtime>;
}

method title() {
  $x<Title>;
}

method type() {
  $x<Type>;
}

method writer() {
  $x<Writer>;
}

method year() {
  $x<Year>;
}

method imdbrating() {
  $x<imdbRating>;
}

method imdbvotes() {
  $x<imdbVotes>;
}
}
