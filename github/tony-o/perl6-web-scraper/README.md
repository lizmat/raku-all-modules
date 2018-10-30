# Perl 6: Web::Scraper;

This module works very similar to Perl 5's Web::Scraper.  Right now it has some extra sugar in some areas. Currently works with parsing from XML and HTML (converts it to XHTML).

## Status:
### Working on:
Maintenance mode, enhancemenets, etc.

## Syntax:
### Data:
```xml
<data>
  <t id="1">test1</t>
  <t id="2">test2</t>
  <e>etest</e>
  <t id="3">test3</t>
  <t id="4">test4</t>
  <e>etest</e>
  <nest>
    <id>1</id>
    <val>50</val>
    <sval>1</sval>
    <sval>2</sval>
    <sval>3</sval>
    <sval>43</sval>
  </nest>
  <nest>
    <id>2</id>
    <val>30</val>
    <sval>2</sval>
    <sval>3</sval>
    <sval>5</sval>
    <sval>47</sval>
  </nest>
</data>
```

### Scraper:
```perl6
my $count   = 0;
my $scraper = scraper {
  process 't', 'tarray[]' => {
    name => 'TEXT',
    id   => '@id'
  };
  process 'e', 'e[]' => sub ($elem) {
    return "{$elem.contents[0].text ~ $count++}";
  };
  process 't', 'ttext[]' => 'TEXT';
  process 'nest', 'nested[]' => scraper {
    process 'id', 'id' => 'TEXT';
    process 'val', 'val' => 'TEXT';
    process 'sval', 'svals[]' => 'TEXT';
  };
}  
```

### Results:
```sh
$scraper.d = {
  tarray => [
    {id => 1, name => 'test1'},
    {id => 2, name => 'test2'},
    {id => 3, name => 'test3'},
    {id => 4, name => 'test4'},
  ],
  e => [
    'etest1',
    'etest2',
  ],
  ttext => [
    'test1',
    'test2',
    'test3',
    'test4',
  ],
  nested => [
    { id => 1, val => 50, sval => [1,2,3,43,], },
    { id => 2, val => 30, sval => [2,3,5,47,], },
  ],
};
```

## Example with a dynamic source file:
### Data:
#### master.xml:
```xml
<xml>
  <files>
    <file>one.xml</file>
    <file>two.xml</file>
  </files>
</xml>
```
#### one.xml
```xml
<xml>
  <id>1</id>
  <word>one</word>
</xml>
```
#### two.xml
```xml
<xml>
  <id>2</id>
  <word>two</word>
</xml>
```
### Syntax:
```perl6
my $dynamicscraper = scraper {
  process 'id', 'id' => 'TEXT';
  process 'word', 'alpha' => 'TEXT';
};
my $masterscraper = scraper {
  process 'files', 'files[]' => scraper {
    process 'file', 'src-file' => 'TEXT';
    resource $dynamicscraper, 'file' => 'TEXT';
  };
};
$masterscraper.scrape('master.xml');
```
### Results:
```sh
$masterscraper.d == {
  files => [
    { src-file => 'one.xml', id => '1', alpha => 'one', },
    { src-file => 'two.xml', id => '2', alpha => 'two', },
  ],
}
```
