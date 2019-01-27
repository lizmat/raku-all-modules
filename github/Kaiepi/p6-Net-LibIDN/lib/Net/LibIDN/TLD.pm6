use v6.c;
use NativeCall;
use Net::LibIDN::Free;
use Net::LibIDN::Native;
unit class Net::LibIDN::TLD;

constant TLD_SUCCESS      is export = 0;
constant TLD_INVALID      is export = 1;
constant TLD_NODATA       is export = 2;
constant TLD_MALLOC_ERROR is export = 3;
constant TLD_ICONV_ERROR  is export = 4;
constant TLD_NO_TLD       is export = 5;

class Table::Element is repr('CStruct') {
    has uint32 $.start;
    has uint32 $.end;

    submethod TWEAK() {
        $!start = 0;
        $!end   = 0;
    }
}

class Table is repr('CStruct') {
    has Str $.name;
    has Str $.version;
    has size_t $.nvalid;
    has Pointer[Table::Element] $.valid;

    submethod TWEAK() {
        $!name    = Str.new;
        $!version = Str.new;
        $!nvalid  = 0;
        $!valid   = Pointer[Table::Element].new;
    }
}

sub tld_strerror(int32 --> Str) is native(LIB) { * }
method strerror(Int $code --> Str) { tld_strerror($code) || '' }

sub tld_get_z(
    Str,
    Pointer[Str] is encoded('ascii') is rw
    --> int32
) is native(LIB) { * }
proto method get_z(Str, Int $? --> Str) { * }
multi method get_z(Str $domain --> Str) {
    my $tldptr := Pointer[Str].new;
    my $code := tld_get_z($domain, $tldptr);
    return '' if $code !== TLD_SUCCESS;

    my $tld := $tldptr.deref;
    idn_free($tldptr);
    $tld;
}
multi method get_z(Str $domain, Int $code is rw --> Str) {
    my $tldptr := Pointer[Str].new;
    $code = tld_get_z($domain, $tldptr);
    return '' if $code !== TLD_SUCCESS;

    my $tld := $tldptr.deref;
    idn_free($tldptr);
    $tld;
}

sub tld_get_table(
    Str is encoded('ascii'),
    CArray[Pointer[Table]]
    --> Pointer[Table]
) is native(LIB) { * }
method get_table(Str $tld, @tables --> Pointer[Table]) {
    my @tableptrs := CArray[Pointer[Table]].new: @tables;
    tld_get_table($tld, @tableptrs);
}

sub tld_default_table(
    Str is encoded('ascii'),
    CArray[Pointer[Table]]
    --> Pointer[Table]
) is native(LIB) { * }
proto method default_table(Str, @? --> Pointer[Table]) { * }
multi method default_table(Str $tld --> Pointer[Table]) {
    my @overrides := CArray[Pointer[Table]].new;
    tld_default_table($tld, @overrides);
}
multi method default_table(Str $tld, @tables --> Pointer[Table]) {
    my @overrides := CArray[Pointer[Table]].new: @tables;
    tld_default_table($tld, @overrides);
}

sub tld_check_8z(
    Str,
    Pointer[size_t] is rw,
    CArray[Pointer[Table]]
    --> int32
) is native(LIB) { * }
proto method check_8z(Str, | --> Int) { * }
multi method check_8z(Str $input --> Int) {
    my $errposptr = Pointer[size_t].new;
    my @overrides := CArray[Pointer[Table]].new;
    my $code := tld_check_8z($input, $errposptr, @overrides);
    return 0 unless $errposptr;

    my $errpos := $errposptr.deref;
    idn_free($errposptr);
    $errpos;
}
multi method check_8z(Str $input, Int $code is rw --> Int) {
    my $errposptr = Pointer[size_t].new;
    my @overrides := CArray[Pointer[Table]].new;
    $code = tld_check_8z($input, $errposptr, @overrides);
    return 0 unless $errposptr;

    my $errpos := $errposptr.deref;
    idn_free($errposptr);
    $errpos;
}
multi method check_8z(Str $input, @tables --> Int) {
    my $errposptr = Pointer[size_t].new;
    my @overrides := CArray[Pointer[Table]].new: @tables;
    my $code := tld_check_8z($input, $errposptr, @overrides);
    return 0 unless $errposptr;

    my $errpos := $errposptr.deref;
    idn_free($errposptr);
    $errpos;
}
multi method check_8z(Str $input, @tables, Int $code is rw --> Int) {
    my $errposptr = Pointer[size_t].new;
    my @overrides := CArray[Pointer[Table]].new: @tables;
    $code = tld_check_8z($input, $errposptr, @overrides);
    return 0 unless $errposptr;

    my $errpos := $errposptr.deref;
    idn_free($errposptr);
    $errpos;
}

