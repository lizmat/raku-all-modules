[![Build Status](https://travis-ci.org/zoffixznet/perl6-NASA.svg)](https://travis-ci.org/zoffixznet/perl6-NASA)

# NAME

NASA::MarsRover - use NASA's `Mars Rover Photos` API

# SYNOPSIS

```perl6
use NASA::MarsRovers;
my NASA::MarsRovers $rovers .= new: :key<drH7437T55HSV266UJ77TxhoT>;

my $sol = $rovers.curiosity.query: :0sol;

say "See this cool landing-day photo: $sol<cameras><FHAZ>[0]<img_src>";
```
# DESCRIPTION

Access photographs from several cameras installed on the three Mars rovers.

# METHODS

## `new`

```perl6
use NASA::MarsRovers;
my NASA::MarsRovers $mars .= new; # use severely rate-limited keyless operation
my NASA::MarsRovers $mars .= new: :key<drH7437T55HSV266UJ77TxhoT>; # use your own API key
```

Constructs and returns a new `NASA::MarsRovers` object. Takes one **optional**
argument: `key`. To get your API key, visit [](https://api.nasa.gov/index.html#apply-for-an-api-key). If no key is provided,
`DEMO_KEY` will be used, which is a rate-limited key provided by NASA. It allows
only 50 queries per day (30 per hour).

## `.ROVER.query`

```perl6
    say $mars.curiosity.query: :0sol;

    my $oppy = $mars.opportunity;
    say $oppy.query:
        :earth-date<2012-08-06>,
        :camera<FHAZ>
        :2page;

    method query (
        Sol       :$sol,
        EarthDate :$earth-date,
        RoverCam  :$camera,
        Int       :$page,
    ) {
```

```perl6
{
  cameras => {
    CHEMCAM => [
      {
        id      => 3133.Int,
        img_src => "http://mars.jpl.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/00000/opgs/edr/ccam/CR0_397506222EDR_F0010008CCAM00000M_.JPG".Str,
      },
      {
        id      => 58889.Int,
        img_src => "http://mars.jpl.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/00000/opgs/edr/ccam/CR0_397506434EDR_F0010008CCAM00000M_.JPG".Str,
      },
    ],
    ...
  },
  rover   => {
    cameras      => {
      CHEMCAM => "Chemistry and Camera Complex".Str,
      FHAZ    => "Front Hazard Avoidance Camera".Str,
      MAHLI   => "Mars Hand Lens Imager".Str,
      MARDI   => "Mars Descent Imager".Str,
      MAST    => "Mast Camera".Str,
      NAVCAM  => "Navigation Camera".Str,
      RHAZ    => "Rear Hazard Avoidance Camera".Str,
    },
    landing_date => "2012-08-06".Str,
    max_date     => "2016-04-19".Str,
    max_sol      => 1316.Int,
    name         => "Curiosity".Str,
    total_photos => 250619.Int,
  },
}
```

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-NASA

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-NASA/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
