use JSON::Name;

class Discord::User is export is rw {
    has			$.id;
    has			$.name is json-name('username');
    has			$.avatar is json-name('avatar');
    has			$.email;
    has	Bool		$.verified;
    
    has			@.guilds;
    has 		%.hguilds;
    has 	        @.text-channels;
    has                 %.private-channels;
    has 	        @.voice-channels;
    
    method	AT-KEY ($key) {
      my $self = self;
      Proxy.new(
      FETCH => method ()
      {
        $self.hguilds{$key};
      },
      STORE => method ($val)
      {
        die "Can't store on Discord::User with AT-KEY ({} or <>)";
      }
      );
    }
}