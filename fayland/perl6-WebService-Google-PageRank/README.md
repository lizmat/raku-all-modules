# perl6-WebService-Google-PageRank

[![Build Status](https://travis-ci.org/fayland/perl6-WebService-Google-PageRank.svg?branch=master)](https://travis-ci.org/fayland/perl6-WebService-Google-PageRank)

## SYNOPSIS

```
use WebService::Google::PageRank;

say get_pagerank('https://www.google.com/'); # "9"
```

## DESCRIPTION

 * it throws on HTTP error
 * it returns Any if the url does not have rank.