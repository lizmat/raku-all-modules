use JSON::Name;

use Discord::Channel;
use Discord::User;

class Discord::GuildRole is export {
    has			$.name;
    has			$.id;
    has	Bool		$.managed;
    has Int		$.color;
    has	Bool		$.hoist;
    has	Int		$.position;
    has			$.permissions;
}

class Discord::GuildMember is export {
    has			$.guild-id is json-name('guild_id');
    has			$.joined-at is json-name('joined_at');
    has	Bool		$.deaf;
    has	Bool		$.mute;
    has	Discord::User	$.user;
    has			@.roles;
}
 
  
class Discord::Guild is export is rw {
    has			$.id;
    has			$.name;
    has			$.icon;
    has			$.region;
    has Int		$.afk-timeout is json-name('afk_timeout');
    has Int		$.afk-channel-id is json-name('afk_channel_id');
    has Int		$.embed-channel-id is json-name('embed_channel_id');
    has Bool		$.embed is json-name('embed_enabled');
    has			$.owner-id is json-name('owner_id');
    has Bool		$.large;
    has 		$.joined-at is json-name('joined_at');
    
    has	Discord::GuildRole	@.roles;
    has Discord::TextChannel	@.text-channels;
    has Discord::TextChannel	%.htext-channels;
    has Discord::VoiceChannel	@.voice-channels;
    has Discord::VoiceChannel	%.hvoice-channels;
    
    method	AT-KEY ($key) {
      my $self = self;
      Proxy.new(
      FETCH => method ()
      {
        $self.htext-channels{$key};
      },
      STORE => method ($val)
      {
        die "Can't store on Discord::Guild with AT-KEY ({} or <>)";
      }
      );
    }
}