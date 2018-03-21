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

unit module App::Assixt::Commands::Push;

multi sub assixt(
	"push",
	Str:D $path,
	Config:D :$config,
) is export {
	chdir $path;

	assixt("bump", :$config) unless $config<runtime><no-bump>;
	my Str $dist = assixt("dist", :$config);
	assixt("upload", $dist, :$config);
}

multi sub assixt(
	"push",
	Config:D :$config,
) is export {
	assixt(
		"push",
		".",
		:$config,
	)
}

multi sub assixt(
	"push",
	Str @paths,
	Config:D :$config,
) is export {
	for @paths -> $path {
		assixt("push", $path, :$config)
	}
}
