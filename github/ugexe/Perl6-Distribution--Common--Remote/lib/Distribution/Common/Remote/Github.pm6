use Distribution::IO::Remote::Github;
use Distribution::Common;

class Distribution::Common::Remote::Github {
    also does Distribution::IO::Remote::Github;
    also does Distribution::Common;

    has $.user;
    has $.repo;
    has $.branch;
    has $.api-key;

    method new(|c) { self.bless(|c) }
    submethod BUILD(:$!user, :$!repo, :$!branch = 'master', :$!api-key = %*ENV<GITHUB_ACCESS_TOKEN>) { }
}