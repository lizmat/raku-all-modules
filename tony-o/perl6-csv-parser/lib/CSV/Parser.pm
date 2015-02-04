#!/usr/bin/env perl6
 
class CSV::Parser {
  has Bool       $.binary              = False;
  has IO::Handle $.file_handle         = Nil;
  has Bool       $.contains_header_row = False;
  has Any        $.field_separator     = ',';
  has Any        $.line_separator      = "\n";
  has Any        $.field_operator      = '"';
  has Any        $.escape_operator     = '\\';
  has Int        $.chunk_size          = 1024;
  has Int        $!fpos                = 0;
  has Int        $!bpos                = 0;
  has Int        $!bopn                = 0;
  has Any        %!headers             = Nil;
  has Any        $!lbuff               = '';

  method reset () {
    my $p = $.file_handle.path;
    $.file_handle.close;
    $.file_handle = open $p, :r;
  }

  method get_line () {
    return Nil if $.file_handle.eof;
    $!lbuff = $!lbuff == '' ?? ( $.binary == True ?? Buf.new() !! '' ) !! $!lbuff;
    my Any $buffer = $!lbuff;

    $!bpos = 0;
    $!bopn = 0;
    while my Any $line = ( $.binary == True ?? $.file_handle.read($.chunk_size) !! $.file_handle.get ) {
      $buffer = $buffer ~ $line;
      $buffer ~= "\n" if ( $.binary == False );
      $buffer ~= $.line_separator if ( $.binary == True );
      last if $.detect_end_line( $buffer ) == 1;
    }
    if ($.binary == True) {
      $buffer = $buffer.subbuf(0, $buffer.bytes - $.line_separator.bytes);
      $!lbuff = $buffer.subbuf($!bpos - 1);
      $buffer = $buffer.subbuf(0, $!bpos);
    } else {
      $buffer = $buffer.substr(0, $buffer.chars - 1);
      $!lbuff = $buffer.substr($!bpos - 1);
      $buffer = $buffer.substr(0, $!bpos);
    }
    if ( $!contains_header_row ) { 
      %!headers = %($.parse( $buffer ));
      $!contains_header_row = False;
      return $.get_line();
    }
    return %($.parse( $buffer ));
  };

  method parse ( $line ) returns Hash {
    my Any %values    = ();
    my Any %header    = %!headers;
    my Int $fcnt      = 0;
    my Any $localbuff = $.binary == True ?? Buf.new() !! '';
    my Int $buffpos   = 0;
    my Any $buffer    = $line;
    my Int $bopn      = 0;
    my Any $key;
    #my $reg       = /^{$.field_operator}|{$.field_operator}$/; #this shit isn't implemented yet

    while ($.binary == False && $buffpos < $buffer.chars) || ($.binary == True && $buffpos < $buffer.bytes) {
      if ( ( ( $.binary == False && $buffer.substr($buffpos, $.field_operator.chars) eq  $.field_operator ) || 
             ( $.binary == True && $buffer.subbuf($buffpos, $.field_operator.bytes) eqv $.field_operator ) ) &&
           ( ( $.binary == False && $localbuff ne   $.escape_operator ) || 
             ( $.binary == True && $localbuff !eqv $.escape_operator ) ) ) {
        $bopn = $bopn == 1 ?? 0 !! 1;
      }
      if ( ( ( $.binary == False && $buffer.substr($buffpos, $.field_separator.chars) eq  $.field_separator ) ||
             ( $.binary == True && $buffer.subbuf($buffpos, $.field_separator.bytes) eqv $.field_separator ) ) &&
           ( ( $.binary == False && $localbuff ne   $.escape_operator ) || 
             ( $.binary == True && $localbuff !eqv $.escape_operator ) ) &&
           $bopn == 0 ) {
        $key = %header.exists_key(~$fcnt) ?? %header{~$fcnt} !! $fcnt;
        if ($.binary == True) {
          %values{ $key } = $buffer.subbuf(0, $buffpos);
          %values{ $key } = %values{ $key }.subbuf($.field_operator.bytes, %values{ $key }.bytes - ( $.field_operator.bytes * 2 )) if %values{ $key }.subbuf(0, $.field_operator.bytes) eqv $.field_operator;
          $buffer = $buffer.subbuf($buffpos+$.field_separator.bytes);
        } else {
          %values{ $key } = $buffer.substr(0, $buffpos);
          %values{ $key } = %values{ $key }.substr($.field_operator.chars, %values{ $key }.chars - ( $.field_operator.chars * 2 )) if %values{ $key }.substr(0, $.field_operator.chars) eq  $.field_operator;
          $buffer = $buffer.substr($buffpos+$.field_separator.chars);
        }
        $buffpos = 0;
        $fcnt++;
        next;
      }
      
      $localbuff = ($localbuff.chars >= $.escape_operator.chars ?? $localbuff.substr(1) !! $localbuff) ~ $buffer.substr($buffpos, 1) if $.binary == False;
      $localbuff = ($localbuff.bytes >= $.escape_operator.bytes ?? $localbuff.subbuf(1) !! $localbuff) ~ $buffer.subbuf($buffpos, 1) if $.binary == True; 
      $buffpos++;
    }
    $key = %header.exists_key(~$fcnt) ?? %header{~$fcnt} !! $fcnt;
    %values{ $key } = $buffer;
    %values{ $key } = %values{ $key }.substr($.field_operator.chars, %values{ $key }.chars - ( $.field_operator.chars * 2 )) if $.binary == False && %values{ $key }.substr(0, $.field_operator.chars) eq  $.field_operator;
    %values{ $key } = %values{ $key }.subbuf($.field_operator.bytes, %values{ $key }.bytes - ( $.field_operator.bytes * 2 )) if $.binary == True && %values{ $key }.subbuf(0, $.field_operator.bytes) eqv $.field_operator;

    while %header.exists_key(~(++$fcnt)) {
      %values{%header{~$fcnt}} = Nil;
    }

    return %values;
  };

  method detect_end_line ( $buffer ) returns Int {
    my Any $localbuff = $.binary == True ?? Buf.new !! '';
    while $!bpos < ( $.binary == True ?? $buffer.bytes !! $buffer.chars ) {
      if ( ( ( $.binary == False && $buffer.substr($!bpos, $.field_operator.chars) eq  $.field_operator ) || 
             ( $.binary == True && $buffer.subbuf($!bpos, $.field_operator.bytes) eqv $.field_operator ) ) &&
           ( ( $.binary == False && $localbuff ne   $.escape_operator ) || 
             ( $.binary == True && $localbuff !eqv $.escape_operator ) ) ) {
        $!bopn = $!bopn == 1 ?? 0 !! 1;
      }

      #detect line separator
      if ( ( ( $.binary == False && $buffer.substr($!bpos, $.line_separator.chars) eq  $.line_separator ) ||
             ( $.binary == True && $buffer.subbuf($!bpos, $.line_separator.bytes) eqv $.line_separator ) ) && 
           ( ( $.binary == False && $localbuff ne   $.escape_operator ) ||
             ( $.binary == True && $localbuff !eqv $.escape_operator ) ) && 
           $!bopn == 0 ) {
        $!bpos++;
        return 1;
      }
      $localbuff = ($localbuff.chars >= $.escape_operator.chars ?? $localbuff.substr(1) !! $localbuff) ~ $buffer.substr($!bpos, 1) if $.binary == False;
      $localbuff = ($localbuff.bytes >= $.escape_operator.bytes ?? $localbuff.subbuf(1) !! $localbuff) ~ $buffer.subbuf($!bpos, 1) if $.binary == True;
      $!bpos++;
    }
    return 0;
  };
};
