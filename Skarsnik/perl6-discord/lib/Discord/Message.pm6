use Discord::Channel;
use Discord::User;
use JSON::Name;

class Discord::Message {
  has				$.id;
  has				$.timestamp;
  has	Bool			$.tts;
  has	Discord::User 		$.author;
  has				$.content;
  has				$.channel-id is json-name('channel_id');
  has	Bool			$.mention-everyone is json-name('mention_everyone');
  has	Discord::User		@.mentions;
  has	Discord::Channel	$.channel;
}