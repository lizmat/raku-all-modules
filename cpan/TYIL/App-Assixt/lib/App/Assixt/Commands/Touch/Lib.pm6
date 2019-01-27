#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use Config;
use Dist::Helper::Meta;
use Dist::Helper::Template;

class App::Assixt::Commands::Touch::Lib
{
	multi method run(
		"class",
		Str:D $provide,
		Config:D :$config,
	) {
		self.run(
			"lib",
			$provide,
			"class",
			:$config,
		)
	}

	multi method run(
		"unit",
		Str:D $provide,
		Config:D :$config,
	) {
		self.run(
			"lib",
			$provide,
			"unit",
			:$config,
		)
	}

	multi method run(
		"lib",
		Str:D $provide,
		Str $type = "lib",
		Config:D :$config,
	) {
		my %meta = get-meta;
		my $path = "./lib".IO;

		# Deduce the path to create
		for $provide.split("::") {
			$path = $path.add($_);
		}

		$path = $path.extension("pm6", parts => 0);

		if ($path.e) {
			die "File already exists at {$path.absolute}";
		}

		my $template = "module/";
		my %context = %(
			perl => %meta<perl>,
			vim => template("vim-line/$config<style><indent>", context => $config<style>).trim-trailing,
            author => %meta<authors>.join(", "),
            version => %meta<version>,
			:$provide,
		);

		given $type {
			when "class" { $template ~= "class" }
			when "unit"  { $template ~= "unit" }
			default      { $template ~= "lib" }
		}

		template($template, $path, :%context);

		# Update META6.json
		%meta<provides>{$provide} = $path.relative;

		put-meta(:%meta);

		# Inform the user of success
		say "Added $provide to {%meta<name>}";
	}
}
