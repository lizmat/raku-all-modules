use v6;

# External
use HTTP::Easy::PSGI;
use URI;
use File::Find;

use Totem::Util;

module Totem
{

=begin pod

Runs the Totem webserver at host:port. If host is empty
then it listens on all interfaces

=end pod

	our sub run(Str $host, Int $port)
	{

		# Trap Ctrl-C to properly execute END { } to enable
		# showing of deprecated messages
		#signal(SIGINT).tap({
		#	"Ctrl-C detected".say;
		#	die
		#});

		# Development or panda-installed?
		my $files-dir = 'lib/Totem/files';
		unless "$files-dir/assets/main.js".IO ~~ :e {
			say "Switching to panda-installed totem";
			my @dirs = $*SPEC.splitdir($*EXECUTABLE);
			$files-dir = $*SPEC.catdir(
				@dirs[0..*-3], 
				'languages', 'perl6', 'site', 'lib', 'Totem', 'files'
			);
		}

		# Make sure files contains main.js
		die "main.js is not found in {$files-dir}/assets" 
			unless $*SPEC.catdir($files-dir, 'assets', 'main.js').IO ~~ :e;

		say "Totem is serving files from {$files-dir} at http://$host:$port";
		my $app = sub (%env)
		{
			return [400,['Content-Type' => 'text/plain'],['']] if %env<REQUEST_METHOD> eq '';

			my Str $filename;
			my Str $uri = %env<REQUEST_URI>;

			# Remove the query string part
			$uri ~~ s/ '?' .* $ //;

			# Handle files and routes :)
			if $uri eq '/'
			{
				$filename = 'index.html';
			}
			elsif $uri eq '/search'
			{
				return search(Totem::Util::get-parameter(%env<psgi.input>.decode, 'pattern')); 
			}
			else 
			{
				$filename = $uri.substr(1);
			}

			# Get the real file from the local filesystem
			#TODO more robust and secure way of getting files. We could easily be attacked from here
			$filename = $*SPEC.catdir($files-dir, $filename);
			my Str $mime-type = Totem::Util::find-mime-type($filename);
			my Int $status;
			my $contents;
			if ($filename.IO ~~ :e)
			{
				$status = 200;
				$contents = $filename.IO.slurp(:enc('ASCII'));
			} 

			unless ($contents)
			{
				$status = 404;
				$mime-type = 'text/plain';
				$contents = "Not found $uri";	
			}

			[ 
				$status, 
				[ 'Content-Type' => $mime-type ], 
				[ $contents ] 
			];
		}


		build-module-index();

		my $server = HTTP::Easy::PSGI.new(:host($host), :port($port));
		$server.app($app);
		$server.run;
	}

	my @modules;

	sub build-module-index
	{
		"Building module index".say;

		my ($lib-dirs, $lib-dir) = Totem::Util::find-perl6-dir(['lib']);
		my ($site-lib-dirs, $site-lib-dir) = Totem::Util::find-perl6-dir(['site', 'lib']);
		

		my @results = gather for ($lib-dir, $site-lib-dir) -> $dir
		{
			my $files = find(
				:dir($dir),
				:name(/ '.pm' '6'? $/)
			);
			
			my $dir-array-length = ($dir eq $lib-dir) ?? +@$lib-dirs !! +@$site-lib-dirs;
			for @$files -> $file
			{
				my @dirs = $*SPEC.splitdir($file);

				# Take module name
				take @dirs[$dir-array-length..*].join("::").subst(/ '.pm' '6'? $/, '');
			}
		}
		
		@modules = @results.sort;
		"Found {+@modules} module(s)".say;
	}

	sub search(Str $pattern is copy)
	{
		# Trim the pattern and make sure we dont fail on undefined
		$pattern = $pattern // '';
		$pattern = $pattern.trim;

		# Start stopwatch
		my $t0 = now;

		constant $MAX_SIZE = 5;
		my $count = 0;
		my @results = gather for @modules -> $module
		{
			if $module ~~ m:i/"$pattern"/ {
				take $module;

				$count++;
				if $count >= $MAX_SIZE {
					last;
				}
			}
		}
		
		@results.say;

		# Stop stopwatch and calculate the duration
		my $duration = sprintf("%.3f", now - $t0);

		# PSGI response
		[
			200,
			[ 'Content-Type' => 'application/json' ],
			[
				to-json(
					%(
						'results'  => @results,
						'duration' => $duration,
					)
				)
			],
		];
	}
}

# vim: ft=perl6
