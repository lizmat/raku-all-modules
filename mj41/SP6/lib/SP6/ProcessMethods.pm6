module SP6::ProcessMethods;

multi sub esc(*@argv) is export {
	# todo
	return @argv.gist;
}
