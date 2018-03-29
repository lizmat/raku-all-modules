#! /usr/bin/env false

use v6.c;

use App::Assixt::Commands::Bump;
use App::Assixt::Commands::Dist;
use App::Assixt::Commands::Upload;
use App::Assixt::Config;
use Config;
use Dist::Helper::Meta;
use Dist::Helper::Path;
use Dist::Helper;

class App::Assixt::Commands::Push
{
	multi method run(
		Str:D $path,
		Config:D :$config,
	) {
		chdir $path;

		App::Assixt::Commands::Bump.run(:$config) unless $config<runtime><no-bump>;
		my Str $dist = App::Assixt::Commands::Dist.run(:$config);
		App::Assixt::Commands::Upload.run($dist, :$config);
	}

	multi method run(
		Config:D :$config,
	) {
		self.run(
			".",
			:$config,
		)
	}

	multi method run(
		Str @paths,
		Config:D :$config,
	) {
		for @paths -> $path {
			self.run(
				$path,
				:$config,
			)
		}
	}
}
