import 'dart:typed_data';

import 'package:rpi_spi/spi.dart';

import 'dart-ext:rpi_spi_ext';

/// The [Spi] interface used for accessing SPI devices on the Raspberry Pi.
class RpiSpi extends Spi {
  static bool _instantiatedSpi = false;

  final _devices = <RpiSpiDevice>[];

  RpiSpi() {
    if (_instantiatedSpi) throw new SpiException('RpiSpi already instantiated');
    _instantiatedSpi = true;
  }

  @override
  SpiDevice device(int controller, int chipSelectPin, int speed, int mode) {
    if (mode < 0 || mode > 3) {
      throw new SpiException('invalid mode: $mode', controller, chipSelectPin);
    }
    int chipSelect = allocateChipSelectPin(controller, chipSelectPin);
    int fd = _setupDevice(controller, chipSelect, speed, mode);
    if (fd < 0) {
      throw new SpiException(
          'device init failed: $fd', controller, chipSelectPin);
    }
    final device = new RpiSpiDevice(fd, speed);
    _devices.add(device);
    return device;
  }

  @override
  void dispose() {
    while (_devices.isNotEmpty) {
      int result = _disposeDevice(_devices.removeLast()._fd);
      if (result != 0) throw new SpiException('dispose failed: $result');
    }
  }

  int _setupDevice(int controller, int chipSelect, int speed, int mode)
      native "setupDevice";
  int _disposeDevice(int fd) native "disposeDevice";
}

class RpiSpiDevice extends SpiDevice {
  final int _fd;
  final int _speed;

  RpiSpiDevice(this._fd, this._speed);

  @override
  Uint8List send(List<int> txData) {
    if (txData.length > 40) throw new SpiException('max data len 40 bytes');
    Uint8List rxData = new Uint8List(txData.length);
    int result = _send(_fd, _speed, txData, rxData, txData.length);
    if (result < 0) {
      throw new SpiException('send failed: $result');
    }
    return rxData;
  }

  int _send(int fd, int speed, List<int> data, Uint8List response, int len)
      native "send";
}
