#!/usr/bin/env perl6

use lib 'lib';

use Test;
use Flower::TAL;

plan 10;

my $xml = '<?xml version="1.0"?>';

my %date = {
  'date'     => Date.new(2010,10,9),
  'datetime' => DateTime.new(
    :year(2010), :month(10), :day(11), 
    :hour(13), :minute(17), :second(14),
    :timezone('16200') # +0430
  ),
  'year'  => 2010,
  'month' => 10,
  'day'   => 10,
};

my $tal = Flower::TAL.new();

$tal.add-tales('Date');

## test 1

my $template = '<date tal:content="dateof: 2010 10 10"/>';

is ~$tal.parse($template), $xml~'<date>2010-10-10T00:00:00Z</date>', 'dateof: modifier';

## test 2

$template = '<date tal:content="dateof: ${date/year} ${date/month} ${date/day}"/>';

is ~$tal.parse($template, :date(%date)), $xml~'<date>2010-10-10T00:00:00Z</date>', 'dateof: modifier using string parsing';

## test 3

$template = '<date tal:content="time: \'1286666133\'"/>';

is ~$tal.parse($template), $xml~'<date>2010-10-09T23:15:33Z</date>', 'time: modifier';

## test 4

$template = '<date tal:content="strftime: \'%Y_%m_%d-%T\' date/datetime"/>';

is ~$tal.parse($template, :date(%date)), $xml~'<date>2010_10_11-13:17:14</date>', 'strftime: modifier on a datetime object';

## test 5

$template = '<date tal:content="strftime: \'%b %d, %Y\' date/date"/>';

is ~$tal.parse($template, :date(%date)), $xml~'<date>Oct 09, 2010</date>', 'strftime: modifier on a date object';

## test 6

$template = "<date tal:content=\"strftime: rfc: \{\{dateof: 2010 10 10 :tz('-0800')}}\"/>";

is ~$tal.parse($template), $xml~'<date>Sun, 10 Oct 2010 00:00:00 -0800</date>', 'strftime: with rfc: modifier';

## test 7

$template = '<date tal:content="strftime: \'%Y-%m-%d\' now:"/>';
my $now = Date.today();

is $tal.parse($template), $xml~'<date>'~$now~'</date>', 'strftime: with now: modifier';

## test 8

$template = '<date tal:content="date: \'2011-01-12T15:15:00-0800\'"/>';

is $tal.parse($template, :date(%date)), $xml~'<date>2011-01-12T15:15:00-0800</date>', 'date: modifier';

## test 9
$template = '<date tal:content="strftime: \'%b %d, %Y\' {{date: \'2011-01-12T15:15:00-0800\'}}"/>';

is $tal.parse($template, :date(%date)), $xml~'<date>Jan 12, 2011</date>', 'strftime: with date: modifier';

## test 10

$template = '<date tal:content="strftime: \'%b %d, %Y\' \'2011-01-12T15:15:00-0800\'"/>';

is $tal.parse($template, :date(%date)), $xml~'<date>Jan 12, 2011</date>', 'strftime: with iso date string';


