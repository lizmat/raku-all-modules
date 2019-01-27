
use v6;

unit class Wkhtmltox::PDF;

use NativeCall;
use NativeHelpers::Blob;
use Wkhtmltox::Native;

has int32 $!gs;
has int32 $!os;
has Bool $!initialized;

submethod BUILD() {
	unless $!initialized {
		# Init wkhtmltopdf in graphics-less mode
		die "Init failed"
			if wkhtmltopdf_init(False) != 1;

		$!initialized = True;
	}

	# Create global / object settings
	$!gs = wkhtmltopdf_create_global_settings;
	$!os = wkhtmltopdf_create_object_settings;
}
method version {
	wkhtmltopdf_version
}

sub finished(int32 $converter, int32 $p) {
	printf("Finished: %d\n", $p);
}

sub progress-changed(int32 $converter, int $p) {
	printf("progress = %3d\n", $p);
}

sub phase-changed(int32 $converter) {
	my $phase = wkhtmltopdf_current_phase($converter);
	printf("Phase: %s\n", wkhtmltopdf_phase_description($converter, $phase));
}

sub error(int32 $converter, Str $msg) {
	printf("Error: %s\n", $msg);
}

sub warning(int32 $converter, Str $msg) {
	printf("Warning: %s\n", $msg);
}

method destroy {
	unless $!initialized {
		warn "Not initialized properly. Please call .new";
		return;
	}
	wkhtmltopdf_deinit;
}

method get-global-setting(Str $name) {
	constant BUFFER_SIZE = 1024;
	my $blob = Blob[uint8].allocate(BUFFER_SIZE);
	my $result = wkhtmltopdf_get_global_setting($!gs, $name, $blob, BUFFER_SIZE);
	die "Error while getting global setting '$name'" unless $result;
	$blob.decode('utf-8');
}

method set-global-setting(Str $name, Str $value) {
	wkhtmltopdf_set_global_setting($!gs, $name, $value);
}

#
# Returns if successful a generated pdf byte blob from the given HTML string
#
method render(Str $html) returns Blob {

	# Create convertor and object settings & HTML to it
	my $converter = wkhtmltopdf_create_converter($!gs);
	wkhtmltopdf_add_object($converter, $!os, $html);

	# Setup callbacks
	wkhtmltopdf_set_finished_callback($converter, &finished);
	wkhtmltopdf_set_progress_changed_callback($converter, &progress-changed);
	wkhtmltopdf_set_phase_changed_callback($converter, &phase-changed);
	wkhtmltopdf_set_error_callback($converter, &error);
	wkhtmltopdf_set_warning_callback($converter, &warning);
	
	# Perform the HTML -> PDF conversion
	my $blob;
	if !wkhtmltopdf_convert($converter) {
		say "Conversion failed!";
	} else {
		constant NULL = Pointer.new;
		my $data = NULL;
		my $len = wkhtmltopdf_get_output($converter, $data);
		$blob = blob-from-pointer( $data, :elems($len), :type(Blob[int8]) );
	}

	# Cleanup
	wkhtmltopdf_destroy_converter($converter);

	# Return PDF blob
	return $blob
}
