use Text::TFIdf;
use Lingua::EN::Stopwords::Short;

my $doc-store = TFIdf.new(:trim(True), :stop-list(%stop-words));

$doc-store.add('perl is cool');
$doc-store.add('i like node');
$doc-store.add('java is okay');
$doc-store.add('perl and node are interesting meh about java');

sub results($id, $score) {
  say $id ~ " got " ~ $score;
}

$doc-store.tfids('node perl java', &results);

say $doc-store.tfids('node perl java');
