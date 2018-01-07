use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Config;
use Magento::Cms;
use TestLogin;

my %config = TestLogin::admin_config;
my $block_content;

subtest {

    # POST   /V1/cmsBlock
    my $identifier = 'delete-me-' ~ now.Int;

    # This leaves residule URL Rewrites (Marketing > URL Rewrites)
    my %t1_data = %{
        block => %{
            identifier => $identifier,
            title      => 'Delete Me Block',
            content    => '<h1>Delete Me Block</h1>'
        }
    }

    my $t1_results =
        cms-block 
            %config,
            data => %t1_data;
    my $block_id = $t1_results<id>.Int;
    is $t1_results<title>, 'Delete Me Block', 'cms block new';

    # GET    /V1/cmsBlock/:blockId
    my $t2_results =
        cms-block 
            %config,
            block_id => $block_id;
    is $t2_results<title>, 'Delete Me Block', 'cms block by id';

    # PUT    /V1/cmsBlock/:id
    my $t3_results =
        cms-block 
            %config,
            block_id   => $block_id,
            data => %t1_data;
    is $t3_results<title>, 'Delete Me Block', 'cms block update';

    # GET    /V1/cmsBlock/search
    my %t4_search_criteria = %{
        searchCriteria => %{ 
            pageSize => 50
        }
    }

    my $t4_results = cms-block-search %config, search_criteria => %t4_search_criteria;
    $block_content = $t1_results<items>.grep({ $_<identifier> ~~ 'new-block' }).head<content>;
    is so $t4_results<items>.head<content> ~~ / 'Delete Me Block' /, True, 'cms block-search all';

    # DELETE /V1/cmsBlock/:blockId
    my $t5_results =
        cms-block-delete 
            %config,
            block_id => $block_id;
    is $t5_results, True, 'cms block delete';

}, 'Cms block';

subtest {

    my $identifier = 'delete-me-' ~ now.Int;

    # This leaves residule URL Rewrites (Marketing > URL Rewrites)
    # POST   /V1/cmsPage
    my %t1_data = %{
        page => %{
            identifier => $identifier,
            title      => 'Delete Me Page',
            content    => '<h1>Delete Me Page</h1>'
        }
    }

    my $t1_results =
        cms-page 
            %config,
            data => %t1_data;
    is $t1_results<title>, 'Delete Me Page', 'cms page new';
    my $page_id = $t1_results<id>.Int;

    # GET    /V1/cmsPage/:pageId
    my $t2_results =
        cms-page 
            %config,
            page_id => $page_id;
    is $t2_results<title>, 'Delete Me Page', 'cms page by page id';

    # PUT    /V1/cmsPage/:id
    my $t3_results =
        cms-page 
            %config,
            page_id => $page_id,
            data => %t1_data;
    is $t3_results<title>, 'Delete Me Page', 'cms page update';

    # DELETE /V1/cmsPage/:pageId
    my $t4_results =
        cms-page-delete 
            %config,
            page_id => $page_id;
    is $t4_results, True, 'cms page delete';

}, 'Cms page';

subtest {

    # GET    /V1/cmsPage/search
    my %t1_search_criteria = %{
        searchCriteria => %{ 
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'is_active',
                            value => 'true',
                            condition_type => 'eq'
                        },
                    ]
                },
            ],
        }
    }

    my $t1_results = cms-page-search %config;
    is $t1_results<items> ~~ Array, True, 'cms page-search all';

}, 'Cms page-search';

done-testing;
