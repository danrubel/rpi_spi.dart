#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <fcntl.h>
#include <linux/spi/spidev.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

// === from wiringPiI2C.c ===

const static char *spiDev0  = "/dev/spidev0.0";
const static char *spiDev1  = "/dev/spidev0.1";

const static uint8_t  spiBPW   = 8;
const static uint16_t spiDelay = 0;

// === end from wiringPiI2C.c ===

// SPI Notes:
/// * https://elinux.org/RPi_SPI
/// * https://en.wikipedia.org/wiki/Serial_Peripheral_Interface
/// * https://www.kernel.org/doc/html/v4.16/driver-api/spi.html
/// * https://www.raspberrypi.org/documentation/hardware/raspberrypi/spi

extern "C" {
  // Setup the SPI device with the specified controller, chip select, speed, and mode.
  // Negative return values indicate an error.
  int64_t setupDevice(int64_t controller, int64_t chipSelect, int64_t speed, int64_t mode) {
    int64_t fd = open(chipSelect == 0 ? spiDev0 : spiDev1, O_RDWR);
    if (fd < 0) {
      return -1;
    } else if (ioctl(fd, SPI_IOC_WR_MODE, &mode) < 0) {
      return -2;
    } else if (ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &spiBPW) < 0) {
      return -3;
    } else if (ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed) < 0) {
      return -4;
    }
    return fd;
  }

  // Dispose of the SPI device and return 0 to indicate success.
  // Negative return values indicate an error.
  int64_t disposeDevice(int64_t fd) {
    if (close(fd) < 0) {
      return -1;
    }
    return 0;
  }

  // Send bytes to the device and receive the same number of bytes.
  // Negative return values indicate an error.
  int64_t writeThenRead(int64_t fd, int64_t speed, int64_t numBytes, uint8_t *listPtr) {
    struct spi_ioc_transfer spi;

    // From spidev.h:
    // Zero-initialize the structure, including currently unused fields,
    // to accommodate potential future updates.
    memset(&spi, 0, sizeof (spi));

    spi.tx_buf        = (unsigned long) listPtr;
    spi.rx_buf        = (unsigned long) listPtr;
    spi.len           = numBytes;
    spi.delay_usecs   = spiDelay;
    spi.speed_hz      = speed;
    spi.bits_per_word = spiBPW;

    return ioctl(fd, SPI_IOC_MESSAGE(1), &spi);
  }
}
