use HTTP::UserAgent;
use JSON::Tiny;
use JSON::Marshal;
use JSON::Unmarshal;
use Discord::Api_ref;
use Discord::Channel;
use Discord::User;
use Discord::Guild;
use Discord::Message;

module Discord {

class Discord::Client is export {
    has 		$!auth-token;
    has HTTP::UserAgent $!ua = HTTP::UserAgent.new(useragent => "Perl6 UA", :debug($*ERR));
    has			$!base-url = "https://discordapp.com/api/";
    has	Discord::User	$.me;

    
    method	request(Str $type, Str $url, %data?) {
      my $request;
      if $type eq 'post' {
         $request = HTTP::Request.new(:post($!base-url~$url));
         $request.content = to-json(%data).encode;
         $request.header.field(Content-length => $request.content.bytes)
      }
      if $type eq 'get' {
         $request = HTTP::Request.new(:get($!base-url~$url));
      }
      $request.field(User-Agent => $!ua.useragent);
      $request.header.field(Content-Type => "application/json");
      $request.header.field(authorization => $!auth-token) if $!auth-token;
      my $rep = $!ua.request($request);
      if ! $rep.is-success {
	die "Can't perform request : "~ $rep.status-line;
      }
      return $rep;
      
    }
    method	get(Str $url) {
      self.request('get', $url);
    }
    
    
    
    method	post(Str $url, *%data) {
      self.request('post', $url, %data);
    }
    
    method	login(Str $mail, Str $password) returns Bool {
      my $rep = self.post(%api-url<login>, email => $mail, password => $password);
      my %d = from-json($rep.content);
      $!auth-token = %d<token>;
      $!me = Discord::User.new(:id('@me'));
      self.info-user($!me);
      return True,
    }
    
    method	logout() {
      self.post(%api-url<logout>, token => $!auth-token);
    }
    
    method info-user(Discord::User $user is rw) {
      my $rep = self.get(sprintf(%api-url<user>, $user.id));
      $user = unmarshal($rep.content, Discord::User);
      my $id = $user eq $!me ?? '@me' !! $user.id;
      $rep = self.get(sprintf(%api-url<user-guilds>, $id));
      my @g = from-json($rep.content);
      say @g.elems;
      for @g[0][0] -> %g {
        say to-json(%g);
	my $gd = unmarshal(to-json(%g), Discord::Guild);
	$user.hguilds{%g<name>} = $gd;
	$user.guilds.push($gd);
	self.guild-channels($gd);
      }
      $rep = self.get(sprintf(%api-url<user-channels>, $user.id));
      my $pcdata = from-json($rep.content);
      $user.text-channels = ();
      for @($pcdata) -> %pc {
        my $chan = unmarshal(to-json(%pc), Discord::TextChannel);
        $user.text-channels.push($chan);
        $user.private-channels{$chan.recipient.name} = $chan;
      }
    }
    
    method send-message(Discord::TextChannel $chan, $message) {
      self.post(sprintf(%api-url<channel-messages>, $chan.id), content => $message);
    }

    method guild-info(Discord::Guild $guild) {
      self.get(sprintf(%api-url<guild>, $guild.id));
    }
    
    method guild-channels(Discord::Guild $guild is rw) {
      my $rep = self.get(sprintf(%api-url<guild-channels>, $guild.id));
      my $data = from-json($rep.content);
      $guild.text-channels = ();
      $guild.voice-channels = ();
      for @($data) -> %channel {
        my $cd;
        $cd = unmarshal(to-json(%channel), Discord::TextChannel) if %channel<type> eq "text";
        $cd = unmarshal(to-json(%channel), Discord::VoiceChannel) if %channel<type> eq "voice";
	if %channel<type> eq "text" {
	  $guild.text-channels.push($cd);
	  $guild.htext-channels{%channel<name>} = $cd;
	}
	if %channel<type> eq "voice" {
	  $guild.voice-channels.push($cd);
	  $guild.hvoice-channels{%channel<name>} = $cd;
	}
	
      }
    }
    
    method get-messages(Discord::TextChannel $channel, :$after, :$before, :$limit) {
      my $url = sprintf(%api-url<channel-messages>, $channel.id);
      $url ~= '?' if $after or $before or $limit;
      $url ~= "&after="~$after if $after;
      $url ~= "&before="~$before if $before;
      $url ~= "&limit="~$limit if $limit;
      my $rep = self.get($url);
      my @messages;
      my $data = from-json($rep.content);
      for @($data) -> %message {
        my $m = unmarshal(to-json(%message), Discord::Message);
        @messages.push($m);
      }
      return @messages;
    }
}
}