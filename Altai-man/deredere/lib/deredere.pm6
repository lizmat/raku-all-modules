use v6;

use HTTP::UserAgent;
use Gumbo;

unit module deredere;

# Scraper instances.
multi sub scrape(Str $url) is export {
    default-save-operator(get-page($url), $url);
    CATCH {
	default {
	    note "For $url: ", .message;
	}
    }
}

multi sub scrape(Str $url, &parser, Str :$filename="scraped-data.txt") is export {
    my $page = get-page($url);
    my $xml = parse-html($page.content);
    my @data = &parser($xml);
    default-save-operator(@data, $filename);
    CATCH {
	default {
	    note "For $url: ", .message;
	}
    }
}

multi sub scrape(Str $u, &parser, &operator, &next=&default-next, Int $gens=1, Int $delay=0) is export {
    my $page;
    my $xml;
    my $url = $u;
    for (1 .. $gens) {
	sleep $delay;
	$page = get-page($url);
	CATCH {
	    default {
		note "For $url: ", .message;
		note "Iteration is broken now. Bye.";
		note "Last url was: ", $url
	    }
	}
	$xml = parse-html($page.content);
	&operator(&parser($xml));
	$url = &next($xml);
    }
}

# Operators.
multi sub default-save-operator($res, $url) {
    my $name = split("/", $url)[*-1];
    # We need to somehow distinguish bad and good url ends...
    unless $name.ends-with(".html"|".htm"|".xhtml"|".jpg"|".png"|".jpeg") {
    	$name ~= ".html";
    }

    if $res.is-binary {
	spurt $name, $res.content, :bin;
    } else {
	spurt $name, $res.content;
    }
    note "$url is OK.";
}

multi sub default-save-operator(@data, Str $filename) {
    my @data-pull;
    # .race here is optional. I gained a small speed improvement by this
    # even on small(10-20 links) pulls, but testing with a wide bandwith
    # and many variants is still needed to decide is we really need .race here.
    @data.race.map( { if $_ ~~ /https?\:\/\// {
			    default-save-operator(get-page($_), $_);
			    CATCH {
				default {
				    note "For $_: ", .message;
				    .resume;
				}
			    }
			} else {
			  @data-pull.append($_);
		      }});
    if @data-pull.defined {
	my $fh = open $filename, :a;
	for @data-pull {
	    $fh.say($_);
	}
	$fh.close;
    }
}

# Utilites.
our sub get-page(Str $url, Int $timeout=10) {
    my $ua = HTTP::UserAgent.new(:useragent<chrome_linux>);
    $ua.timeout = $timeout;
    my $res = $ua.get($url);
    if !$res.is-success {
	warn $res.status-line;
    }
    $res;
}

our sub default-next($xml) {
    # If we are using default "next" operator,
    # it means that the caller wants to scrape only first "generation".
    # Because of that, we just assign empty line to url,
    # since it won't be used in the cycle.
    "";
}
