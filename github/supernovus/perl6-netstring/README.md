# Netstring library for Perl 6

## Introduction

Work with netstrings. This currently supports generating netstrings, and
parsing a netstring from an IO::Socket (it would support further IO classes,
except that the current Perl 6 implementations do not seem to have a more
generic IO role.)

## Usage

### Generating Netstrings

```perl
  use Netstring;

  to-netstring("hello world!");
  ## returns "12:hello world!,"

  my $b = Buf.new(0x68,0x65,0x6c,0x6c,0x6f,0x20,0x77,0x6f,0x72,0x6c,0x64,0x21);
  to-netstring($b);
  ## returns "12:hello world!,";

  to-netstring-buf("hello world!");
  ## returns Buf:0x<31 32 3a 68 65 6c 6c 6f 20 77 6f 72 6c 64 21 2c>

  to-netstring-buf($b);
  ## returns Buf:0x<31 32 3a 68 65 6c 6c 6f 20 77 6f 72 6c 64 21 2c>

```

### Reading Netstring from IO::Socket

```perl
  use Netstring;

  my $daemon = IO::Socket::INET.new(
    :localhost<localhost>,
    :localport(42),
    :listen
  );

  while my $client = $daemon.accept()
  {
    ## The client sends "12:hello world!," as a stream of bytes.
    my $rawcontent = read-netstring($client);
    my $strcontent = $rawcontent.decode;

    say "The client said: $strcontent";
    ## prints "The client said: hello world!"

    $client.write($strcontent.flip);
    ## sends "!dlrow olleh" back to the client.
    
    $client.close();
  }

```

## Author 

Timothy Totten, supernovus on #perl6, https://github.com/supernovus/

## License

Artistic License 2.0

