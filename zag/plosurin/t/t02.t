#!/usr/bin/env perl6
use v6;
use Test;
use Plosurin;

my $txt= '{namespace rname.sample}
/**
  * Comment line
  * @param? par1 Some comment
  * @param par2 Some comment
*/
{template .Hello}
 <div>Test</div>
{/template}

/**
  * Comment2
  * @param 12 1244
  * @param Rrt 1244
*/
{template .Hello1}
 <div>Test2</div>
{/template}

/**
  * Coksd
*/
{template .Hello3}
 <div>Test3</div>
{/template}
';

my $res = Plosurin::Grammar.parse($txt, :actions(Plosurin::Actions.new ));
ok $res, 'grammar';
is_deeply [$/.ast.values».WHAT».perl], ["Template", "Template", "Template"], 'objects';

