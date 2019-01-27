
use v6;

unit module Wkhtmltox::Native;

use NativeCall;

sub lib {	
	# TODO support macOS platform
	# TODO support windows platform
	return "/usr/local/lib/libwkhtmltox.so"
}

# Prototype... see pdf.h
sub wkhtmltopdf_init(int32) returns int32 is native(&lib) is export { * }
sub wkhtmltopdf_deinit is native(&lib) is export { * }
sub wkhtmltopdf_extended_qt() returns int32 is native(&lib) is export { * }
sub wkhtmltopdf_version returns Str is native(&lib) is export { * }

sub wkhtmltopdf_create_global_settings returns int32 is native(&lib) is export { * }
sub wkhtmltopdf_destroy_global_settings(int32) is native(&lib) is export { * }

sub wkhtmltopdf_create_object_settings returns int32 is native(&lib) is export { * }
sub wkhtmltopdf_destroy_object_settings(int32) is native(&lib) is export { * }

sub wkhtmltopdf_set_global_setting(int32, Str, Str) returns int32 is native(&lib) is export { * }
sub wkhtmltopdf_get_global_setting(int32, Str, Blob[uint8], int32) returns int32 is native(&lib) is export { * }
sub wkhtmltopdf_set_object_setting(int32, Str, Str) returns int32 is native(&lib) is export { * }
sub wkhtmltopdf_get_object_setting(int32, Str, Str, int32) returns int32 is native(&lib) is export { * }

sub wkhtmltopdf_create_converter(int32) returns int32 is native(&lib) is export { * }
sub wkhtmltopdf_destroy_converter(int32) is native(&lib) is export { * }

sub wkhtmltopdf_set_warning_callback(int32, &callback (int32, Str)) is native(&lib) is export { * };
sub wkhtmltopdf_set_error_callback(int32, &callback (int32, Str)) is native(&lib) is export { * };
sub wkhtmltopdf_set_phase_changed_callback(int32, &callback (int32)) is native(&lib) is export { * };
sub wkhtmltopdf_set_progress_changed_callback(int32, &callback (int32, int32)) is native(&lib) is export { * };
sub wkhtmltopdf_set_finished_callback(int32, &callback (int32, int32)) is native(&lib) is export { * };

sub wkhtmltopdf_convert(int32) returns int32 is native(&lib) is export { * }
sub wkhtmltopdf_add_object(int32, int32, Str) is native(&lib) is export { * }

sub wkhtmltopdf_current_phase(int32) returns int32 is native(&lib) is export { * }
sub wkhtmltopdf_phase_count(int32) returns int32 is native(&lib) is export { * }
sub wkhtmltopdf_phase_description(int32, int32) returns Str is native(&lib) is export { * }
sub wkhtmltopdf_progress_string(int32) returns Str is native(&lib) is export { * }
sub wkhtmltopdf_get_output(int32, Pointer is rw) returns int32 is native(&lib) is export { * }
sub wkhtmltopdf_http_error_code(int32) returns int32 is native(&lib) is export { * }
