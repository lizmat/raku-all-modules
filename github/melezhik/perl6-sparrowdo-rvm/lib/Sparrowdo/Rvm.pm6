use v6;

unit module Sparrowdo::Rvm;

use Sparrowdo;

use Sparrowdo::Core::DSL::Bash;

use Sparrowdo::Core::DSL::Package;

our sub tasks (%args) {

    package-install 'gnupg2';

    my $ruby-version = %args<version> || '2.1.0';

    bash "test -f /tmp/sparrow-cache/gpg-import.ok || curl -ksSL https://rvm.io/mpapis.asc | gpg2 --import - && touch /tmp/sparrow-cache/gpg-import.ok";

    bash "test -f /etc/profile.d/rvm.sh || curl -L get.rvm.io | bash -s stable";

    bash "source /etc/profile.d/rvm.sh && rvm reload && rvm install $ruby-version --default";

}