=begin pod

=head1 NAME

Net::LibIDN::TLD

=head1 SYNOPSIS

  use Net::LibIDN::TLD;

  my $idn_tld := Net::LibIDN::TLD.new;
  my $domain := 'google.com';
  my Int $code;
  my $tld := $idn_tld.get_z($domain, $code);
  say "$tld $code"; # com 0

  my $tld := 'fr';
  my $tableptr = $idn_tld.default_table($tld);
  my $table = $tableptr.deref;
  say $table.name, ' ', $table.nvalid; # fr 12

  $tableptr = $idn_tld.get_table($tld, [$tableptr]);
  $table = $tableptr2.deref;
  say $table.name, ' ', $table.nvalid; # fr 12

  my $errpos := $idn_tld.check_8z($domain, $code);
  say "$errpos $code"; # 0 0

  say $idn_tld.strerror($code); # Success

=head1 DESCRIPTION

Net::LibIDN::TLD provides bindings for checking domains against tables of
characters allowed by the organization in control of their top level domain.

=head1 METHODS

=item B<Net::LibIDN::TLD.strerror>(Int I<$code> --> Str)

Returns the error represented by I<$code> in human readable form. This is only
available in LibIDN v0.4.0 and later.

=item B<Net::LibIDN::TLD.get_z>(Str I<$domain> --> Str)
=item B<Net::LibIDN::TLD.get_z>(Str I<$domain>, Int I<$code> is rw --> Str)

Returns the top level domain of I<$domain> as an ASCII encoded string. Assigns
I<$code> to the corresponding error code returned by the native function if
provided. This is only available in LibIDN v0.4.0 and later.

=item B<Net::LibIDN::TLD.get_table>(Str I<$tld>, I<@tables> --> Pointer[Net::LibIDN::TLD::Table])

Returns a pointer to the TLD table for I<$tld> in the given array of pointers
to I<Net::LibIDN::TLD::Table>, I<@tables>. This is only available in LibIDN
v0.4.0 and later.

=item B<Net::LibIDN::TLD.default_table>(Str I<$tld> --> Pointer[Net:LibIDN::TLD::Table])
=item B<Net::LibIDN::TLD.default_table>(Str I<$tld>, I<@tables> --> Pointer[Net::LibIDN::TLD::Table])

Returns a pointer to the default TLD table for I<$tld>. I<@tables>, if
provided, contains an array of pointers to I<Net::LibIDN::TLD::Table>, which
overrides the array of natively cached TLD tables. This is only available in
LibIDN v0.4.0 and later.

=item B<Net::LibIDN::TLD.check_8z>(Str I<$input> --> Int)
=item B<Net::LibIDN::TLD.check_8z>(Str I<$input>, Int I<$code> is rw --> Int)
=item B<Net::LibIDN::TLD.check_8z>(Str I<$input>, @tables --> Int)
=item B<Net::LibIDN::TLD.check_8z>(Str I<$input>, @tables, Int I<$code> is rw --> Bool)

Checks for any invalid characters in I<$input>, and returns the position of any
offending character found, or 0 otherwise. Assigns I<$code> to the
corresponding error code returned by the native function, if provided.
I<@tables> contains an array of pointers to I<Net::LibIDN::TLD::Table>, if
provided, which overrides the array of natively cached TLD tables. This is only
available in LibiDN v0.4.0 and later.

=head1 CONSTANTS

=head2 ERRORS

=item Int B<TLD_SUCCESS>

Success.

=item Int B<TLD_INVALID>

Invalid character found.

=item Int B<TLD_NODATA>

No input data was provided.

=item Int B<TLD_MALLOC_ERROR>

Error during memory allocation.

=item Int B<TLD_ICONV_ERROR>

Error during iconv string conversion.

=item Int B<TLD_NO_TLD>

No top-level domain found in the input string.

=end pod
