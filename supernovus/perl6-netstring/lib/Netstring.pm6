use v6;

unit module Netstring;

proto to-netstring ($) is export {*}
proto to-netstring-buf ($) is export {*}

multi to-netstring (Str $str --> Str)
{
  my $bytes = $str.encode.bytes;
  return "$bytes:$str,";
}

multi to-netstring (Blob $buf --> Str)
{
  my $bytes = $buf.bytes;
  my $str = $buf.decode;
  return "$bytes:$str,";
}

multi to-netstring-buf (Str $str --> Buf)
{
  my $buf = $str.encode;
  to-netstring-buf($buf);
}

multi to-netstring-buf (Blob $buf --> Buf)
{
  my $bytes = $buf.bytes.Str.encode;
  my $colon = ':'.encode;
  my $comma = ','.encode;
  return Buf.new($bytes ~ $colon ~ $buf ~ $comma);
}

sub read-netstring (IO::Socket $in --> Buf) is export
{
  my Str $len = '';
  loop
  {
    my $byte = $in.read(1);
    my $str = $byte.decode;
    if $str eq ':' { last; }
    elsif $str ~~ /^ <[0..9]> $/
    {
      $len ~= $str;
    }
    else
    {
      die "Invalid netstring stream data.";
    }
  }
  my $content = $in.read(+$len);
  my $terminator = $in.read(1);
  $terminator.=decode;
  if $terminator ne ',' 
  { 
    die "Missing or invalid netstring terminator: $terminator" 
  }
  return $content;
}

