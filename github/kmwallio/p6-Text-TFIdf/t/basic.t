use v6;
use Text::TFIdf;
use Test;

plan 4;

my $doc-store = TFIdf.new(:trim(True));

$doc-store.add('perl is cool');
$doc-store.add('i like node');
$doc-store.add('java is okay');
$doc-store.add('perl and node are interesting meh about java');

sub results($id, $score) {
  if ($id < 3) {
    ok $score < 1, "Docs with one matching term score 0";
  } else {
    ok $score > 1, "Doc with 3 matching terms score 1";
  }
}

$doc-store.tfids('node perl java', &results);

done-testing;
