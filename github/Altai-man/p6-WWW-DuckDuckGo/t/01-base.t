use v6;

use Test;
use lib 'lib';

use WWW::DuckDuckGo;
use WWW::DuckDuckGo::ZeroClickInfo;
use WWW::DuckDuckGo::Link;
use WWW::DuckDuckGo::Icon;

my $icon = WWW::DuckDuckGo::Icon.new('URL' => 'http://i.duck.co/i/4bd98dc2.jpg');

isa-ok($icon, 'WWW::DuckDuckGo::Icon');
is($icon.url, 'http://i.duck.co/i/4bd98dc2.jpg', 'Checking for correct url in icon');
is($icon.width  ?? 1 !! 0, 0, 'Checking for non-existance of width');
is($icon.height ?? 1 !! 0, 0, 'Checking for non-existance of height');

my $link = WWW::DuckDuckGo::Link.new({'Result' => '<a href="http://duckduckgo.com/Gordon_Getty">Gordon Getty</a>, J. Paul Getty\'s son',
                                      'Icon' => {},
                                      'FirstURL' => 'http://duckduckgo.com/Gordon_Getty',
                                      'Text' => 'Gordon Getty, J. Paul Getty\'s son'});

isa-ok($link, 'WWW::DuckDuckGo::Link');
is($link.first_url, 'http://duckduckgo.com/Gordon_Getty', 'Checking for correct url in link');
is($link.has-icon   ?? 1 !! 0, 0, 'Checking for non-existance of icon');
is($link.result ?? 1 !! 0, 1, 'Checking for existance of result');
is($link.result, '<a href="http://duckduckgo.com/Gordon_Getty">Gordon Getty</a>, J. Paul Getty\'s son', 'Checking for correct result');
is($link.text   ?? 1 !! 0, 1, 'Checking for existance of text');
is($link.text, 'Gordon Getty, J. Paul Getty\'s son', 'Checking for correct text');

my $zci = WWW::DuckDuckGo::ZeroClickInfo.new({'Definition' => '',
                                              'Heading' => 'Duck Duck Go',
		                              'DefinitionSource' => '',
		                              'AbstractSource' => 'Wikipedia',
		                              'Image' => 'http://i.duck.co/i/37bc399d.png',
		                              'RelatedTopics' => [
			                                          {
				                                      'Result' => '<a href="http://duckduckgo.com/c/Internet_search_engines">Internet search engines</a>',
				                                      'Icon' => {},
				                                      'FirstURL' => 'http://duckduckgo.com/c/Internet_search_engines',
				                                      'Text' => 'Internet search engines'
			                                          }
		                                              ],
		                              'Abstract' => 'Duck Duck Go is a search engine based in Valley Forge, Pennsylvania that uses information from crowd-sourced sites with the aim of augmenting traditional results and improving relevance.',
		                              'AbstractText' => 'Duck Duck Go is a search engine based in Valley Forge, Pennsylvania that uses information from crowd-sourced sites with the aim of augmenting traditional results and improving relevance.',
		                              'Type' => 'A',
		                              'AnswerType' => '',
		                              'DefinitionURL' => '',
		                              'Results' => [
			                                    {
				                                'Result' => '<a href="http://duckduckgo.com/"><b>Official site</b></a><a href="http://duckduckgo.com/"></a>',
				                                'Icon' => {
					                            'URL' => 'http://i.duck.co/i/duckduckgo.com.ico',
					                            'Height' => 16,
					                            'Width' => 16
				                                },
				                                'FirstURL' => 'http://duckduckgo.com/',
				                                'Text' => 'Official site'
			                                    }
		                                        ],
		                              'Answer' => '',
		                              'AbstractURL' => 'http://en.wikipedia.org/wiki/Duck_Duck_Go',
		                              'HTML' => '<a href="test">test</a>'});

isa-ok($zci, 'WWW::DuckDuckGo::ZeroClickInfo');
is($zci.definition ?? 1 !! 0, 0, 'Checking for non-existance of definition');
is($zci.heading    ?? 1 !! 0, 1, 'Checking for existance of heading');
is($zci.heading, 'Duck Duck Go', 'Checking for correct heading');
is($zci.definition-source ?? 1 !! 0, 0, 'Checking for non-existance of definition source');
is($zci.abstract-source   ?? 1 !! 0, 1, 'Checking for existance of abstract source');
is($zci.abstract-source, 'Wikipedia', 'Checking for correct abstract source');
is($zci.image      ?? 1 !! 0, 1, 'Checking for existance of image');
isa-ok($zci.image, 'URI');
is($zci.image, 'http://i.duck.co/i/37bc399d.png', 'Checking for correct image url');
is($zci.abstract ?? 1 !! 0, 1, 'Checking for existance of abstract');
is($zci.abstract, 'Duck Duck Go is a search engine based in Valley Forge, Pennsylvania that uses information from crowd-sourced sites with the aim of augmenting traditional results and improving relevance.', 'Checking for correct abstract');
is($zci.abstract-text ?? 1 !! 0, 1, 'Checking for existance of abstract text');
is($zci.abstract-text, 'Duck Duck Go is a search engine based in Valley Forge, Pennsylvania that uses information from crowd-sourced sites with the aim of augmenting traditional results and improving relevance.', 'Checking for correct abstract text');
is($zci.type ?? 1 !! 0, 1, 'Checking for existance of type');
is($zci.type, 'A', 'Checking for correct type');
is($zci.type-long, 'article', 'Checking for correct type long');
is($zci.answer-type ?? 1 !! 0, 0, 'Checking for non-existance of answer type');
is($zci.definition-url ?? 1 !! 0, 0, 'Checking for non-existance of definition url');
is($zci.answer ?? 1 !! 0, 0, 'Checking for non-existance of answer');
is($zci.abstract-url ?? 1 !! 0, 1, 'Checking for existance of abstract url');
is($zci.html, '<a href="test">test</a>', 'Checking for correct html');
is($zci.html ?? 1 !! 0, 1, 'Checking for existance of html');

done-testing;
