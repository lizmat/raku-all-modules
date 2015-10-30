use Test;
use WebServices::GitHub::Search;

my $search = WebServices::GitHub::Search.new;

# enable debug
use WebServices::GitHub::Role::Debug;
$search does WebServices::GitHub::Role::Debug;

my $data = $search.repositories({
    :q<perl6>,
    :sort<stars>,
    :order<desc>
}).data;
ok $data<total_count> > 500, 'total_count';
is $data<items>[0]<owner><login>, 'perl6', 'first repos login';

done-testing;