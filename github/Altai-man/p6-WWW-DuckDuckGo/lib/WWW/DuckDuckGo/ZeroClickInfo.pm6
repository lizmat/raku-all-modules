use v6;

unit class WWW::DuckDuckGo::ZeroClickInfo;

use WWW::DuckDuckGo::Link;
use URI;

has $.result;
has $.json;
has $.abstract;
has $.abstract-text;
has $.abstract-source;
has $.abstract-url;
has $.image;
has $.heading;
has $.answer;
has $.answer-type;
has $.definition;
has $.definition-source;
has $.definition-url;
has $.html;
has $.redirect;
has $.related-topics-sections;
has $.results;
has $.type;
has %.type-long-definitions = ( A => 'article',
				D => 'disambiguation',
				C => 'category',
				N => 'name',
				E => 'exclusive' );

method new($result) {
    my $params;
    if ($result<RelatedTopics>) {
	$params<related-topics-sections> = {};
        if ($result<RelatedTopics>[0]<Topics>.defined) {
	    for @($result<RelatedTopics>) {
                die "Please, go to the module issues page and fill and issue with your searchterm" if $_<Name> eq '_';
                my @topics;
		for @($_<Topics>) -> $topic {
		    @topics.push(WWW::DuckDuckGo::Link.new($topic)) if $topic.WHAT.perl eq 'Hash';
		}
		$params<related-topics-sections>{$_<Name>} := @topics;
	    }
	} else {
	    my @topics;
	    for (@($result<RelatedTopics>)) -> $topic {
                @topics.push(WWW::DuckDuckGo::Link.new($topic)) if $topic.WHAT.perl eq 'Hash';
            }
	    $params<related-topics-sections> := @topics if so @topics;
	}
    }
    my @results;
    for (@($result<Results>)) {
	@results.push(WWW::DuckDuckGo::Link.new($_)) if $_.WHAT.perl eq 'Hash';
    }
    $params<json> = $result;
    $params<results> := @results if so @results;
    $params<abstract> = $result<Abstract>;
    $params<abstract-text> = $result<AbstractText>;
    $params<abstract-source> = $result<AbstractSource>;
    $params<abstract-url> = $result<AbstractURL>;
    $params<image> = URI.new($result<Image>);
    $params<heading> = $result<Heading>;
    $params<answer> = $result<Answer>;
    $params<answer-type> = $result<AnswerType>;
    $params<definition> = $result<Definition>;
    $params<definition-source> = $result<DefinitionSource>;
    $params<definition-url> = $result<DefinitionURL>;
    $params<type> = $result<Type>;
    $params<html> = $result<HTML> if so $result<HTML>;
    $params<redirect> = $result<Redirect>;
    self.bless(|$params);
}

method default-related-topics() {
    self.related-topics-sections;
}

method has-default-related-topics() {
    so self.related-topics-sections ?? 1 !! 0;
}

method type-long() {
    return if !$!type;
    %!type-long-definitions{$!type};
}
