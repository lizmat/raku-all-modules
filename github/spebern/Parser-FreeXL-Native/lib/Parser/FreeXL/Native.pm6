use v6;
use NativeCall;

sub freexl_lib(--> Str) {
    return IO::Path.new('./lib/' ~ sprintf $*VM.config<dll>, 'freexl').Str;
}

class FileNotFound is Exception {
    has Str $.path is required;
    method message { "path '$.path' not found" }
}

class OpenError is Exception {
    has Str $.path is required;
    method message { "unknown error opening file: " }
}

class IllegalSheetIndex is Exception {
    has Int $.sheet_index is required;
    method message { "sheet with index: '$.sheet_index' does not exist" }
}

class IllegalSheetName is Exception {
    has Str $.sheet_name is required;
    method message { "sheet with name: '$.sheet_name' does not exist" }
}

class IllegalCell is Exception {
    has Int $.row   is required;
    has Int $.rows  is required;
    has Int $.col   is required;
    has Int $.cols  is required;
    has Str $.sheet is required;
    method message {
        "Cell in sheet: '$.sheet', row: '$.row', col: '$.col' does not exist\n"
      ~ "Boundaries in sheet are rows: '$.rows', cols: '$.cols'"
    }
}

class CellValue is repr('CUnion') {
    has int32 $.int_value;
    has num64 $.double_value;
    has Str   $.text_value;
}

class Cell is repr('CStruct') {
    has uint8     $!type;
    HAS CellValue $!value;

    method type {
        given $!type {
            when 102 { return 'int'      }
            when 103 { return 'double'   }
            when 104 { return 'text'     }
            when 105 { return 'text'     }
            when 106 { return 'date'     }
            when 107 { return 'datetime' }
            when 108 { return 'time'     }
            default  { return Nil        }
        }
    }

    method value {
        given $!type {
            when 101 { return Nil                      }
            when 102 { return $!value.int_value    }
            when 103 { return $!value.double_value }
            when 104 { return $!value.text_value   }
            when 105 { return $!value.text_value   }
            when 106 { return $!value.text_value   }
            when 107 { return $!value.text_value   }
            when 108 { return $!value.text_value   }
        }
    }
}

class Parser::FreeXL::Native is export {
    has Bool    $!initialized  = False;
    has Pointer $!xls_handle  .= new;
    has uint32  $!rows;
    has uint16  $!cols;
    has Str     $.active_sheet is rw;
    has Int     $.sheet_count is rw;
    has Str     @.sheet_names;

    method DESTROY() {
        freexl_close($!xls_handle) if $!initialized;
    }

    method open(Str $path) {
        freexl_close($!xls_handle) if $!initialized;

        my $status = freexl_open($path, $!xls_handle);
        if $status == -1 {
            die FileNotFound.new(:path($path));
        }
        elsif $status != 0 {
            die OpenError.new;
        }
        $!initialized = True;

        $.sheet_count = self!get_sheet_count;

        my int32 $result;
        @.sheet_names = (0 ..^ $.sheet_count).map( -> Int $sheet_index {
            p6_freexl_get_worksheet_name($!xls_handle, $sheet_index, $result)
        });
    }

    method version { freexl_version };

    method !get_sheet_count {
        my uint32 $sheet_count;
        freexl_get_info($!xls_handle, 32010, $sheet_count);
        return $sheet_count;
    }

    multi method select_sheet(Str $sheet_name) {
        my int32 $result;
        my Int $sheet_index = (0 ..^ $!sheet_count).first( -> int16 $sheet_index { @.sheet_names[$sheet_index] eq $sheet_name });
        if $sheet_index.defined {
            self.select_sheet($sheet_index);
        }
        else {
            die IllegalSheetName.new(:sheet_name($sheet_name));
        }
    }

    multi method select_sheet(Int $sheet_index) {
        my int16 $native_sheet_index = $sheet_index;
        if freexl_select_active_worksheet($!xls_handle, $native_sheet_index) == -18 {
            die IllegalSheetIndex.new(:sheet_index($sheet_index));
        }
        freexl_worksheet_dimensions($!xls_handle, $!rows, $!cols);

        my Str $test .= new;

        my int32 $result;
        my $.active_sheet = p6_freexl_get_worksheet_name($!xls_handle, $sheet_index, $result);
    }

    method sheet_dimensions {
        return ($!rows, $!cols);
    }

    method get_cell(uint32 $row, uint16 $col) {
        my Cell $cell .= new;
        if freexl_get_cell_value($!xls_handle, $row, $col, $cell) == -22 {
            die IllegalCell.new(
                row   => $row,
                rows  => $!rows,
                col   => $col,
                cols  => $!cols,
                sheet => $.active_sheet,
            );
        }
        return $cell;
    }

    # native functions

    sub freexl_open(Str $path, Pointer $xls_handle is rw --> int32) is native(&freexl_lib) { * }

    sub freexl_close(Pointer $xls_handle is rw --> int32) is native(&freexl_lib) { * }

    sub freexl_version(--> Str) is native(&freexl_lib) { * }

    sub freexl_get_info(Pointer $xls_handle, uint16 $what, uint32 $info is rw --> int32)
        is native(&freexl_lib) { * }

    sub p6_freexl_get_worksheet_name(Pointer $xls_handle, uint16 $sheet_index, int32 $result is rw
                                --> Str) is native(&freexl_lib) { * }

    sub freexl_select_active_worksheet(Pointer $xls_handle, uint16 $sheet_index --> int32)
        is native(&freexl_lib) { * }

    sub freexl_worksheet_dimensions(Pointer $xls_handle, uint32 $rows is rw, uint16 $cols is rw
                                --> int32) is native(&freexl_lib) { * }

    sub freexl_get_cell_value(Pointer $xls_handle, uint32 $row, uint16 $col, Cell $cell is rw
                              --> int32) is native(&freexl_lib) { * }
}

=begin pod

=head1 NAME

Parser::FreeXL::Native - wrapper for freexl parsing .xls files

=head1 SYNOPSIS

  use Parser::FreeXL::Native;

  my Parser::FreeXL::Native $parser .= new;
  $parser.open('file.xls');

  my $sheet_count = $parser.sheet_count;

  $parser.select_sheet(1);
  $parser.select_sheet('sheet_1');

  my @sheet_names = $parser.sheet_names;

  my ($max_row, $max_col) = $parser.sheet_dimensions;

  for ^$max_row -> $row {
      for ^$max_col -> $col {
          my $cell = $parser.get_cell($row, $col);
          # types: <int double text date datetime time>, Nil
          my $type  = $cell.type;
          my $value = $cell.value;

          # do something with type and value
      }
  }

=head1 DESCRIPTION

Parser::FreeXL::Native is a parser for xls using the freexl c library

Windows support is planned. Currently the dll is missing.

=head1 AUTHOR

spebern <bernhard@specht.net>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 spebern

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
