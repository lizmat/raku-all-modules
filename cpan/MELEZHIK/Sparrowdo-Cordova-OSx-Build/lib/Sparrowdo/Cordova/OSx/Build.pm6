use v6;

unit module Sparrowdo::Cordova::OSx::Build:ver<0.0.7>;

use Sparrowdo;
use Sparrowdo::Core::DSL::Template;
use Sparrowdo::Core::DSL::Directory;
use Sparrowdo::Core::DSL::Bash;

our sub tasks (%args) {

    my $keychain-password = %args<keychain-password>;

    directory "www";
    
    bash "npm install --silent", %( description => "npm install" );
    
    bash "npm install --silent ios-deploy 1>/dev/null", %( description => "npm install ios-deploy" );

    unless %args<skip-pod-setup> {    
      bash "pod setup 1>/dev/null", %(
        envvars => %(
          LANG => "en_US.UTF-8"
        )
      );
    }

    bash "perl {%?RESOURCES<configure.pl>}", %(
      description => "perl configure.pl",
      debug => 1,
    );

    if (%args<rm-platform>) {
      bash "npm run --silent cordova -- platform rm ios", %( description => "cordova platform rm ios" );
      bash "npm run --silent cordova -- platform add ios", %( description => "cordova platform add ios" );
    } else {
      bash "npm run --silent cordova -- platform add ios; echo", %( description => "cordova platform add ios" );
    }

    bash "npm run --silent cordova -- prepare ios", %( description => "cordova prepare ios" );
    
    bash "npm run cordova -- requirements ios; echo", %( description => "cordova requirements ios" );
    
    bash "rm -rfv ./platforms/ios/build/device/*.ipa";

    if $keychain-password {
      bash "security unlock-keychain -p $keychain-password ~/Library/Keychains/login.keychain-db", %(
        description => "security unlock-keychain -p ****** ~/Library/Keychains/login.keychain-db"
      );
    }

    bash "defaults write com.apple.dt.Xcode DVTDeveloperAccountUseKeychainService -bool NO";

    if %args<manual-signing> {
      template-create "manual-signing.json", %(
        source => ( slurp %?RESOURCES<manual-signing.json> ),
        variables => %( 
          team      => %args<team-id>,
          profile   =>  %args<profile>,
        )
      );
      bash "npm run --silent cordova -- build ios --device --buildConfig=manual-signing.json", %(
        expect_stdout => 'EXPORT SUCCEEDED',
        debug => 1,
        description => "cordova build"
      );
    } else {
        bash "npm run --silent cordova -- build ios --device -- --buildFlag='DEVELOPMENT_TEAM={%args<team-id>}' --buildFlag='-allowProvisioningUpdates'", %(
          expect_stdout => 'EXPORT SUCCEEDED',
          debug => 1,
          description => "cordova build"
        );
    }

    bash "ls -l platforms/ios/build/device/*.ipa";
   
    bash "rm -rf binaries/ && mkdir binaries && cp platforms/ios/build/device/*.ipa binaries/", %(
          debug => 1,
          description => "copy binaries"
    );
}


