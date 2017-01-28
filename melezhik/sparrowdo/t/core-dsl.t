use v6;
use Test;

use Sparrowdo;
use Sparrowdo::Core::DSL::User;
use Sparrowdo::Core::DSL::Group;
use Sparrowdo::Core::DSL::File;
use Sparrowdo::Core::DSL::Directory;
use Sparrowdo::Core::DSL::Template;
use Sparrowdo::Core::DSL::Package;
use Sparrowdo::Core::DSL::CPAN::Package;
use Sparrowdo::Core::DSL::Service;
use Sparrowdo::Core::DSL::Bash;
use Sparrowdo::Core::DSL::Ssh;
use Sparrowdo::Core::DSL::User;

plan 1;

ok 1, 'Core DSL Modules are loaded';

