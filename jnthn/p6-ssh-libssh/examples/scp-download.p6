use SSH::LibSSH;

sub MAIN($host, $user, $remote, $local, Int :$port, Str :$password) {
    my $session = await SSH::LibSSH.connect(:$host, :$user, :$port, :$password);
    await $session.scp-download($remote, $local);
    $session.close;
}
