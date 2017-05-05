use v6;

use NativeCall;

constant LIB = 'primesieve';

constant PRIMESIEVE_ERROR = 18446744073709551615;

enum PRIMESIEVE <SHORT_PRIMES USHORT_PRIMES INT_PRIMES UINT_PRIMES
  LONG_PRIMES ULONG_PRIMES LONGLONG_PRIMES ULONGLONG_PRIMES
  INT16_PRIMES UINT16_PRIMES INT32_PRIMES UINT32_PRIMES INT64_PRIMES
  UINT64_PRIMES>;

class X::Math::Primesieve is Exception
{
    method message() { 'Math::Primesieve error' }
}

class Math::Primesieve does Positional
{
    sub primesieve_version() returns Str is native(LIB) {*}

    sub primesieve_generate_primes(uint64, uint64, size_t is rw, int32)
        returns Pointer is native(LIB) {*}

    sub primesieve_generate_n_primes(uint64, uint64, int32)
        returns Pointer is native(LIB) {*}

    sub primesieve_nth_prime(int64, uint64)
        returns uint64 is native(LIB) {*}

    sub primesieve_count_primes(uint64, uint64)
        returns uint64 is native(LIB) {*}

    sub primesieve_count_twins(uint64, uint64)
        returns uint64 is native(LIB) {*}

    sub primesieve_count_triplets(uint64, uint64)
        returns uint64 is native(LIB) {*}

    sub primesieve_count_quadruplets(uint64, uint64)
        returns uint64 is native(LIB) {*}

    sub primesieve_count_quintuplets(uint64, uint64)
        returns uint64 is native(LIB) {*}

    sub primesieve_count_sextuplets(uint64, uint64)
        returns uint64 is native(LIB) {*}

    sub primesieve_print_primes(uint64, uint64)
        returns uint64 is native(LIB) {*}

    sub primesieve_print_twins(uint64, uint64)
        returns uint64 is native(LIB) {*}

    sub primesieve_print_triplets(uint64, uint64)
        returns uint64 is native(LIB) {*}

    sub primesieve_print_quadruplets(uint64, uint64)
        returns uint64 is native(LIB) {*}

    sub primesieve_print_quintuplets(uint64, uint64)
        returns uint64 is native(LIB) {*}

    sub primesieve_print_sextuplets(uint64, uint64)
        returns uint64 is native(LIB) {*}

    sub primesieve_get_max_stop() returns uint64 is native(LIB) { * }

    sub primesieve_get_sieve_size() returns int32 is native(LIB) {*}

    sub primesieve_get_num_threads() returns int32 is native(LIB) {*}

    sub primesieve_set_sieve_size(int32) is native(LIB) {*}

    sub primesieve_set_num_threads(int32) is native(LIB) {*}

    sub primesieve_free(Pointer) is native(LIB) { * }

    method BUILD(:$num-threads, :$sieve-size)
    {
        primesieve_set_num_threads($num-threads) with $num-threads;

        primesieve_set_sieve_size($sieve-size) with $sieve-size;
    }

    method version() { primesieve_version }

    method max-stop() { primesieve_get_max_stop }

    method sieve-size($sieve-size?)
    {
        primesieve_set_sieve_size($sieve-size) with $sieve-size;

        primesieve_get_sieve_size;
    }

    method num-threads($num-threads?)
    {
        primesieve_set_num_threads($num-threads) with $num-threads;

        primesieve_get_num_threads;
    }

    method primes(UInt $start is copy, UInt $stop is copy = 0)
    {
        my size_t $size;

        unless $stop
        {
            $stop = $start;
            $start = 0;
        }

        my $p = primesieve_generate_primes($start, $stop, $size, UINT64_PRIMES);

        die X::Math::Primsieve.new if $p == PRIMESIEVE_ERROR;

        my @ret = nativecast(CArray[uint64], $p)[0 ..^ $size];

        primesieve_free($p);

        @ret;
    }

    method n-primes(UInt $n, UInt $start = 0)
    {
        my $p = primesieve_generate_n_primes($n, $start, UINT64_PRIMES);

        die X::Math::Primsieve.new if $p == PRIMESIEVE_ERROR;

        my @ret = nativecast(CArray[uint64], $p)[0 ..^ $n];

        primesieve_free($p);

        @ret;
    }

    method nth-prime(Int $n, UInt $start = 0)
    {
        primesieve_nth_prime($n, $start)
    }

    method AT-POS($n) { self.nth-prime($n) }

    method count(UInt $start is copy, UInt $stop is copy = 0,
                 :$twins, :$triplets, :$quadruplets, :$quintuplets, :$sextuplets)
    {
        unless $stop
        {
            $stop = $start;
            $start = 0;
        }

        return primesieve_count_twins($start, $stop)       if $twins;
        return primesieve_count_triplets($start, $stop)    if $triplets;
        return primesieve_count_quadruplets($start, $stop) if $quadruplets;
        return primesieve_count_quintuplets($start, $stop) if $quintuplets;
        return primesieve_count_sextuplets($start, $stop)  if $sextuplets;
        primesieve_count_primes($start, $stop)
    }

    method print(UInt $start is copy, UInt $stop is copy = 0,
                 :$twins, :$triplets, :$quadruplets,
                 :$quintuplets, :$sextuplets)
    {
        unless $stop
        {
            $stop = $start;
            $start = 0;
        }

        return primesieve_print_twins($start, $stop)       if $twins;
        return primesieve_print_triplets($start, $stop)    if $triplets;
        return primesieve_print_quadruplets($start, $stop) if $quadruplets;
        return primesieve_print_quintuplets($start, $stop) if $quintuplets;
        return primesieve_print_sextuplets($start, $stop)  if $sextuplets;
        primesieve_print_primes($start, $stop)
    }
}
