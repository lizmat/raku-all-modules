
use v6;
use lib 'lib';
use WebService::Discourse;

# Create a new Discourse webservice client
my $discourse = WebService::Discourse.new(
    hostname     => 'http://try.discourse.org',
    api-key      => 'YOUR-API-KEY',
    api-username => 'YOUR-USERNAME'
);

# # Specify SSL connection settings if needed
# $discourse.ssl(...);

# Topic endpoints
# - Gets a list of the latest topics
say $discourse.latest-topics;
# - Gets a list of hot topics
say $discourse.hot-topics;
# - Gets a list of new topics
say $discourse.new-topics;
# - Gets a list of topics created by user 'sam'
#TODO say $discourse.topics-by('sam');

# - Gets the topic with id 57
say $discourse.topic(57);

# # Search endpoint
# # Gets a list of topics that match 'sandbox'
# my @results = $discourse.search('sandbox')
#
# # Categories endpoint
# # Gets a list of categories
# client.categories;
#
# # Gets a list of latest topics in a category
# client.category-latest-topics(category-slug: 'lounge');
#
# # SSO endpoint
# # Synchronizes the SSO record
# client.sync-sso(
#     sso-secret  => 'discourse-sso-rocks',
#     name        => 'Test Name',
#     username    => 'test-name',
#     email       => 'name@example.com',
#     external-id => '2'
# );
#
# # Private messages
#
# # - Gets a list of private messages received by 'test-user'
# $discourse.private-messages('test-user');
#
# # - Gets a list of private messages sent by 'test-user'
# $discourse.sent-private-messages('test-user');
#
# # - Creates a private messages by api-username user
# $discourse.create-private-message(
#     title('Confidential: Hello World!'),
#     raw('This is the raw markdown for my private message'),
#     target-usernames('user1,user2')
# )
