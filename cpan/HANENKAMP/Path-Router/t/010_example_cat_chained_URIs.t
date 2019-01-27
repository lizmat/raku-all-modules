#!/usr/bin/perl6

use v6;

use Test;
use Test::Path::Router;

use Path::Router;

=begin pod

This is an example of using Path::Router to match
the URIs from a Catalyst app we recently built at
$work which used the Chained dispatch type. It is
a test to see how things would translate between
the two.

Below is part of the Catalyst ASCII table which
shows all the paths and the actions they take.

Loaded Path Part actions:

=table
    Path Spec                           | Private
    ====================================+======================================
    /plan/*/confirm                     | /plan/load_plan_from_store (1)
                                        | -> /plan/end_transition (0)
                                        | => /plan/confirm
    ------------------------------------+--------------------------------------
    /plan/*/delete                      | /plan/load_plan_from_store (1)
                                        | => /plan/delete
    ------------------------------------+--------------------------------------
    /plan/*/edit                        | /plan/load_plan_from_store (1)
                                        | -> /plan/edit (0)
                                        | => /plan/edit_next
    ------------------------------------+--------------------------------------
    /plan/*/edit/engagement_framework   | /plan/load_plan_from_store (1)
                                        | -> /plan/edit (0)
                                        | => /plan/engagement_framework
    ------------------------------------+--------------------------------------
    /plan/*/edit/key_drivers            | /plan/load_plan_from_store (1)
                                        | -> /plan/edit (0)
                                        | => /plan/key_drivers
    ------------------------------------+--------------------------------------
    /plan/*/edit/priorities             | /plan/load_plan_from_store (1)
                                        | -> /plan/edit (0)
                                        | => /plan/priorities
    ------------------------------------+--------------------------------------
    /plan/*/submit                      | /plan/load_plan_from_store (1)
                                        | -> /plan/end_transition (0)
                                        | => /plan/submit
    ------------------------------------+--------------------------------------
    /plan/*/edit/title                  | /plan/load_plan_from_store (1)
                                        | -> /plan/edit (0)
                                        | => /plan/title
    ------------------------------------+--------------------------------------
    /plan/*/unsubmit                    | /plan/load_plan_from_store (1)
                                        | -> /plan/end_transition (0)
                                        | => /plan/unsubmit
    ------------------------------------+--------------------------------------
    /plan/*/view                        | /plan/load_plan_from_store (1)
                                        | => /plan/view

=end pod

my $router = Path::Router.new;
isa-ok($router, 'Path::Router');

$router.add-route(':controller');

$router.add-route('plan/:action' => %(
    defaults => {
        controller => 'plan',
    },
    validations => {
        action => /\D+/
    }
));

$router.add-route('plan/:id/edit/?:edit_action' => %(
    defaults => {
        controller  => 'plan',
        action      => 'edit',
        edit_action => 'edit_next'
    },
    validations => {
        id          => /\d+/,
        edit_action => /\D+/,
    }
));

$router.add-route('plan/:id/:action' => %(
    defaults => {
        controller => 'plan'
    },
    validations => {
        id     => /\d+/,
        action => /\D+/,
    }
));

routes-ok($router, {
    'index' => {
        controller => 'index'
    },
    'access_denied' => {
        controller => 'access_denied'
    },
    'plan' => {
        controller => 'plan'
    },
    # plan searching
    'plan/search' => {
        controller => 'plan',
        action     => 'search',
    },
    'plan/search_results' => {
        controller => 'plan',
        action     => 'search_results',
    },
    # plan viewing
    'plan/list' => {
        controller => 'plan',
        action     => 'list',
    },
    'plan/create' => {
        controller => 'plan',
        action     => 'create',
    },
    'plan/not_found' => {
        controller => 'plan',
        action     => 'not_found',
    },
    'plan/wrong_state' => {
        controller => 'plan',
        action     => 'wrong_state',
    },
    # with $id
    'plan/5/view' => {
        controller => 'plan',
        action     => 'view',
        id         => '5',
    },
    'plan/5/delete' => {
        controller => 'plan',
        action     => 'delete',
        id         => '5',
    },
    'plan/5/confirm' => {
        controller => 'plan',
        action     => 'confirm',
        id         => '5',
    },
    'plan/5/submit' => {
        controller => 'plan',
        action     => 'submit',
        id         => '5',
    },
    'plan/5/unsubmit' => {
        controller => 'plan',
        action     => 'unsubmit',
        id         => '5',
    },
    # editing
    'plan/5/edit' => {
        controller  => 'plan',
        action      => 'edit',
        id          => '5',
        edit_action => 'edit_next',
    },
    'plan/5/edit/title' => {
        controller  => 'plan',
        action      => 'edit',
        id          => '5',
        edit_action => 'title',
    },
    'plan/5/edit/engagement_framework' => {
        controller  => 'plan',
        action      => 'edit',
        id          => '5',
        edit_action => 'engagement_framework',
    },
    'plan/5/edit/key_drivers' => {
        controller  => 'plan',
        action      => 'edit',
        id          => '5',
        edit_action => 'key_drivers',
    },
    'plan/5/edit/priorities' => {
        controller  => 'plan',
        action      => 'edit',
        id          => '5',
        edit_action => 'priorities',
    },
},
"... our routes are solid");

path-not-ok($router, $_, '... ' ~ $_ ~ ' is not okay') for <
    /index/edit
    /access_denied/5/delete
    /access_denied/5/delete/foo

    /plan/5
    /plan/foo/5
    /plan/5/10
    /plan/5/edit/100
>;

done-testing;
