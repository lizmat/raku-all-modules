#!/usr/bin/env perl6

unit module Net::Jupyter::Messages;

use v6;

use JSON::Tiny;
use MIME::Base64;

my MIME::Base64 $m64 .= new;

sub is-display($type)  is export {
  return True if  $type.starts-with('image');
  return False;
}

sub get-mime-type($data)  is export {
#  return 'text/plain' without $data;
  return 'image/svg+xml' if $data.starts-with('<svg');
  return 'image/gif' if $data.starts-with('GIF89a');
  return 'image/gif' if $data.starts-with('GIF87a');

  my $hex = $data.substr(0,8).encode('UTF8-C8').gist;
  $hex = $hex.substr($hex.index('<')+1, 23).split(' ').join;

  return 'image/png' if $hex.starts-with('89504e47');
  return 'image/jpeg' if $hex.starts-with('ffd8ffe');
  return 'image/tiff' if $hex.starts-with('492049');
  return 'image/tiff' if $hex.starts-with('49492a');
  return 'image/tiff' if $hex.starts-with('4d4d002');

  return  'text/plain';
}

multi sub shutdown_reply-content(Bool $restart) is export {
   my %dict = Hash.new;
   %dict< restart > = $restart;
   return to-json( %dict);
}


multi sub error-content(%dict) is export {
    return to-json( %dict< ename evalue traceback>);
}

multi sub error-content($name, $value, $traceback=()) is export {
    my %dict = Hash.new;
    %dict< ename > = $name;
    %dict< evalue > = $value;
    %dict< traceback > = $traceback;
    return to-json( %dict);
}

sub status-content($status) is export {
  die "Bad status: $status" unless ('idle','busy').grep( $status );
  return to-json( %( qqw/ execution_state $status/)  );
}


sub execute_input-content($count, $code) is export {
  my %dict = Hash.new;
  %dict< execution_count > = $count;
  %dict< code > = $code;
  return to-json( %dict);
}

sub stream-content($stream, $text) is export {
  my %dict = Hash.new;
  %dict< name > = $stream;
  %dict< text > = $text;
  return to-json( %dict);
}

sub display-data(@data) is export {
  my %dict = Hash.new;
  my %data = Hash.new;
  for @data -> $d {
    my $mime-type = get-mime-type($d);
    my $data = $d;
    given $mime-type {
      when  'image/png' {  $data = $m64.encode_base64($d);}
    }
    %data{ $mime-type } = $data;
  }
  %dict< data > = %data;
  %dict< metadata > = Hash.new;
  return to-json( %dict);
}

sub execute_result-content($count, $result, $metadata) is export {
  my %data = Hash.new;
  %data{ get-mime-type($result) } = $result;
  my %dict = Hash.new;
  %dict< execution_count > = $count;
  %dict< metadata  > = $metadata;
  %dict< data  > = %data;
  return to-json( %dict);
}

sub execute_reply-content($count, $error, $expressions, $payload) is export {
  my %dict = Hash.new;
  %dict< execution_count > = $count;
  with $error {
    %dict< status > = 'error';
  } else {
    %dict< status > = 'ok';
    %dict< payload > = $payload;
    %dict< user_expressions > = $expressions;
  }
  return to-json( %dict);
}

sub execute_reply_metadata($id, $status, $met) is export {
  my %dict = Hash.new;
  %dict< started > = DateTime.new(now).Str;
  %dict< dependencies_met > = $met;
  %dict< engine > = $id;
  %dict< status > = $status;
  return to-json( %dict);
}


sub kernel_info-reply-content($version) is export {
  my %info = <
    protocol_version 5.2.0
    implementation  iperl6 >;
  %info< implementation_version > =  $version;
  my %language_info = <
        name perl6
        version 6.d
        mimetype application/perl6
        file_extension .pl6>;
=begin c
        # Pygments lexer, for highlighting. Only needed if it differs from the 'name' field.
        'pygments_lexer': str,

        # Codemirror mode, for for highlighting in the notebook.  Only needed if it differs from the 'name' field.
        'codemirror_mode': str or dict,

        # Nbconvert exporter, if notebooks written with this kernel should be exported with something other than the general 'script' exporter.
        'nbconvert_exporter': str,
=end c
=cut

  %info< banner > = 'Awesomest Perl6';
  %info<help_links> = [ %("text", "help here", "url", "http://perl6.org") ] ;
  %info< language_info > = %language_info;
  return to-json(%info);
}


=begin c
  my WireMsg:D $wire .= new(:msg($m));
  given $wire.type {
    when 'shutdown_request' {
      MsgBuilder.new\
              .add('shutdown_reply')\
              .add( new-header(:id($wire.id), :type('shutdown_reply')))\
              .add( $wire.header )\
              .add('{}')\
              .add( '{"restart": false }' )\
              .finalize\
              .send-all($iolog-sk, $iopub-sk);
      return  Any;
    }
  }

  1;
=end c
=cut
