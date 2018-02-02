use v6.c;
use Test;
use Algorithm::GooglePolylineEncoding;

plan 3;

my $encoded = q[_p~iF~ps|U_ulLnnqC_mqNvxq`@];

is decode-polyline( $encoded ), [ { :lat(38.5), :lon(-120.2) }, { :lat(40.7), :lon(-120.95) }, { :lat(43.252), :lon(-126.453) } ], "String decoded OK";

$encoded = q<yikzH{o`@zsHdP|nIsnBxiE{wFboBuxJwi@m|Sc_DonMmdGqcLqnLqcLycFpGonD~eBonCngJ|N`lWfyB~y]vnA|wFpnD~lE>;

is decode-polyline( $encoded ), [
    { 'lat'=>'51.67277', 'lon'=>'0.17166', },
    { 'lat'=>'51.62335', 'lon'=>'0.16891', },
    { 'lat'=>'51.5696',  'lon'=>'0.18677', },
    { 'lat'=>'51.53715', 'lon'=>'0.22659', },
    { 'lat'=>'51.51921', 'lon'=>'0.28702', },
    { 'lat'=>'51.52605', 'lon'=>'0.39413', },
    { 'lat'=>'51.55167', 'lon'=>'0.46829', },
    { 'lat'=>'51.5935',  'lon'=>'0.53558', },
    { 'lat'=>'51.66255', 'lon'=>'0.60287', },
    { 'lat'=>'51.69916', 'lon'=>'0.6015',  },
    { 'lat'=>'51.72724', 'lon'=>'0.58502', },
    { 'lat'=>'51.7502',  'lon'=>'0.52734', },
    { 'lat'=>'51.74765', 'lon'=>'0.40237', },
    { 'lat'=>'51.72809', 'lon'=>'0.24445', },
    { 'lat'=>'51.71533', 'lon'=>'0.20462', },
    { 'lat'=>'51.68724', 'lon'=>'0.17166', },
];

$encoded = q<kzxxHemkAamEvXu|BhjBm|@|nD{aBrb^vaArsFzkBhjDiNnPjLrnBhoBbyAzjIwXt_D_fB~dCgzGzdBwmIlTs_Ny|AgaKmrC_oD>;

is decode-polyline( $encoded ), [
    { 'lat' => '51.4143',  'lon' => '0.39139', },
    { 'lat' => '51.44727', 'lon' => '0.38727', },
    { 'lat' => '51.46738', 'lon' => '0.3701',  },
    { 'lat' => '51.47721', 'lon' => '0.34195', },
    { 'lat' => '51.49303', 'lon' => '0.18265', },
    { 'lat' => '51.48235', 'lon' => '0.14351', },
    { 'lat' => '51.46493', 'lon' => '0.1161',  },
    { 'lat' => '51.46738', 'lon' => '0.1133',  },
    { 'lat' => '51.46524', 'lon' => '0.09544', },
    { 'lat' => '51.44727', 'lon' => '0.08102', },
    { 'lat' => '51.39417', 'lon' => '0.08514', },
    { 'lat' => '51.36846', 'lon' => '0.10162', },
    { 'lat' => '51.34702', 'lon' => '0.14694', },
    { 'lat' => '51.33072', 'lon' => '0.2005',  },
    { 'lat' => '51.32729', 'lon' => '0.2774',  },
    { 'lat' => '51.3423',  'lon' => '0.3392',  },
    { 'lat' => '51.36589', 'lon' => '0.36736', },
];
