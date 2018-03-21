#! /usr/bin/env false

use v6.c;

use App::Assixt::Usage;
use Config;

unit module App::Assixt::Commands::Help;

multi sub assixt("help", Config:D :$config) is export
{
	USAGE
}

multi sub assixt("-h", Config:D :$config) is export
{
	USAGE
}

multi sub assixt(Config:D :$config where $config<runtime><help>) is export
{
	USAGE
}
