use v6;
use Lingua::EN::Stem::Porter;

=begin pod

=head1 NAME

Text::TFIdf

=head1 DESCRIPTION

Text::TFIdf assists in calulating TF-IDF vectors and scores for a collection of documents.

=head2 Examples

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

This example will print out a numbers that represent how similar the given document is to documents in the corpus.

=end pod

module Text::TFIdf {
  sub no-callback ($i, $j) {
    return;
  }
  class Document {
    has Str $.contents;
    has Bool $.trim = False;
    has %!words;
    has $!max = 0;
    has Bool $!built = False;

    method !build () {
      $!built = True;
      if ($.trim) {
        for $.contents.split(/\s+|'!'|'.'|'?'/, :skip-empty) -> $w {
          %!words{porter($w)}++;
          if (%!words > $!max) {
            $!max = %!words;
          }
        }
      } else {
        for $.contents.split(/\s+|'!'|'.'|'?'/, :skip-empty) -> $w {
          %!words{$w}++;
          if (%!words > $!max) {
            $!max = %!words;
          }
        }
      }
    }

    method has-word($word) {
      self!build() unless ($!built);

      my $w = ($.trim) ?? porter($word.lc) !! $word.lc;
      if (%!words{$w}:exists) {
        return 0.5 + (0.5 * (%!words{$w} / $!max));
      } else {
        return 0;
      }
    }
  }

  class TFIdf is export {
    has @!documents;
    has %!vocab;
    has %!idfs;
    has Bool $!built = False;
    has %.stop-list;
    has Bool $.trim = False;

    method !build() {
      $!built = True;
      my $docs = @!documents.elems;
      for %!vocab.keys() -> $key {
        my $denom = 1 + %!vocab{$key};
        %!idfs{$key} = 1 + log($docs / $denom);
      }
    }

    method add(Str $doc) is export {
      @!documents.push(Document.new(:contents($doc), :trim($.trim)));

      my %seen;
      $!built = False;

      for $doc.split(/\s+|'!'|'.'|'?'/, :skip-empty) -> $w {
        my $i = ($.trim) ?? porter($w.lc) !! $w.lc;
        unless ((%.stop-list{$w.lc}:exists) || (%seen{$i}:exists)) {
          %!vocab{$i}++;
          %seen{$i} = 1;
        }
      }
    }

    method tfidf(Str $doc, Int $id) is export {
      self!build() unless ($!built);

      if ($id < 0 || $id > @!documents.elems) {
        return 0;
      }

      my %seen;
      my $score = $doc.split(/\s+|'!'|'.'|'?'/, :skip-empty).map(-> $w {
        my $i = ($.trim) ?? porter($w.lc) !! $w.lc;
        unless ((%.stop-list{$w.lc}:exists) || (%seen{$i}:exists)) {
          %seen{$i} = 1;
          my $idf = %!idfs{$i}:exists ?? %!idfs{$i} !! 0;
          @!documents[$id].has-word($w) * $idf;
        }
      }).reduce(*+*);

      return $score;
    }

    method tfids(Str $doc, &callback = &no-callback)  is export {
      self!build() unless ($!built);

      my $docs = @!documents.elems - 1;
      my @tfids = [0..$docs].map(-> $doc-id {
        my $res = self.tfidf($doc, $doc-id);
        callback($doc-id, $res);
        $res
      });

      return @tfids;
    }
  }
}
