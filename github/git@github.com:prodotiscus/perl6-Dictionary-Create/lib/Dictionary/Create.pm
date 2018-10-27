=begin pod

=head1 

C<Dictionary::Create> is a module that allows you to create in different formats

=head1 Synopsis

    use Dictionary::Create;
    my $article = Dictionary::Create::DSL::Article.new;
    $article.set-title("foo");
    my $translation = $article.space( [
        $article.translation("bar"),
        $article.example("foo and bar is foobar")
    ] );
    $article.append_new($article.m-tag(1, $translation));
    say $article.give(); # get the article content

=end pod

unit module Dictionary::Create;

use Dictionary::Create::DSL;

# vim: ft=perl6
