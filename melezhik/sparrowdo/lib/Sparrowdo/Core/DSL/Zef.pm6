use v6;

unit module Sparrowdo::Core::DSL::Zef;

use Sparrowdo;

use Sparrowdo::Core::DSL::Bash;

multi sub zef ( $pkg, %args? ) is export { 

  my $zef-cmd = 'export PATH=/opt/rakudo/bin:$PATH && ';

  $zef-cmd ~= %args<cwd>:exists ?? 'cd ' ~ %args<cwd> ~ '&& zef' !! 'zef';

  $zef-cmd ~= ' --depsonly' if %args<depsonly>;
  $zef-cmd ~= ' --force' if %args<force>;

  $zef-cmd ~= " install $pkg";

  my %bash-args = Hash.new;

  %bash-args<description> = %args<description> ||  "zef install $pkg";
  %bash-args<debug>       = %args<debug> || 0;
  %bash-args<user>        = %args<user> if %args<user>;

  bash $zef-cmd, %bash-args;

}
