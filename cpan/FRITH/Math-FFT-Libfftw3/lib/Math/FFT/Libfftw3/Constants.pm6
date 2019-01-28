use v6;

unit module Math::FFT::Libfftw3::Constants:ver<0.1.2>:auth<cpan:FRITH>;

constant FFTW_FORWARD         is export = -1;
constant FFTW_BACKWARD        is export =  1;

constant FFTW_MEASURE         is export =  0;
constant FFTW_DESTROY_INPUT   is export =  1 +<  0;
constant FFTW_UNALIGNED       is export =  1 +<  1;
constant FFTW_CONSERVE_MEMORY is export =  1 +<  2;
constant FFTW_EXHAUSTIVE      is export =  1 +<  3;
constant FFTW_PRESERVE_INPUT  is export =  1 +<  4;
constant FFTW_PATIENT         is export =  1 +<  5;
constant FFTW_ESTIMATE        is export =  1 +<  6;
constant FFTW_WISDOM_ONLY     is export =  1 +< 21;

enum fftw_r2r_kind is export <FFTW_R2HC FFTW_HC2R FFTW_DHT
                              FFTW_REDFT00 FFTW_REDFT01 FFTW_REDFT10 FFTW_REDFT11
                              FFTW_RODFT00 FFTW_RODFT01 FFTW_RODFT10 FFTW_RODFT11>;

constant TYPE-ERROR          is export = 1;
constant DIRECTION-ERROR     is export = 2;
constant NO-DIMS             is export = 3;
constant FILE-ERROR          is export = 4;
constant DIMS-ERROR          is export = 5;
constant KIND-ERROR          is export = 6;

constant OUT-COMPLEX         is export = 0;
constant OUT-REIM            is export = 1;
constant OUT-NUM             is export = 2;
