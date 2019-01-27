
use v6;

use HTTP::UserAgent;
use WebService::Discourse::ApiKey;
use WebService::Discourse::Backups;
use WebService::Discourse::Badges;
use WebService::Discourse::Categories;
use WebService::Discourse::Dashboard;
use WebService::Discourse::Email;
use WebService::Discourse::Groups;
use WebService::Discourse::Invite;
use WebService::Discourse::Notifications;
use WebService::Discourse::Posts;
use WebService::Discourse::PrivateMessages;
use WebService::Discourse::Search;
use WebService::Discourse::SiteSettings;
use WebService::Discourse::SSO;
use WebService::Discourse::Tags;
use WebService::Discourse::Topics;
use WebService::Discourse::Uploads;
use WebService::Discourse::UserActions;
use WebService::Discourse::Users;

unit class WebService::Discourse
    does WebService::Discourse::ApiKey
    does WebService::Discourse::Backups
    does WebService::Discourse::Badges
    does WebService::Discourse::Categories
    does WebService::Discourse::Dashboard
    does WebService::Discourse::Email
    does WebService::Discourse::Groups
    does WebService::Discourse::Invite
    does WebService::Discourse::Notifications
    does WebService::Discourse::Posts
    does WebService::Discourse::PrivateMessages
    does WebService::Discourse::Search
    does WebService::Discourse::SiteSettings
    does WebService::Discourse::SSO
    does WebService::Discourse::Tags
    does WebService::Discourse::Topics
    does WebService::Discourse::Uploads
    does WebService::Discourse::UserActions
    does WebService::Discourse::Users
    ;

has Str $.hostname is required;
has Str $.api-key is required;
has Str $.api-username is required;
