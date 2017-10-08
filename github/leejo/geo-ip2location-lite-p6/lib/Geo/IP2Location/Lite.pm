unit module Geo::IP2Location::Lite:auth<github:leejo>:ver<0.9.0>;

use NativeCall;

class Geo::IP2Location::Lite {

	subset IPv4 of Str where / (\d ** 1..3) ** 4 % '.' /;
	has %!file is required;

	my $UNKNOWN            = "UNKNOWN IP ADDRESS";
	my $NOT_SUPPORTED      = "This parameter is unavailable in selected .BIN data file. Please upgrade data file.";
	my $MAX_IPV4_RANGE     = 4294967295;

	my $COUNTRY_SHORT      = 0;
	my $COUNTRY_LONG       = 1;
	my $LATITUDE           = 5;
	my $LONGITUDE          = 6;

	my $NUMBER_OF_FIELDS   = 20;
	my $NAME_FIELD         = 25;

	my @POSITIONS = (
		[0,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2, 'country_short' ],
		[0,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2, 'country_long' ],
		[0,  0,  0,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3, 'region' ],
		[0,  0,  0,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4, 'city' ],
		[0,  0,  3,  0,  5,  0,  7,  5,  7,  0,  8,  0,  9,  0,  9,  0,  9,  0,  9,  7,  9,  0,  9,  7,  9, 'isp' ],
		[0,  0,  0,  0,  0,  5,  5,  0,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5, 'latitude' ],
		[0,  0,  0,  0,  0,  6,  6,  0,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6, 'longitude' ],
		[0,  0,  0,  0,  0,  0,  0,  6,  8,  0,  9,  0, 10,  0, 10,  0, 10,  0, 10,  8, 10,  0, 10,  8, 10, 'domain' ],
		[0,  0,  0,  0,  0,  0,  0,  0,  0,  7,  7,  7,  7,  0,  7,  7,  7,  0,  7,  0,  7,  7,  7,  0,  7, 'zipcode' ],
		[0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  8,  8,  7,  8,  8,  8,  7,  8,  0,  8,  8,  8,  0,  8, 'timezone' ],
		[0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  8, 11,  0, 11,  8, 11,  0, 11,  0, 11,  0, 11, 'netspeed' ],
		[0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  9, 12,  0, 12,  0, 12,  9, 12,  0, 12, 'iddcode' ],
		[0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 10, 13,  0, 13,  0, 13, 10, 13,  0, 13, 'areacode' ],
		[0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  9, 14,  0, 14,  0, 14,  0, 14, 'weatherstationcode' ],
		[0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 10, 15,  0, 15,  0, 15,  0, 15, 'weatherstationname' ],
		[0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  9, 16,  0, 16,  9, 16, 'mcc' ],
		[0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 10, 17,  0, 17, 10, 17, 'mnc' ],
		[0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 11, 18,  0, 18, 11, 18, 'mobilebrand' ],
		[0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 11, 19,  0, 19, 'elevation' ],
		[0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 12, 20, 'usagetype' ],
		[0...24, 'all' ], # special "give me everything" case
	);

	submethod BUILD( Str :$file ) {
		%!file{"filehandle"} = open( $file, :bin );

		%!file{"databasetype"}      = self!read8(%!file{"filehandle"}, 1);
		%!file{"databasecolumn"}    = self!read8(%!file{"filehandle"}, 2);
		%!file{"databaseyear"}      = self!read8(%!file{"filehandle"}, 3);
		%!file{"databasemonth"}     = self!read8(%!file{"filehandle"}, 4);
		%!file{"databaseday"}       = self!read8(%!file{"filehandle"}, 5);
		%!file{"ipv4databasecount"} = self!read32(%!file{"filehandle"}, 6);
		%!file{"ipv4databaseaddr"}  = self!read32(%!file{"filehandle"}, 10);
		%!file{"ipv4indexbaseaddr"} = self!read32(%!file{"filehandle"}, 22);

		for @POSITIONS.kv -> $i,$pos {
			self.^add_method( "get_{ $pos[$NAME_FIELD] }",method ( IPv4 $ip ) {
				self!get_record( $ip,$i )
			} );
		}

	}

	method get_country ( IPv4 $ip ) {
		( self!get_record( $ip,0 ),self!get_record( $ip,1 ) );
	}

