#!/usr/bin/env perl6

unit module Net::ZMQ::V4::LowLevel;
use v6;
use NativeCall;

constant ZMQ_LOW_LEVEL is export = 1;

constant ZMQ_LOW_LEVEL_FUNCTIONS_TESTED is export = <
				    zmq_version
				    zmq_errno
				    zmq_strerror
				    zmq_ctx_new
				    zmq_ctx_term
				    zmq_ctx_shutdown
				    zmq_ctx_get
				    zmq_ctx_set
				    zmq_socket
				    zmq_close
				    zmq_bind
				    zmq_unbind
				    zmq_connect
				    zmq_disconnect
				    zmq_send
				    zmq_recv
				    zmq_getsokopt
				    zmq_setsockopt
            zmq_msg_init
            zmq_msg_init_data
            zmq_msg_close
            zmq_msg_data
            zmq_msg_recv
            zmq_msg_send
						zmq_poll
				>;


my constant LIB = 'zmq';
#my constant LIB = '/home/docker/Downloads/zeromq-4.2.2/src/.libs/libzmq.so';

class zmq_msg_t is repr('CStruct') is export {
#  has CArray[uint64]                 $._; # unsigned char[64] _
# solution thanks to https://github.com/arnsholt/Net-ZMQ
	has int64 $._;
	has int64 $._1;
	has int64 $._2;
	has int64 $._3;
	has int64 $._4;
	has int64 $._5;
	has int64 $._6;
	has int64 $._7;

=begin c
    my $instances = 0;
    my $created = 0;
    method instances() { say "msg_t : $created instances created, $instances remaining"; $instances; }
    method created()   { $created }
    method DESTROY { 
		     --$instances
		    }# say .WHICH, " Destroyed" }
    method TWEAK   { 
		    { ++$created; ++$instances; }
		}# say .WHICH, " created"  }
=end c
=cut
#submethod TWEAK {
## Why Does this not work?
#    $!_ := CArray[uint64].new( [0,0,0,0,0,0,0,0] );
#  }

}

## int64: because Pointers are immutable in Perl6, assignments to
## array locations fail
class zmq_pollitem_t is repr('CStruct') is export {
	has int64   $.socket is rw;
	has int32   $.fd is rw;
	has int16   $.events is rw;
	has int16   $.revents is rw;
}

#-From zmq.h:461
#ZMQ_EXPORT int  zmq_poll (zmq_pollitem_t *items, int nitems, long timeout);
sub zmq_poll(Pointer[zmq_pollitem_t]
            ,int32
            ,long
             ) is native(LIB, v5) returns int32 is export { * }


class iovec is repr('CPointer') is export { * }

# ZMQ_EXPORT void zmq_version (int *major, int *minor, int *patch);
sub zmq_version(int32 is rw, int32 is rw, int32 is rw ) is native(LIB, v5) is export { * }

#-From zmq.h:197
#/*  This function retrieves the errno as it is known to 0MQ library. The goal */
#/*  of this function is to make the code 100% portable, including where 0MQ   */
#/*  compiled with certain CRT library (on Windows) is linked to an            */
#/*  application that uses different CRT library.                              */
#ZMQ_EXPORT int zmq_errno (void);

sub zmq_errno() is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:200
#/*  Resolves system errors and 0MQ errors to human-readable string.           */
#ZMQ_EXPORT const char *zmq_strerror (int errnum);
sub zmq_strerror(int32 $errnum ) is native(LIB, v5) returns Str is export { * }


#-From zmq.h:223
#ZMQ_EXPORT void *zmq_ctx_new (void);
sub zmq_ctx_new() is native(LIB, v5) returns Pointer is export { * }

