import 'dart:typed_data';

/// Base SPI interface supported by all SPI implementations.
///
/// Resources
/// * https://elinux.org/RPi_SPI
/// * https://en.wikipedia.org/wiki/Serial_Peripheral_Interface
/// * https://www.kernel.org/doc/html/v4.16/driver-api/spi.html
/// * https://www.raspberrypi.org/documentation/hardware/raspberrypi/spi
abstract class Spi {
  final _allocatedChipSelectPins = <int>[];

  /// Check that the pin can be used for chip select with the specified
  /// controller and return the chip select.
  /// Throw an exception if the pin has already been allocated
  /// or if the controller chip select combination is invalid.
  /// This should be called by subclasses not clients.
  int allocateChipSelectPin(int controller, int chipSelectPin) {
    if (_allocatedChipSelectPins.contains(chipSelectPin)) {
      throw SpiException('Already allocated', controller, chipSelectPin);
    }
    var chipSelect = -1;
    const chipSelectIndexes = [
      /* controller 0 */ [24, 26],
      /* controller 1 */ // [12, 11, 36], not supported
    ];
    if (controller >= 0 && controller < chipSelectIndexes.length) {
      chipSelect = chipSelectIndexes[controller].indexOf(chipSelectPin);
    }
    if (chipSelect == -1) {
      throw SpiException('invalid controller chip select combination',
          controller, chipSelectPin);
    }
    _allocatedChipSelectPins.add(chipSelectPin);
    return chipSelect;
  }

  /// Return the [SpiDevice] for communicating with the device
  /// over the specified controller and chip select,
  /// with the given [speed] and [mode].
  ///
  /// [controller] is the number of the SPI controller to which the device
  /// is connected. The Pi has 2 controllers, 0 and 1.
  /// Controller 0 is available for use on all Pi models while
  /// controller 1 is available on Pis with the expanded 40 pin header.
  ///
  /// [chipSelectPin] is the physical pin number used by the controller
  /// to select the device for communication.
  /// Controller 0 has two chip select pins (physical pins 24 and 26) while
  /// controller 1 has three (physical pins 11, 12 and 36).
  ///
  /// [speed] is the desired data exchange rate in Hz, for example
  /// 5000000 would be requesting a speed of 5 MHz.
  /// The actual speed is based on a 2 based division of the core clock
  /// and would typically be slightly less than the requested speed.
  /// Devices typically have a range of speeds at which they can communicate.
  ///
  /// [mode] is a one of the following:
  /// *	SPI_MODE_0 0x00 = SPI_CPHA 0 & SPI_CPOL 0
  /// *	SPI_MODE_1 0x01 = SPI_CPHA 1 & SPI_CPOL 0
  /// *	SPI_MODE_2 0x02 = SPI_CPHA 0 & SPI_CPOL 1
  /// *	SPI_MODE_3 0x03 = SPI_CPHA 1 & SPI_CPOL 1
  /// where
  /// *	SPI_CPHA = bit 0x01 - clock phase
  /// *	SPI_CPOL = bit 0x02 - clock polarity
  /// Different devices require different modes for proper communication.
  /// There are several other `mode` flags not supported at this time.
  /// See spi_device in https://www.kernel.org/doc/html/v4.16/driver-api/spi.html
  SpiDevice device(int controller, int chipSelectPin, int speed, int mode);

  /// Call dispose before exiting your application to cleanup native resources.
  void dispose();
}

/// A SPI device.
abstract class SpiDevice {
  /// Send the specified bytes to the device
  /// and return an identical number of bytes sent from the device.
  Uint8List send(List<int> data);
}

/// Exceptions thrown by I2C.
class SpiException {
  final String message;
  final int? controller;
  final int? chipSelectPin;

  SpiException(this.message, [this.controller, this.chipSelectPin]);

  @override
  String toString() {
    final msg = StringBuffer('SpiException($message');
    if (controller != null) msg.write(', controller: $controller');
    if (chipSelectPin != null) msg.write(', chipSelectPin: $chipSelectPin');
    msg.write(')');
    return msg.toString();
  }
}
