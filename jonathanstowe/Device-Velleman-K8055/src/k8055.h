/* k8055 driver for libusb-1.0

 Copyright (c) 2012 by Jakob Odersky
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
 derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 Thanks to the following people who wrote the original version of `libk8055'
 (http://libk8055.sourceforge.net/), without their useful comments this
 library would not have been possible:

 2005 by Sven Lindberg <k8055@k8055.mine.nu>

 2007 by Pjetur G. Hjaltason <pjetur@pjetur.net>
 Commenting, general rearrangement of code, bugfixes,
 python interface with swig and simple k8055 python class

 The comments explaining the data packets and debounce time conversion
 (in the source file) are from them.
*/

#ifndef K8055_H_
#define K8055_H_

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct k8055_device k8055_device;

enum k8055_error_code {
	K8055_SUCCESS = 0, K8055_ERROR = -1, K8055_ERROR_INIT_LIBUSB = -2, /* error during libusb initialization */
	K8055_ERROR_NO_DEVICES = -3, /* no usb devices found on host machine */
	K8055_ERROR_NO_K8055 = -4, /* Velleman k8055 cannot be found (on given port) */
	K8055_ERROR_ACCESS = -6, /* access denied (insufficient permissions) */
	K8055_ERROR_OPEN = -7, /* error opening device handle (also applies for claiming and detaching kernel driver) */
	K8055_ERROR_CLOSED = -8, /* device is already closed */
	K8055_ERROR_WRITE = -9, /* write error */
	K8055_ERROR_READ = -10, /* read error */
	K8055_ERROR_INDEX = -11, /* invalid argument (i.e. trying to access analog channel >= 2) */
	K8055_ERROR_MEM = -12 /* memory allocation error */
};

void k8055_debug(bool value);

/**Opens a K8055 device on the given port (i.e. address).
 * @return 0 on success
 * @return K8055_ERROR_INDEX if port is an invalid index
 * @return K8055_ERROR_INIT_LIBUSB on libusb initialization error
 * @return K8055_ERROR_NO_DEVICES if no usb devices are found on host system
 * @return K8055_ERROR_NO_K8055 if no K8055 board is found at the given port
 * @return K8055_ERROR_ACCESS if permission is denied to access a usb port
 * @return K8055_ERROR_OPEN if another error occured preventing the board to be opened
 * @return K8055_ERROR_MEM if memory could not be allocated for device */
int k8055_open_device(int port, k8055_device** device);

/** Closes the given device. */
void k8055_close_device(k8055_device* device);

/**Sets all digital ouputs according to the given bitmask.
 * @param device k8055 board
 * @param bitmask '1' for 'on', '0' for 'off'
 * @return K8055_ERROR_CLOSED if the given device is not open
 * @return K8055_ERROR_WRITE if another error occurred during the write process */
int k8055_set_all_digital(k8055_device* device, int bitmask);

/**Sets a digital output at given channel.
 * @param device k8055 board
 * @param channel channel of port
 * @param value output status: 'true' for on, 'false' for off
 * @return K8055_ERROR_CLOSED if the given device is not open
 * @return K8055_ERROR_WRITE if another error occurred during the write process */
int k8055_set_digital(k8055_device* device, int channel, bool value);

/**Sets the values of both analog outputs.
 * @param device k8055 board
 * @param analog0 value of first analog output
 * @param analog1 value of second analog output
 * @return K8055_ERROR_CLOSED if the given device is not open
 * @return K8055_ERROR_WRITE if another error occurred during the write process */
int k8055_set_all_analog(k8055_device* device, int analog0, int analog1);

/**Sets the value for an analog output at a given channel.
 * @param device k8055 board
 * @param channel channel of analog output (zero indexed)
 * @param value value of analog output [0-255]
 * @return K8055_ERROR_INDEX if channel is an invalid index
 * @return K8055_ERROR_CLOSED if the given device is not open
 * @return K8055_ERROR_WRITE if another error occurred during the write process */
int k8055_set_analog(k8055_device* device, int channel, int value);

/**Resets a hardware integrated counter of the Velleman K8055 board.
 * @param device k8055 board
 * @param counter index of counter (zero indexed)
 * @return K8055_ERROR_INDEX if counter is an invalid index
 * @return K8055_ERROR_CLOSED if the given device is not open
 * @return K8055_ERROR_WRITE if another error occurred during the write process */
int k8055_reset_counter(k8055_device* device, int counter);

/**Sets the debounce time of a hardware integrated counter of the Velleman K8055 board.
 * @param device k8055 board
 * @param counter index of counter (zero indexed)
 * @param debounce debounce value
 * @return K8055_ERROR_INDEX if counter is an invalid index
 * @return K8055_ERROR_CLOSED if the given device is not open
 * @return K8055_ERROR_WRITE if another error occurred during the write process*/
int k8055_set_debounce_time(k8055_device* device, int counter, int debounce);

/**Reads all current data of a given board into the passed parameters. NULL is a valid parameter.
 * Unless quick is set, data is read twice from the board to circumvent some kind of buffer and get current data.
 * @param device k8055 board
 * @param digitalBitmask bitmask value of digital inputs (there are 5 digital inputs)
 * @param analog0 value of first analog input
 * @param analog1 value of second analog input
 * @param counter0 value of first counter
 * @param counter1 value of second counter
 * @param quick if set, read data only once
 * @return 0 on success
 * @return K8055_ERROR_CLOSED if the given device is not open
 * @return K8055_ERROR_READ if another error occurred during the read process */
int k8055_get_all_input(k8055_device* device, int *digitalBitmask, int *analog0,
		int *analog1, int *counter0, int *counter1, bool quick);
		
/**Gets a given board's current output status. NULL is a valid parameter.
 * Note: as the K8055's firmware does not provide any method for querying the board's output status,
 * this library only tracks the board's status by recording any successfull data writes.
 * Hence no guarantee can be given on the validity of the output status.
 * @param device k8055 board
 * @param digitalBitmask bitmask value of digital outputs (there are 8 digital outputs)
 * @param analog0 value of first analog output
 * @param analog1 value of second analog output
 * @param debounce0 value of first counter's debounce time [ms]
 * @param debounce1 value of second counter's debounce time [ms] */
void k8055_get_all_output(k8055_device* device, int* digitalBitmask, int *analog0,
		int *analog1, int *debounce0, int *debounce1);

#ifdef __cplusplus
}
#endif 

#endif /* K8055_H_ */
