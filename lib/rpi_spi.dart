import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as ffi;
import 'package:rpi_spi/spi.dart';
import 'package:rpi_spi/src/native/rpi_spi_ext.dart';

/// The [Spi] interface used for accessing SPI devices on the Raspberry Pi.
class RpiSpi extends Spi {
  static bool _instantiatedSpi = false;

  final _devices = <RpiSpiDevice>[];
  final _dylib = _RpiSpiDynamicLibrary(findDynamicLibrary());

  RpiSpi() {
    if (_instantiatedSpi) throw SpiException('RpiSpi already instantiated');
    _instantiatedSpi = true;
  }

  @override
  SpiDevice device(int controller, int chipSelectPin, int speed, int mode) {
    if (mode < 0 || mode > 3)
      throw SpiException('Invalid mode: $mode', controller, chipSelectPin);
    var chipSelect = allocateChipSelectPin(controller, chipSelectPin);

    var fd = _dylib.setupDeviceMth(controller, chipSelect, speed, mode);
    if (fd < 0)
      throw SpiException('Device init failed: $fd', controller, chipSelectPin);

    final device = RpiSpiDevice(fd, controller, chipSelectPin, speed, _dylib);
    _devices.add(device);
    return device;
  }

  @override
  void dispose() {
    while (_devices.isNotEmpty) {
      var device = _devices.removeLast();
      var result = _dylib.disposeDeviceMth(device._fd);
      if (result != 0)
        throw SpiException('Dispose device failed for'
            ' controller ${device._controller}, cs pin ${device._chipSelectPin}: $result');
    }
  }
}

class RpiSpiDevice extends SpiDevice {
  final int _fd;
  final int _controller;
  final int _chipSelectPin;
  final int _speed;
  final _RpiSpiDynamicLibrary _dylib;

  RpiSpiDevice(this._fd, this._controller, this._chipSelectPin, this._speed,
      this._dylib);

  @override
  Uint8List send(List<int> txData) {
    if (txData.isEmpty || txData.length > 40)
      throw SpiException('Expected txData length between 1 and 40', _controller,
          _chipSelectPin);

    var buf = _dylib.byteBufferOfLen40;
    for (var index = 0; index < txData.length; index++) {
      buf.elementAt(index).value = txData[index];
    }

    var result = _dylib.writeThenReadMth(_fd, _speed, txData.length, buf);
    if (result < 0) throw SpiException('Send failed: $result');

    var rxData = Uint8List(txData.length);
    for (var index = 0; index < txData.length; index++) {
      rxData[index] = buf.elementAt(index).value;
    }
    return rxData;
  }
}

class _RpiSpiDynamicLibrary extends NativePgkLib {
  final byteBufferOfLen40 = ffi.malloc.allocate<ffi.Uint8>(40);

  _RpiSpiDynamicLibrary(ffi.DynamicLibrary dylib) : super(dylib);
}
