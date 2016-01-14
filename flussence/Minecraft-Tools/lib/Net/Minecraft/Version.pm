unit module Net::Minecraft::Version:ver<2.0.0>;
#= Do stuff with Minecraft version numbers, possibly involving network IO

#| URL prefix for everything
our $URL = 'http://s3.amazonaws.com/Minecraft.Download/versions/';

#| URL suffix for server jar downloads
sub server-jar-for(Str $_ --> Str) is export {
    $URL ~ .fmt('%s/minecraft_server.%1$s.jar');
}

#| Reconstruct version numbers after feeding them to Version.new
sub stringify-version(Version $_ --> Str) is export {
    when .parts[1] eq 'w' # snapshot versions: collapse
        { .parts.join }
    default # everything else: keep the dots
        { .Str }
}

#| Grab versions.json from the server, parse and return it
sub get-versions(--> Hash) is export {
    use JSON::Fast;
    use Net::HTTP::GET;

    # AWS sends the JSON as application/octet-stream with no encoding, wonderful
    from-json(.body.decode) with Net::HTTP::GET($URL ~ 'versions.json');
}
