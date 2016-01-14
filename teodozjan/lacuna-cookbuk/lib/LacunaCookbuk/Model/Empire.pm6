use v6;
use PerlStore::FileStore;
use JSON::RPC::Client;
use MONKEY-SEE-NO-EVAL;

#| Data provided by this class are required by anything in this  game 
unit class LacunaCookbuk::Model::Empire;

constant $EMPIRE = '/empire';
my %status;
my Int $counter=0;
constant $counter_limit=50;
my $session_id;

#| Lacuna expanse has 60 requests per minute limit
#| this option is much more optimal than sleep every second
#| lets leave margin to don't get exception
method start_rpc_keeper {
    $*SCHEDULER.cue: {$counter=$counter_limit}, :every(60);
}

sub lacuna_url(Str $url){
    'http://us1.lacunaexpanse.com'~ $url
}

sub rpc(Str $name --> JSON::RPC::Client) is export {
    sleep 1 until $counter; 
    --$counter;
    rpc_client($name)
}

#| we cannot use cached because of some bug
my %cache;
sub rpc_client($name --> JSON::RPC::Client) {
        return %cache{$name} if %cache{$name};
        %cache{$name} = JSON::RPC::Client.new( url => lacuna_url($name));

}

submethod create_session {
    my %login = find_credentials;
    my %logged = %(rpc($EMPIRE).login(|%login));
    %status = %(%logged<status>);
    $session_id = %logged<session_id>
}

submethod close_session {
    rpc($EMPIRE).logout($session_id);
    $session_id=Str;
}

submethod planet_name($planet_id --> Str)  {
    %status<empire><planets>{$planet_id};
}

submethod home_planet_id {
    %status<empire><home_planet_id>;
}

submethod planets_hash {
    %status<empire><planets>;
}

sub find_credentials returns Hash {
    my %login = %( );
    mkdir('.lacuna_cookbuk') unless '.lacuna_cookbuk'.IO ~~ :e;
    my $path = make_path('login.pl');
    my $file;
    try $file = slurp $path;
    

    if $! {
	%login = 
	    :api_key('07a052e0-d92b-49bb-ad38-cc1e433eb869'),
		:Empire('password');
		to_file($path, %login);
		die "Must fill your data in $path, data were pregenerated for you"
	    } 

	    %login = %(EVAL $file);
    

    return %login;
    
}

#| Need testing
submethod api_key(Str $key) {
...
#    %login<api_key> = $key;
}

#| Need testing
submethod credentials(Pair $user_password){ 
...
#    %login{$user_password.key} = $user_password.value;
}


sub session_id is export {
    $session_id;
}

#| There is module homedir for that but... I'm too lazy
sub make_path(Str $anyth) is export {    
    IO::Path.new(return %*ENV<HOME> ~ '/.lacuna_cookbuk/' ~ $anyth)
}
