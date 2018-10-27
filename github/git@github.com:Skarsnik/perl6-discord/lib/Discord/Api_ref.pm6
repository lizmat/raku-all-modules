module Discord::Api_ref {

constant %api-url is export = {	login => 'auth/login',
			logout => 'auth/logout',
			user => 'users/%s',
			guild => 'guilds/%s',
			guild-channels => 'guilds/%s/channels',
			channel => 'channels',
			user-channels => 'users/%s/channels',
			user-guilds => 'users/%s/guilds',
			channel-messages => 'channels/%s/messages'			
			};
}