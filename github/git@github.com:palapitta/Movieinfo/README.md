# Movieinfo
Get Movie info from omdb

### Usage Example
```perl6
use Movieinfo;
my $m = Movieinfo.new();

$m.getinfo(" Dead Man","1995"); # year is optional
say $m.actors();
shell("wget -q $m.posterurl");

$m.getinfo("barton fink") # call getinfo again to get other movie info
my $w = $m.writer(); say $w;

# functions __________________________
$m.actors;
$m.director;
$m.awards;
$m.country;
$m.genre;
$m.language;
$m.metascore;
$m.rated;
$m.releasedate;
$m.runtime;
$m.title;
$m.type;
$m.writer;
$m.year;
$m.imdbrating;
$m.imdbvotes;
$m.posterurl;
