#!/usr/bin/env perl6

use v6;

unit module Net::Jupyter::EvalError;

my constant FILENAME = 'EvalError.pm';

class EvalError  is export {
  has Exception $.exception is required;
  has %!error;

  method extract() {
    return %!error if so %!error;
    my $x := $!exception;
    %!error< ename >  = $x.^name;
    %!error< gist > = $x.message || $x.^name;
    %!error< status > = 'error';
    given $x.is-compile-time {
        when 1 {
          %!error< type  > = 'Compilation Error';
        try {
            %!error< context > =  "@ line {$x.line}, pos {$x.pos} ---> {$x.pre}<***>{$x.post}";
            CATCH { default { %!error< context > = $x.perl; }}
        }
        %!error< traceback > = [];
        %!error< TRACEBACK > = '';
      }
      when 0 {
        %!error< type  > = 'Runtime Error';
        %!error< context > = '';
        %!error< traceback > = $x.backtrace.grep( { ! .file.index( FILENAME  ).defined });#\
        %!error< TRACEBACK > = $x.backtrace.full;
      }
    }
    %!error< perl > = $x.perl;
    %!error< dependencies-error > = $x.isa(X::CompUnit::UnsatisfiedDependency);
    %!error< gist > = 'Unsatisfied Dependencies: ' ~ %!error< gist > if %!error< dependencies >;

    %!error< evalue > = "%!error< type >: %!error< gist > %!error< context >";
    return %!error;
  }

  method Str {
    return qq:to/ERR_FORMAT/;
    type:     %!error< type >
    name:     %!error< ename >
    error:    %!error< gist >
    context:  %!error< context >
    perl:
              %!error< perl >

    trace:    %!error< traceback >
    TRACE:    %!error< TRACEBACK >
    DEP:      %!error< dependencies-error >
    ERR_FORMAT
  }

  multi method format(:$short!) {
    self.extract unless %!error;
    return %!error< evalue >;
  }

  multi method format(:$long!) {
    return qq:to/ERR_FORMAT_3/;
    { self.format(:short) }
    %!error< ename >
    %!error< traceback >
    ERR_FORMAT_3
  }

  multi method format(:$full!) {
    return qq:to/ERR_FORMAT_4/;
    { self.format(:long) }
    %!error< perl >
    ERR_FORMAT_4
  }


}# class EvalError
