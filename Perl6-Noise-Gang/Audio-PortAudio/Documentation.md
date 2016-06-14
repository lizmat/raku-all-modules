NAME
====

Audio::PortAudio - Access to audio input and output devices

SYNOPSIS
========

    use Audio::PortAudio;

    my $pa = Audio::PortAudio.new;

    # get the default stream with no inputs, 2 output channels
    # for audio encoded as 32 bit floats at 44100 samplerate;
    my $stream = $pa.open-default-stream(0,2,Audio::PortAudio::Float32,44100);

    $stream.start;

    loop {
	    # get some audio data in a carray from somewhere
	    $stream.write($carray, $frame-count);
    }

See also the examples directory in the distribution

DESCRIPTION
===========

This module provides a mechanism to get audio into and out of your program via a sound card or some other sub-system supported by the Portaudio library (http://www.portaudio.com/), this may include "ALSA", "JACK" or "OSS" on Linux, "CoreAudio" on Mac and "ASIO" on Windows, (of course the actual support depends on how the library was built on your system.)

You will need to have the portaudio library installed on your system to use this, it may be available as a package or come pre-installed, but the details will be specific to your platform.

The interface is somewhat simplified in comparison to the underlying library and in particular only "blocking" IO is supported at the current time (though this does not preclude the use of the callback API in the future, it's just an interface that is natural to a Perl 6 developer doesn't suggest itself at the moment.)

It is important to note that the constraints of real-time audio data handling mean that you have to be careful that you allow for consistent and timely handing of the data to or from the device for proper results, you may find that for some applications you will need to avoid the use of any concurrency whatsoever for instance (the streaming example is such a case where the time budget was such that any unexpected garbage collection or other processor stealing activity didn't leave the process enough time spare to recover and the stream eventually became unusable.)

Also it should be noted that some types of source API ("JACK" in particular,) require that you use a fixed buffer size that is consistent with that configured for the host service, unfortunately portaudio doesn't appear to provide a way of discovering this so you may need to either check with the source configuration or experiment to find a correct and working value for buffer sizes. The symptoms of this may include choppy, "syncopated" or "phased" output.

This is based on the original work of Peschwa (https://github.com/peschwa/Audio-PortAudio) which I forked and then just completely hijacked when I realised it could be potentially be made useful :) So most of the credit probably goes to him.

METHODS
=======

method new
----------

    method new()

The constructor doesn't currently take any arguments. It will cause `initialize()` for you.

method version
--------------

    method version() returns Str

This returns the portaudio library version string that may be useful for diagnostic purposes.

method initialize
-----------------

    method initialize() returns Bool

This starts the portaudio service and will initialise all of the host API drivers found, which may (depending on the configuration,) cause the drivers to emit some output (typically ALSA and JACK will do this.) You probably don't need to call this yourself as it is called by the constructor, though may be necessary after  `terminate` if you didn't actually end your program. If there was a problem initializing the library then an exception will be thrown.

method terminate
----------------

    method terminate() returns Int

This ends the portaudio and will shutdown all the backends, calling any methods except `initialise()` after this will give rise to an exception.

method device-count
-------------------

    method device-count() returns Int

This returns the number of devices in the system.

method device-info
------------------

    method device-info(Int $device-number) returns DeviceInfo

This returns the `Audio::PortAudio::DeviceInfo` object for the device `index` which is in the range 0 to `device-count` exclusive. If the device index is out of range or there is some other error an exception will be thrown.

method devices
--------------

    method devices()

This is a convenience to return a lazy list of the devices as `Audio::PortAudio::DeviceInfo` objects, it may be useful to enumerate the devices but you will need to keep track of the index in order to be able to open a stream with a particular device.

method host-api-index
---------------------

    method host-api-index(HostApiTypeId $type) returns Int

This returns the index number of the host API as used in the `Audio::PortAudio::DeviceInfo` given the host API type, and can be used to enumerate devices of a certain type from the `devices` list. `HostApiTypeId` is an enumeration with the following values:

  * InDevelopment

  * DirectSound

  * MME

  * ASIO

  * SoundManager

  * CoreAudio

  * OSS

  * ALSA

  * AL

  * BeOS

  * WDMKS

  * JACK

  * WASAPI

  * AudioScienceHPI

It is unlikely that more than a couple of these will actually be available on any given system.

method host-api
---------------

    method host-api(HostApiTypeId $type) returns HostApiInfo

Given a `HostApiTypeId` as described above this will return a [Audio::PortAudio::HostApiInfo](#Audio::PortAudio::HostApiInfo) object that describes the host api on this system. 

method default-output-device
----------------------------

    method default-output-device() returns DeviceInfo

This returns a [Audio::PortAudio::DeviceInfo](#Audio::PortAudio::DeviceInfo) object that describes the device that will be used for output if the default output stream is asked for. Depending on the configuration of your system this may differ from the `default-input-device`. An exception will be thrown if there was a problem determining the device.

method default-input-device
---------------------------

    method default-input-device() returns DeviceInfo

This returns a [Audio::PortAudio::DeviceInfo](#Audio::PortAudio::DeviceInfo) object that describes the device that be used for input if the default input stream is asked for. Depending on the configuration of your system this may differ from the `default-outpur-device`. An exception will be thrown if there was a problem determining the device.

method open-default-stream
--------------------------

    method open-default-stream(Int $input = 0, Int $output = 2, StreamFormat $format = StreamFormat::Float32, Int $sample-rate = 44100, Int $frames-per-buffer = 256) returns Stream

This opens a stream for reading and/or writing on the default device, returning a [Audio::PortAudio::Stream](#Audio::PortAudio::Stream) object or throwing an exception if there was a problem opening the stream.

The default values will almost certainly **not** work for a lot of applications, of particular importance is `format` which should be a member of the enumeration [Audio::PortAudio::StreamFormat](#Audio::PortAudio::StreamFormat):

  * Float32

  * Int32 

  * Int24

  * Int16

  * Int8

  * UInt8

  * CustomFormat

  * NonInterleaved

Which should firstly match the capabilities of your device and also `must` match the bit-size and type of the data that is written, if this is not adhered to then you are likely to see segfaults or other memory violation errors. The `CustomFormat` is unlikely to be used unless you have created your own portaudio backend. The `NonInterleaved` value can be ORed (`+|`) with another value to tell the stream to expect the data as separate arrays of data for each channel rather than "interleaved" (samples for each channel in a "frame" appear consecutively in the data,) this may be more convenient for some applications especially with a high channel count.

The `$buffer-size` may also be critical for some backends (such as "JACK",) that require this to match the value configured in the backend and that all reads and writes are of the same size, you will need to consult the configuration of the backend to determine what this value should be. Some backends (such as ALSA,) on the other hand, don't seem to be quite as sensitive and this can be set to some value that your application can easily handle in the time available ( that is (buffer-size * channels)/samplerate seconds.) Supplying a value of 0 for buffer size will cause portaudio to adjust its own buffer to suit the calculated latency and throughput, thus allowing for reads and writes based on the available data, however this does not over-ride the earlier comments about fixed buffer sizes for some backends (it really doesn't work well with JACK for instance.)

The `$samplerate` should match the capabilities or configuration of your device and the samplerate of the data that is being written, if you pass data to `write` which does not match this it is unlikely to playback correctly (you may be able to use [Audio::Convert::Samplerate](https://github.com/jonathanstowe/Audio-Convert-Samplerate) to adjust this in your application.)

The `$input` and `$output` parameters indicate the number of channels to be opened for input and output respectively, 0 indicating that the stream will not be opened for either reading or writing. The value should match the number of channels present in the device (or a smaller value,) some devices may indicate a larger number of channels than are actually used or connected, if a smaller number of channels is requested than the device presents then they will be taken in the order that the backend supports them, there is no way of specifying a specific range of channels, though you could use the NonInterleaved option to format and ignore the channels you aren't interested in. The implication for backends that are explicitly designed for multi channel applications (such as JACK) is that you may not be able to distinguish named individual channels within the device. Sorry about that, but it appears to be a portaudio limitation.

method open-stream
------------------

    method open-stream(StreamParameters $in-params, StreamParameters $out-params, Int $sample-rate = 44100, Int $frames-per-buffer = 256) returns Stream

This returns the [Audio::PortAudio::Stream](#Audio::PortAudio::Stream) opened with the parameters supplied in the [Audio::PortAudio::StreamParameters](#Audio::PortAudio::StreamParameters) `$in-params` and `$out-params`, described below, if either input or output is not required then a StreamParameters type object can be passed for either parameter. `$sample-rate` and `$frames-per-buffer` is the same as for `open-default-stream` and apply to both input and output.

This will throw an exception if the stream cannot be opened with the parameters supplied, you can validate the parameters prior to making this call with `is-format-supported` described below.

method is-format-supported
--------------------------

    method is-format-supported(StreamParameters $input, StreamParameters $output, Int $sample-rate) returns Bool

This returns a Boolean to indicate whether the [Audio::PortAudio::StreamParameters](#Audio::PortAudio::StreamParameters) `$input` and `$output` and the sample rate would work for `open-stream`, if it returns False it is likely that `open-stream` would throw an exception with the same parameters.

method error-text
-----------------

    method error-text(Int $error-code) returns Str

This returns the appropriate error text for the integer code returned by the pulseaudio API calls, a negative number indicating that it is an error response. As most of the methods that call the portaudio API will infact throw an exception with the appropriate message this may not be all that useful.

Audio::PortAudio::DeviceInfo
============================

This is the class that describes the portaudio devices as discoverd by `devices` or `device-info`. It has the following members:

struct-version
--------------

This is the version of this API structure used, it probably isn't all that useful unless you somehow have mixed versions of backend and portaudio and things aren't working correctly.

name;
-----

This is the name of the device that will commonly be displayed in a user interface.

api-version;
------------

This is the `host-api-index` (not the host api type,) of the backend API that supports the device. See the `host-api` method to get details of the actual host API being used.

max-input-channels;
-------------------

This is the maximum number of input channels that the device reports, it should be noted that not all of the number may be usable or connected to a physical device as some drivers may, for instance, examine the underlying hardware to get this value and some of the potential inputs may not be physically connected (laptops with generic audio chips are an example of this,) however it is probably okay to request up to this number of channels, they just may not work.

max-output-channels
-------------------

The maximum output channels that the device reports. The same caveats apply as for `max-input-channels`.

default-low-input-latency
-------------------------

This is a suggested value for input latency for low latency applications, expressed as a Num fraction of a second. This can be used in a `StreamParameters`. Some backends such as "JACK" may report this (and the other latency values below,) as being 0 for "client" applications, in which case it might be necessary to use the appropriate value for the "default device" of the host API.

default-low-output-latency
--------------------------

This is a suggested value for output latency for low latency applications, expressed as a Num fraction of a second. This can be used in a `StreamParameters`.

default-high-input-latency;
---------------------------

This is a suggested value for input latency for high latency applications, expressed as a Num fraction of a second. This is possibly a better value for Perl applications which are likely to be "high latency".

default-high-output-latency
---------------------------

This is a suggested value for output latency for high latency applications, expressed as a Num fraction of a second. This is possibly a better value for Perl applications which are likely to be "high latency".

default-sample-rate;
--------------------

This is the default sample rate for the device and will probably be the one that you want to use when you are opening a stream on the device unless you definitely know that the device can adjust itself appropriately. The usual caveats about using the correct sample rate for input and output data apply. Portaudio expresses this as a floating point number ( a Num,) but will almost without exception be an Int. The `open-stream` and `open-default-stream` take `sample-rate` as an Int which will be coerced appropriately.

method host-api
---------------

    method host-api() returns HostApiInfo

This returns the [Audio::PortAudio::HostApiInfo](#Audio::PortAudio::HostApiInfo) object representing the host api of this device, which contains useful information about the backed API. 

Audio::PortAudio::HostApiInfo
=============================

This class represents the details of a host API or "backend" as returned by several methods described above.

struct-version
--------------

This is a version number that is internal to the portaudio implementation.

type
----

This is the HostApiTypeId and the value will be one of the enumeration described above.

name
----

This is the name of the host API, such as "ALSA", "JACK" etc.

device-count
------------

This is the number of devices that are recorded for this host API and could be used to enumerate the devices.

default-input-device
--------------------

This is the "device index" of the default input device for this backend, this can be used to get, for example, the default latency for a backend such as JACK that might not report the correct value for its clients, by passing this value to the `device-info` method of the [Audio::PortAudio](#Audio::PortAudio) object to get the appropriate [Audio::PortAudio::DeviceInfo](#Audio::PortAudio::DeviceInfo) object.

default-output-device 
----------------------

This is the "device index" of the default output device for this backend, this can be used to get, for example, the default latency for a backend such as JACK that might not report the correct value for its clients, by passing this value to the `device-info` method of the [Audio::PortAudio](#Audio::PortAudio) object to get the appropriate [Audio::PortAudio::DeviceInfo](#Audio::PortAudio::DeviceInfo) object. 

This will usually the same as the input device but this shouldn't be relied on.

Audio::PortAudio::StreamParameters
==================================

Objects of this class are passed as the `$in-params` and `$out-params` of the method `open-stream` and describe the details required of the input or outputs to be created. All of the attributes must be filled in unless otherwise noted. The validity or otherwise of a particular set of parameters can be checked with `` before actually using them to open a stream.

device
------

This is the "device index" of the required device (that is 0 .. device-count -1) The device should support the other parameters provided.

channel-count
-------------

This is the integer number of channels that should be opened on the stream for the input or output, it should be equal to or less than the maximum number of channels supported by the device.

sample-format
-------------

This is the integer value of an item of the enumeration `SampleFormat` described above, it should agree with the type of the data that you are intending to read from or write to the stream (otherwise unexpected results may ensue,) not all devices or backend APIs will support all format types and you may have to consult the documentation or configuration. The most commonly supported types are `Float32` and `Int16`.

suggested-latency
-----------------

This is the suggested latency for this stream as a Num fraction of a second. You probably want to used the device's <default-high-input-latency> or <default-high-output-latency> though some backends may entirely ignore this if they have a fixed latency value.

host-api-specific-streaminfo
----------------------------

This is a Pointer to some data that may be supplied to the backend, it is **not**  required by portaudio and should generally be left uninitialised.

Audio::PortAudio::Stream
========================

Objects of this type are returned by `open-default-stream` and `open-stream` and are the primary interface for reading and writing data from/to a device and for getting the status of the audio stream.

method start
------------

    method start() returns Bool

This starts the stream, making it available for reading or writing. Attempting to read or write without first calling start will give rise to an exception.

An exception will be thrown if the stream cannot be started.

method close
------------

    method close() returns Bool

This closes the stream, releasing the device. If any reads or writes are attempted after it has been closed then an exception will be thrown. You should always close a stream after you are done with it as the API will continue attempting to populate the underlying buffers until closed.

If you attempt to close any already closed stream an exception will be thrown.

method stopped
--------------

    method stopped() returns Bool

This returns a Bool to indicate whether the stream is running, it will return True before `start` has been called and after `close`.

method active
-------------

    method active() returns Bool

This returns a Bool to indicate whether the stream is running, it will return True after `start` has been called and before `close`.

method write-available
----------------------

    method write-available() returns Int

This returns the number of frames that can be written to the stream without the `write` call blocking, It may throw an exception if the stream isn't started or there was some other problem with the stream.

method write
------------

    method write(CArray $buf, Int $frames) returns Int

This writes the data in the provided CArray, which must contain data of the correct type as per the `StreamFormat` (e.g. num32, int16 etc,) and should contain `$frames` * `channels` elements.

The data must be written with a frequency such that the underlying buffer is kept filled, an exception will be thrown if the data isn't being fed fast enough and a "buffer under run" occurs before the next write.

For some backends which require a fixed buffer size the number of frames provided should match the buffer size provided when opening the stream, not doing so may result in less than ideal results.

If the stream isn't started or there is some other problem writing the data then an exception will be thrown.

It is deliberate that there is no sugared multi candidates for providing higher level Perl arrays with the data, as the overhead in copying the data will typically eat up too much time to keep the buffer filled. Hopefully this will change in the future.

method read-available
---------------------

    method read-available() returns Int

This returns the number of frames available to be read from a stream, it may return 0 if the stream isn't opened for input. It may throw an exception if there was some problem with the stream.

method read
-----------

    method read(Int $frames, Int $num-channels, Mu:U $type) returns CArray

This reads the specified number of frames of `$num-channels` from a stream that is opened for input, the number of channels should agree with that provided when opening the stream, and the `$type` should correspond to the type of the data that will be used for the `StreamFormat` (i.e. num32, int16, etc,). The CArray returned will be typed accordingly and will contain `$frames` * `$num-channels` elements.

If you do not read from the stream fast enough you may experience buffer over-runs, choppy input, or other artefacts, some backends may consider it fatal and an exception may be raised or the stream closed.

Usually you should be prepared to read the number of frames that were specified when the stream was opened, if the backend requires a specific number of frames for the buffer then this should always be used when reading from the stream.

If there is a problem reading, or the stream has been closed then an exception will be thrown.

method info
-----------

    method info() returns StreamInfo

This provides accurate information from the backend while the stream is actually running, it can be used for informational purposes or possibly to tune some computation, the [Audio::PortAudio::StreamInfo](#Audio::PortAudio::StreamInfo) class is described below.

Audio::PortAudio::StreamInfo
============================

This is the class that is returned by the `info` method of the Stream. It contains information from the backend while the stream is running.

struct-version
--------------

This is the internal version of the structure returned by the API.

input-latency
-------------

This is the calculated latency estimate for input from the backend, it may differ from that provided as the suggested latency when the stream was opened. If the stream was opened for output only this will be 0e0.

output-latency
--------------

This is the calculated latency estimate for output from the backend, it may differ from that provided as the suggested latency when the stream was opened. If the stream was opened for input only this will be 0e0.

sample-rate
-----------

This is the actual sample-rate that is being used by portaudio, this may differ from that provided to the stream open or reported in the device info if portaudio is aware of inaccuracies in the information determined from the hardware or configration and has adjusted it.
