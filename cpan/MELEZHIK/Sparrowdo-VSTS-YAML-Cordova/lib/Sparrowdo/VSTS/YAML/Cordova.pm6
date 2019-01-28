use v6;

unit module Sparrowdo::VSTS::YAML::Cordova:ver<0.0.17>;

use Sparrowdo;
use Sparrowdo::Core::DSL::Bash;
use Sparrowdo::Core::DSL::Template;
use Sparrowdo::Core::DSL::File;
use Sparrowdo::Core::DSL::Directory;

our sub tasks (%args) {

  my $os = %args<os> || 'windows';

  my $build-dir = %args<build-dir> || die "usage module_run '{ ::?MODULE.^name }' ,%(build-dir => dir)";

  directory "$build-dir/.cache";
  directory "$build-dir/files";

  my @list = <
    npm-install.cmd
    npm-install-ionic.cmd
    npm-install-cordova-set-version.cmd
    set-version.pl
    remove-old-packages.pl
    configure.pl
    gene-build-cmd.pl
    prepare.cmd
  >;


  for @list -> $i {
    file "$build-dir/files/$i", %( content => slurp %?RESOURCES{"windows/$i"}.Str );
  }

  template-create "$build-dir/files/build.cmd.tmpl", %(
    source => ( slurp %?RESOURCES<windows/build.cmd.tmpl> ),
    variables => %(
      base_dir => "$build-dir/files",
      VSINSTALLDIR => %args<vs-inst-dir> || 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional',
      MSBUILDDIR => %args<ms-build-dir> || 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin',
      MakePriExeFullPath =>  %args<make-pri-exe-full-path> || 'C:\Program Files (x86)\Windows Kits\10\bin\10.0.17134.0\x86\MakePri.exe'
    )
  );

  template-create "$build-dir/.cache/build.yaml.sample", %(
    source => ( slurp %?RESOURCES<windows/build.yaml> ),
    variables => %(
      build_arch => %args<build-arch> || "x86",
      build_configuration => %args<build-configuration> || "debug",
      base_dir => "$build-dir/files",
      prepare_only => %args<prepare-only>,
      remote_run => %args<remote-run>
    )
  );

  bash "cat $build-dir/.cache/build.yaml.sample >> $build-dir/build.yaml"

}


