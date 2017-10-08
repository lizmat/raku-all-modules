/*
 *  Can't use the inlined ones without the stubs
 */
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>

#ifndef NULL
#define NULL 0
#endif

#include "i2c-dev.h"


/* returns an fd ioctld to the appropriate slave address or a negative number */

extern int rpi_dev_smbus_open(char *filename, int address) {
	int fd;
	int ir;

	fd = open(filename, O_RDWR);

	if ( fd >= 0 ) {
		if ( (ir = ioctl(fd, I2C_SLAVE, address)) < 0 ) {
			fd = ir;
		}
	}
	return fd;
}

extern __s32 rpi_dev_smbus_write_quick(int file, __u8 value) {
    return i2c_smbus_write_quick(file, value);
}

extern __s32 rpi_dev_smbus_read_byte(int file) {
    return i2c_smbus_read_byte(file);
}

extern __s32 rpi_dev_smbus_write_byte(int file, __u8 value) {
    return i2c_smbus_write_byte(file, value);
}

extern __s32 rpi_dev_smbus_read_byte_data(int file, __u8 command) {
    return i2c_smbus_read_byte_data(file, command);
}

extern __s32 rpi_dev_smbus_write_byte_data(int file, __u8 command, __u8 value) {
    return i2c_smbus_write_byte_data(file, command, value);
}

extern __s32 rpi_dev_smbus_read_word_data(int file, __u8 command) {
    return i2c_smbus_read_word_data(file, command);
}

extern __s32 rpi_dev_smbus_write_word_data(int file, __u8 command, __u16 value) {
    return i2c_smbus_write_word_data(file, command,  value);
}

extern __s32 rpi_dev_smbus_process_call(int file, __u8 command, __u16 value) {
    return i2c_smbus_process_call(file, command,  value);
}

extern __s32 rpi_dev_smbus_read_block_data(int file, __u8 command, __u8 *values) {
    return i2c_smbus_read_block_data(file, command, values);
}

extern __s32 rpi_dev_smbus_write_block_data(int file, __u8 command, __u8 length, __u8 *values) {
    return i2c_smbus_write_block_data(file, command, length, values);
}

extern __s32 rpi_dev_smbus_read_i2c_block_data(int file, __u8 command, __u8 length, __u8 *values) {
    return i2c_smbus_read_i2c_block_data(file, command, length, values);
}

extern __s32 rpi_dev_smbus_write_i2c_block_data(int file, __u8 command, __u8 length, __u8 *values) {
    return i2c_smbus_write_i2c_block_data(file, command, length, values);
}

extern __s32 rpi_dev_smbus_block_process_call(int file, __u8 command, __u8 length, __u8 *values) {
    return i2c_smbus_block_process_call(file, command, length, values);
}

