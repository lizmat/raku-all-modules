use JSON::Name;
use Discord::User;

class Discord::PermissionOverwrite is export {
    has $.id;
    has $.type;
    has Int $.deny;
    has Int $.allow;
}

class Discord::Channel is export {
    has			$.id;
    has			$.name;
    has			$.topic;
    has	Bool		$.private is json-name('is_private');
    has Discord::User	$.recipient;
    has Int		$.position;
    has			$.type;
    has Int		$.last-message-id is json-name('last-message-id');
    has	Discord::PermissionOverwrite	@.permission-overwrites is json-name('permission_overwrites');
    has	Int		$.guild-id is json-name('guild_id');

}

class Discord::TextChannel is Discord::Channel is export {     
}
  
class Discord::VoiceChannel is Discord::Channel is export {
}

