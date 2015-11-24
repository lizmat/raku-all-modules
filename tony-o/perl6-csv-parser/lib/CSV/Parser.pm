#!/usr/bin/env perl6

class CSV::Parser {
  has Bool       $.binary              = False;
  has IO::Handle $.file_handle         = Nil;
  has Bool       $.contains_header_row = False;
  has            $.field_separator     = ',';
  has            $.line_separator      = "\n";
  has            $.field_operator      = '"';
  has            $.escape_operator     = '\\';
  has int        $.chunk_size          = 1024;
  has int        $!fpos                = 0;
  has int        $!bpos                = 0;
  has int        $!bopn                = 0;
  has            $!lbuff;

  has        %!headers;

  method reset () {
    my $p = $!file_handle.path;
    $!file_handle.close;
    $!file_handle = open $p, :r;
  }

  method get_line () {
    return Nil if $!file_handle.eof;
    $!lbuff = ?$!binary ?? Buf.new() !! '';
    $!bpos  = $!bopn = 0;
    my $buffer   = $!lbuff;
    my $lso_size = size_of($!line_separator);

    while ( ?$!binary ?? $!file_handle.read($!chunk_size) !! $!file_handle.get ) -> $line {
      $buffer ~= $line ~ $!line_separator;
      last if self.detect_end_line( $buffer ) == 1;
    }

    if (size_of($buffer) - $lso_size) -> $size {
      $buffer  = subpart($buffer, 0, $size);
      $!lbuff  = subpart($buffer, $!bpos - $lso_size);
      $buffer  = subpart($buffer, 0, $!bpos);
    }
    !$!contains_header_row ?? %(self.parse( $buffer )) !! do {
      %!headers = %(self.parse( $buffer ));
      $!contains_header_row = False;
      self.get_line();
    };
  };

  method parse ( $line ) returns Hash {
    my %values      = ();
    my %header      = %!headers;
    my $localbuff   = ?$!binary ?? Buf.new() !! '';
    my $buffer      = $line;
    my int $fcnt    = 0;
    my int $buffpos = 0;
    my int $bopn    = 0;
    my $key;
    #my $reg       = /^{$.field_operator}|{$.field_operator}$/; #this shit isn't implemented yet
    my $fop_size = size_of($!field_operator);
    my $fsp_size = size_of($!field_separator);
    my $eop_size = size_of($!escape_operator);
    my $lso_size = size_of($!line_separator);

    while $buffpos < size_of($buffer) {
      if subpart($buffer, $buffpos, $fop_size) eqv $!field_operator && $localbuff !eqv $!escape_operator {
        $bopn = $bopn == 1 ?? 0 !! 1;
      }

      if $bopn == 0 && subpart($buffer, $buffpos, $fsp_size) eqv $!field_separator && $localbuff !eqv $!escape_operator {
        $key = %header{(~$fcnt)}:exists ?? %header{~$fcnt} !! $fcnt;
        my $buf := subpart($buffer, 0, $buffpos);
        %values{ $key } = subpart($buf, 0, $fop_size) eqv $!field_operator
          ?? subpart($buf, $fop_size, size_of($buf) - ( $fop_size * 2 ))
          !! $buf;
        $buffer = subpart($buffer, ($buffpos+$fsp_size));
        $buffpos = 0;
        $fcnt++;
        next;
      }
      $localbuff = (size_of($localbuff) >= $eop_size ?? subpart($localbuff, $eop_size) !! $localbuff) ~ subpart($buffer, $buffpos, $eop_size);
      $buffpos++;
    }

    $key = %header{~$fcnt}:exists ?? %header{~$fcnt} !! $fcnt;
    %values{ $key } = subpart($buffer, $fop_size, size_of($buffer) - ( $fop_size * 2 ))\
      if subpart($buffer, 0, $fop_size) eqv $!field_operator;

    while %header{~(++$fcnt)}:exists {
      %values{%header{~$fcnt}} = Nil;
    }

    return %values;
  };

  method detect_end_line ( $buffer ) returns Bool {
    my $localbuff = ?$!binary ?? Buf.new() !! '';
    my $fop_size = size_of($!field_operator);
    my $eop_size = size_of($!escape_operator);
    my $lso_size = size_of($!line_separator);

    while $!bpos < size_of($buffer) {
      if subpart($buffer, $!bpos, $fop_size) eqv $!field_operator && $localbuff !eqv $!escape_operator {
        $!bopn = $!bopn == 1 ?? 0 !! 1;
      }

      #detect line separator
      if subpart($buffer, $!bpos, $lso_size) eqv $!line_separator && $localbuff !eqv $!escape_operator && $!bopn == 0 {
        $!bpos++;
        return True;
      }
      $localbuff = (size_of($localbuff) >= $eop_size ?? subpart($localbuff, $eop_size) !! $localbuff) ~ subpart($buffer, $!bpos, $eop_size);
      $!bpos++;
    }
    return False;
  };

  proto sub size_of(|) {*}
  multi sub size_of(Blob $data) { $data.bytes }
  multi sub size_of(Str $data)  { $data.chars }
  multi sub size_of(Any $)      { 0 }

  proto sub subpart(|) {*}
  multi sub subpart(Blob $data, |c) { $data.subbuf(|c) }
  multi sub subpart(Str $data,  |c) { $data.substr(|c) }
};
