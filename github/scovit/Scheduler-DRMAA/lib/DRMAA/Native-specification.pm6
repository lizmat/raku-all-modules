use v6.d.PREVIEW;
unit module DRMAA::Native-specification:ver<0.0.1>:auth<Vittore F Scolari (vittore.scolari@gmail.com)>;

enum DRMAA::Native-specification::Providables is export <Dependencies>; 

role DRMAA::Native-specification {
    method provides(--> List) { ... };
}

our @Builtin-specifications =
    "DRMAA::Native-specification::SLURM",      /^SLURM/,
    "DRMAA::Native-specification::Default",    /.*/;