#-From zmq.h:224
#ZMQ_EXPORT int zmq_ctx_term (void *context);
sub zmq_ctx_term(Pointer $context) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:225
#ZMQ_EXPORT int zmq_ctx_shutdown (void *context);
sub zmq_ctx_shutdown(Pointer $context) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:226
#ZMQ_EXPORT int zmq_ctx_set (void *context, int option, int optval);
sub zmq_ctx_set(Pointer
               ,int32
               ,int32
                ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:227
#ZMQ_EXPORT int zmq_ctx_get (void *context, int option);
sub zmq_ctx_get(Pointer
               ,int32
                ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:230
#/*  Old (legacy) API                                                          */
#ZMQ_EXPORT void *zmq_init (int io_threads);
sub zmq_init(int32 $io_threads # int
             ) is native(LIB, v5) returns Pointer is export { * }

#-From zmq.h:231
#ZMQ_EXPORT int zmq_term (void *context);
sub zmq_term(Pointer $context # void*
             ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:232
#ZMQ_EXPORT int zmq_ctx_destroy (void *context);
sub zmq_ctx_destroy(Pointer $context # void*
                    ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:259
#ZMQ_EXPORT int zmq_msg_init (zmq_msg_t *msg);
sub zmq_msg_init(zmq_msg_t $msg  is rw
                 ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:260
#ZMQ_EXPORT int zmq_msg_init_size (zmq_msg_t *msg, size_t size);
sub zmq_msg_init_size(zmq_msg_t  is rw
                     ,size_t
                      ) is native(LIB, v5) returns int32 is export { * }


#-From zmq.h:261
#ZMQ_EXPORT int zmq_msg_init_data (zmq_msg_t *msg, void *data, size_t size, zmq_free_fn *ffn, void *hint);
########################### PROBLEM

sub zmq_msg_init_data(zmq_msg_t
                     ,Pointer
                     ,size_t
                     ,Pointer = Pointer
                     ,Pointer = Pointer
                      ) is native(LIB, v5)
                      returns int32 is export { * }

sub zmq_msg_init_data_callback(zmq_msg_t
                     ,Pointer
                     ,size_t
                     ,&callback (OpaquePointer, OpaquePointer --> int32) # void (f )(void*,void*
                     ,Pointer = Pointer
                      )
                    is symbol('zmq_msg_init_data')
 is native(LIB, v5) returns int32 is export { * }



#-From zmq.h:263
#ZMQ_EXPORT int zmq_msg_send (zmq_msg_t *msg, void *s, int flags);
sub zmq_msg_send(zmq_msg_t is rw
                ,Pointer                       $s # void*
                ,int32                         $flags # int
                 ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:264
#ZMQ_EXPORT int zmq_msg_recv (zmq_msg_t *msg, void *s, int flags);
sub zmq_msg_recv(zmq_msg_t is rw
                ,Pointer
                ,int32
                 ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:265
#ZMQ_EXPORT int zmq_msg_close (zmq_msg_t *msg);
sub zmq_msg_close(zmq_msg_t is rw )
                   is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:266
#ZMQ_EXPORT int zmq_msg_move (zmq_msg_t *dest, zmq_msg_t *src);
sub zmq_msg_move(zmq_msg_t                     $dest # Typedef<zmq_msg_t>->|zmq_msg_t|*
                ,zmq_msg_t                     $src # Typedef<zmq_msg_t>->|zmq_msg_t|*
                 ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:267
#ZMQ_EXPORT int zmq_msg_copy (zmq_msg_t *dest, zmq_msg_t *src);
sub zmq_msg_copy(zmq_msg_t                     $dest # Typedef<zmq_msg_t>->|zmq_msg_t|*
                ,zmq_msg_t                     $src # Typedef<zmq_msg_t>->|zmq_msg_t|*
                 ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:268
#ZMQ_EXPORT void *zmq_msg_data (zmq_msg_t *msg);
sub zmq_msg_data(zmq_msg_t $msg is rw # Typedef<zmq_msg_t>->|zmq_msg_t|*
                 ) is native(LIB, v5) returns CArray[int8] is export { * }

#-From zmq.h:269
#ZMQ_EXPORT size_t zmq_msg_size (zmq_msg_t *msg);
sub zmq_msg_size(zmq_msg_t $msg # Typedef<zmq_msg_t>->|zmq_msg_t|*
                 ) is native(LIB, v5) returns size_t is export { * }

#-From zmq.h:270
#ZMQ_EXPORT int zmq_msg_more (zmq_msg_t *msg);
sub zmq_msg_more(zmq_msg_t $msg # Typedef<zmq_msg_t>->|zmq_msg_t|*
                 ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:271
#ZMQ_EXPORT int zmq_msg_get (zmq_msg_t *msg, int property);
sub zmq_msg_get(zmq_msg_t                     $msg # Typedef<zmq_msg_t>->|zmq_msg_t|*
               ,int32                         $property # int
                ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:272
#ZMQ_EXPORT int zmq_msg_set (zmq_msg_t *msg, int property, int optval);
sub zmq_msg_set(zmq_msg_t                     $msg # Typedef<zmq_msg_t>->|zmq_msg_t|*
               ,int32                         $property # int
               ,int32                         $optval # int
                ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:273
#ZMQ_EXPORT const char *zmq_msg_gets (zmq_msg_t *msg, const char *property);
sub zmq_msg_gets(zmq_msg_t                     $msg # Typedef<zmq_msg_t>->|zmq_msg_t|*
                ,Str                           $property # const char*
                 ) is native(LIB, v5) returns Str is export { * }

#-From zmq.h:422
#ZMQ_EXPORT void *zmq_socket (void *, int type);
sub zmq_socket(Pointer                        # void*
              ,int32                         $type # int
               ) is native(LIB, v5) returns Pointer is export { * }

#-From zmq.h:423
#ZMQ_EXPORT int zmq_close (void *s);
sub zmq_close(Pointer $s # void*
              ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:424
#ZMQ_EXPORT int zmq_setsockopt (void *s, int option, const void *optval, size_t optvallen);
#ZMQ_EXPORT int zmq_getsockopt (void *s, int option, void *optval, size_t *optvallen);

sub zmq_setsockopt(Pointer, int32, buf8, size_t)
    is native(LIB, v5)
    returns int32
    is export { * }

sub zmq_setsockopt_int64(Pointer, int32, CArray[int64], size_t)
    is native( LIB, v5)
    is symbol('zmq_setsockopt')
    returns int32
    is export  { * }

sub zmq_setsockopt_int32(Pointer, int32, CArray[int32], size_t)
    is native( LIB, v5)
    is symbol('zmq_setsockopt')
    returns int32
    is export  { * }


#-From zmq.h:426
#ZMQ_EXPORT int zmq_getsockopt (void *s, int option, void *optval, size_t *optvallen);
sub zmq_getsockopt(Pointer, int32, buf8 is rw, size_t is rw )
    is native(LIB, v5)
    returns int32
    is export { * }

sub zmq_getsockopt_int64(Pointer, int32, int64 is rw, size_t is rw)
    is native( LIB, v5)
    is symbol('zmq_getsockopt')
    returns int32
    is export  { * }

sub zmq_getsockopt_int32(Pointer, int32, int32 is rw, size_t is rw)
    is native( LIB, v5)
    is symbol('zmq_getsockopt')
    returns int32
    is export  { * }


#-From zmq.h:428
#ZMQ_EXPORT int zmq_bind (void *s, const char *addr);
sub zmq_bind(Pointer                       $s # void*
            ,Str                           $addr # const char*
             ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:429
#ZMQ_EXPORT int zmq_connect (void *s, const char *addr);
sub zmq_connect(Pointer                       $s # void*
               ,Str                           $addr # const char*
                ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:430
#ZMQ_EXPORT int zmq_unbind (void *s, const char *addr);
sub zmq_unbind(Pointer                       $s # void*
              ,Str                           $addr # const char*
               ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:431
#ZMQ_EXPORT int zmq_disconnect (void *s, const char *addr);
sub zmq_disconnect(Pointer                       $s # void*
                  ,Str                           $addr # const char*
                   ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:432
#ZMQ_EXPORT int zmq_send (void *s, const void *buf, size_t len, int flags);
sub zmq_send(Pointer                       $s # void*
            ,buf8                          $buf # const void*
            ,size_t                        $len # Typedef<size_t>->|long unsigned int|
            ,int32                         $flags # int
             ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:433
#ZMQ_EXPORT int zmq_send_const (void *s, const void *buf, size_t len, int flags);
sub zmq_send_const(Pointer                       $s # void*
                  ,buf8                       $buf # const void*
                  ,size_t                        $len # Typedef<size_t>->|long unsigned int|
                  ,int32                         $flags # int
                   ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:434
#ZMQ_EXPORT int zmq_recv (void *s, void *buf, size_t len, int flags);
sub zmq_recv(Pointer                       $s # void*
            ,buf8                       $buf is rw   # void*
            ,size_t                        $len # Typedef<size_t>->|long unsigned int|
            ,int32                         $flags # int
             ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:435
#ZMQ_EXPORT int zmq_socket_monitor (void *s, const char *addr, int events);
sub zmq_socket_monitor(Pointer                       $s # void*
                      ,Str                           $addr # const char*
                      ,int32                         $events # int
                       ) is native(LIB, v5) returns int32 is export { * }


#-From zmq.h:467
#ZMQ_EXPORT int zmq_proxy (void *frontend, void *backend, void *capture);
sub zmq_proxy(Pointer                       $frontend # void*
             ,Pointer                       $backend # void*
             ,Pointer                       $capture # void*
              ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:468
#ZMQ_EXPORT int zmq_proxy_steerable (void *frontend, void *backend, void *capture, void *control);
sub zmq_proxy_steerable(Pointer                       $frontend # void*
                       ,Pointer                       $backend # void*
                       ,Pointer                       $capture # void*
                       ,Pointer                       $control # void*
                        ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:475
##define ZMQ_HAS_CAPABILITIES 1
#ZMQ_EXPORT int zmq_has (const char *capability);
sub zmq_has(Str $capability # const char*
            ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:483
#/*  Deprecated methods */
#ZMQ_EXPORT int zmq_device (int type, void *frontend, void *backend);
sub zmq_device(int32                         $type # int
              ,Pointer                       $frontend # void*
              ,Pointer                       $backend # void*
               ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:484
#ZMQ_EXPORT int zmq_sendmsg (void *s, zmq_msg_t *msg, int flags);
sub zmq_sendmsg(Pointer                       $s # void*
               ,zmq_msg_t                     $msg # Typedef<zmq_msg_t>->|zmq_msg_t|*
               ,int32                         $flags # int
                ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:485
#ZMQ_EXPORT int zmq_recvmsg (void *s, zmq_msg_t *msg, int flags);
sub zmq_recvmsg(Pointer                       $s # void*
               ,zmq_msg_t                     $msg # Typedef<zmq_msg_t>->|zmq_msg_t|*
               ,int32                         $flags # int
                ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:487
#ZMQ_EXPORT int zmq_sendiov (void *s, struct iovec *iov, size_t count, int flags);
sub zmq_sendiov(Pointer                       $s # void*
               ,iovec                         $iov # iovec*
               ,size_t                        $count # Typedef<size_t>->|long unsigned int|
               ,int32                         $flags # int
                ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:488
#ZMQ_EXPORT int zmq_recviov (void *s, struct iovec *iov, size_t *count, int flags);
sub zmq_recviov(Pointer                       $s # void*
               ,iovec                         $iov # iovec*
               ,Pointer[size_t]               $count # Typedef<size_t>->|long unsigned int|*
               ,int32                         $flags # int
                ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:495
#/*  Encode data with Z85 encoding. Returns encoded data                       */
#ZMQ_EXPORT char *zmq_z85_encode (char *dest, const uint8_t *data, size_t size);
sub zmq_z85_encode(Str                           $dest # char*
                  ,Pointer		         $data # const Typedef<uint8_t>->|unsigned char|*
                  ,size_t                        $size # Typedef<size_t>->|long unsigned int|
                   ) is native(LIB, v5) returns Str is export { * }

#-From zmq.h:498
#/*  Decode data with Z85 encoding. Returns decoded data                       */
#ZMQ_EXPORT uint8_t *zmq_z85_decode (uint8_t *dest, const char *string);
sub zmq_z85_decode(Pointer	                $dest # Typedef<uint8_t>->|unsigned char|*
                  ,Str                          $string # const char*
                   ) is native(LIB, v5) returns Pointer is export { * }

#-From zmq.h:502
#/*  Generate z85-encoded public and private keypair with tweetnacl/libsodium. */
#/*  Returns 0 on success.                                                     */
#ZMQ_EXPORT int zmq_curve_keypair (char *z85_public_key, char *z85_secret_key);
sub zmq_curve_keypair(Str                           $z85_public_key # char*
                     ,Str                           $z85_secret_key # char*
                      ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:506
#/*  Derive the z85-encoded public key from the z85-encoded secret key.        */
#/*  Returns 0 on success.                                                     */
#ZMQ_EXPORT int zmq_curve_public (char *z85_public_key, const char *z85_secret_key);
sub zmq_curve_public(Str                           $z85_public_key # char*
                    ,Str                           $z85_secret_key # const char*
                     ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:512
#ZMQ_EXPORT void *zmq_atomic_counter_new (void);
sub zmq_atomic_counter_new(
                           ) is native(LIB, v5) returns Pointer is export { * }

#-From zmq.h:513
#ZMQ_EXPORT void zmq_atomic_counter_set (void *counter, int value);
sub zmq_atomic_counter_set(Pointer                       $counter # void*
                          ,int32                         $value # int
                           ) is native(LIB, v5)  is export { * }

#-From zmq.h:514
#ZMQ_EXPORT int zmq_atomic_counter_inc (void *counter);
sub zmq_atomic_counter_inc(Pointer $counter # void*
                           ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:515
#ZMQ_EXPORT int zmq_atomic_counter_dec (void *counter);
sub zmq_atomic_counter_dec(Pointer $counter # void*
                           ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:516
#ZMQ_EXPORT int zmq_atomic_counter_value (void *counter);
sub zmq_atomic_counter_value(Pointer $counter # void*
                             ) is native(LIB, v5) returns int32 is export { * }

#-From zmq.h:517
#ZMQ_EXPORT void zmq_atomic_counter_destroy (void **counter_p);
sub zmq_atomic_counter_destroy(Pointer[Pointer] $counter_p # void**
                               ) is native(LIB, v5)  is export { * }

#-From zmq.h:530
#/*  Starts the stopwatch. Returns the handle to the watch.                    */
#ZMQ_EXPORT void *zmq_stopwatch_start (void);
sub zmq_stopwatch_start(
                        ) is native(LIB, v5) returns Pointer is export { * }

#-From zmq.h:534
#/*  Stops the stopwatch. Returns the number of microseconds elapsed since     */
#/*  the stopwatch was started.                                                */
#ZMQ_EXPORT unsigned long zmq_stopwatch_stop (void *watch_);
sub zmq_stopwatch_stop(Pointer $watch_ # void*
                       ) is native(LIB, v5) returns ulong is export { * }

#-From zmq.h:537
#/*  Sleeps for specified number of seconds.                                   */
#ZMQ_EXPORT void zmq_sleep (int seconds_);
sub zmq_sleep(int32 $seconds_ # int
              ) is native(LIB, v5)  is export { * }

#-From zmq.h:542
#/* Start a thread. Returns a handle to the thread.                            */
#ZMQ_EXPORT void *zmq_threadstart (zmq_thread_fn* func, void* arg);
sub zmq_threadstart(Pointer			  $func # Typedef<zmq_thread_fn>->|F:void ( )|*
                   ,Pointer                       $arg # void*
                    ) is native(LIB, v5) returns Pointer is export { * }

#-From zmq.h:545
#/* Wait for thread to complete then free up resources.                        */
#ZMQ_EXPORT void zmq_threadclose (void* thread);
sub zmq_threadclose(Pointer $thread # void*
                    ) is native(LIB, v5)  is export { * }

## Externs