	method !get_record ( IPv4 $ipaddr, Int $mode ) {
		my $ipnum = :256[$ipaddr.comb(/\d+/)]; # convert ipv4 to int!
		my $dbtype= %!file{"databasetype"};

		if $mode != $NUMBER_OF_FIELDS {
			if @POSITIONS[$mode][$dbtype] == 0 {
				return $NOT_SUPPORTED;
			}
		}
		
		my $realipno = $ipnum;
		my $handle = %!file{"filehandle"};
		my $baseaddr = %!file{"ipv4databaseaddr"};
		my $dbcount = %!file{"ipv4databasecount"};
		my $dbcolumn = %!file{"databasecolumn"};
		my $indexbaseaddr = %!file{"ipv4indexbaseaddr"};

		my $ipnum1_2 = $ipnum +> 16;
		my $indexaddr = $indexbaseaddr + ($ipnum1_2 +< 3);

		my $low = 0;
		my $high = $dbcount;

		if $indexbaseaddr > 0 {
			$low = self!read32($handle, $indexaddr);
			$high = self!read32($handle, $indexaddr + 4);
		}

		my $mid = 0;
		my $ipfrom = 0;
		my $ipto = 0;
		my $ipno = 0;

		if $realipno == $MAX_IPV4_RANGE {
			$ipno = $realipno - 1;
		} else {
			$ipno = $realipno;
		}

		while ($low <= $high) {
			$mid = ($low + $high) +> 1;
			$ipfrom = self!read32($handle, $baseaddr + $mid * $dbcolumn * 4);
			$ipto = self!read32($handle, $baseaddr + ($mid + 1) * $dbcolumn * 4);
			if ($ipno >= $ipfrom) && ($ipno < $ipto) {

				my @return_vals;

				my @modes = $mode == $NUMBER_OF_FIELDS
					?? ( 0 .. $NUMBER_OF_FIELDS - 1 )
					!! $mode;

				for @modes -> $pos {

					if @POSITIONS[$pos][$dbtype] == 0 {
						push( @return_vals, $NOT_SUPPORTED );
					} else {
						if $pos == $LATITUDE or $pos == $LONGITUDE {

							push( @return_vals, sprintf( "%.6f",self!readFloat(
								$handle,
								$baseaddr + ( $mid * $dbcolumn * 4 ) + 4 * ( @POSITIONS[$pos][$dbtype] -1 )
							) ) ); 

						} else {

							my $return_val = self!readStr(
								$handle,
								$pos == $COUNTRY_LONG
									?? self!read32( $handle,$baseaddr + ( $mid * $dbcolumn * 4 ) + 4 * ( @POSITIONS[$pos][$dbtype] -1 ) ) +3
									!! self!read32( $handle,$baseaddr + ( $mid * $dbcolumn * 4 ) + 4 * ( @POSITIONS[$pos][$dbtype] -1 ) )
							);

							if $pos == $COUNTRY_SHORT && $return_val eq 'UK' {
								$return_val = 'GB';
							}

							push( @return_vals,$return_val );
						}
					}
				}

				return ( $mode == $NUMBER_OF_FIELDS ) ?? @return_vals !! @return_vals[0];

			} else {
				if $ipno < $ipfrom {
					$high = $mid - 1;
				} else {
					$low = $mid + 1;
				}
			}
		}

		$UNKNOWN;
	}

	method !read32 ( IO::Handle $handle, Int $position ) {
		$handle.seek($position-1, SeekFromBeginning);
		my $data = $handle.read(4);
		nativecast((int32), Blob.new($data));
	}

	method !read8 ( IO::Handle $handle, Int $position ) {
		$handle.seek($position-1, SeekFromBeginning);
		my $data = $handle.read(1);
		nativecast((int8), Blob.new($data));
	}

	method !readStr ( IO::Handle $handle, Int $position ) {
		$handle.seek($position, SeekFromBeginning);
		my $data = $handle.read(1);
		$handle.read(nativecast((int8), Blob.new($data))).decode;
	}

	method !readFloat ( IO::Handle $handle, Int $position ) {
		$handle.seek($position-1, SeekFromBeginning);
		my $data = $handle.read(4);

		my sub is-little-endian returns Bool {
		    my $i = CArray[uint32].new: 0x01234567;
		    my $j = nativecast(CArray[uint8], $i);
		    $j[0] == 0x67;
		}

		is-little-endian()
			?? nativecast((num32), Blob.new($data))
			!! nativecast((num32), Blob.new($data.reverse));
	}

}
