#!/usr/bin/env perl6

use v6;

use Test;
use lib 'lib';
use Magento::Utils;

plan 1;

subtest {
    plan 2;
    my %t1_search_criteria = %{
        searchCriteria => %{ 
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'email',
                            value => 'user@6mag.test',
                            condition_type =>  'eq'
                        },
                    ]
                },
            ],
            current_page => 1,
            page_size    => 10
        }
    }
    my $t1_expected = 'searchCriteria[filterGroups][0][filters][0][field]=email&searchCriteria[filterGroups][0][filters][0][value]=user@6mag.test&searchCriteria[filterGroups][0][filters][0][condition_type]=eq&searchCriteria[current_page]=1&searchCriteria[page_size]=10';
    is search-criteria-to-query-string(%t1_search_criteria), $t1_expected, 'single filterGroup / filter to query string';

    my %t2_search_criteria = %{
        searchCriteria => %{
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'color',
                            value => 'Yello',
                            condition_type =>  'eq'
                        },
                        {
                            field => 'color',
                            value => 'Red',
                            condition_type =>  'eq'
                        }
                    ]
                },
                {
                    filters => [
                        {
                            field => 'created_at',
                            value => '2017-09-06',
                            condition_type =>  'gt'
                        },
                    ]
                }
            ],
            current_page => 1,
            page_size    => 10
        }
    }

    my $t2_expected = 'searchCriteria[filterGroups][0][filters][0][field]=color&searchCriteria[filterGroups][0][filters][0][value]=Yello&searchCriteria[filterGroups][0][filters][0][condition_type]=eq&searchCriteria[filterGroups][0][filters][1][field]=color&searchCriteria[filterGroups][0][filters][1][value]=Red&searchCriteria[filterGroups][0][filters][1][condition_type]=eq&searchCriteria[filterGroups][1][filters][0][field]=created_at&searchCriteria[filterGroups][1][filters][0][value]=2017-09-06&searchCriteria[filterGroups][1][filters][0][condition_type]=gt&searchCriteria[current_page]=1&searchCriteria[page_size]=10';
    is search-criteria-to-query-string(%t2_search_criteria), $t2_expected, 'multiple filterGroups / filters to query string';
}, 'Search critera';
