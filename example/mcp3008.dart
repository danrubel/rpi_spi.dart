import 'package:rpi_spi/spi.dart';

/// MCP3008 - 8-Channel 10-Bit A/D Converters.
/// See https://cdn-shop.adafruit.com/datasheets/MCP3008.pdf
class Mcp3008 {
  /// The device speed can range from 50kHz to 1 MHz.
  static const defaultSpeed = 500000; // 500 kHz

  final SpiDevice device;

  Mcp3008(Spi spi, int controller, int chipSelectPin,
      [int speed = defaultSpeed])
      : device = spi.device(controller, chipSelectPin, speed, 0);

  /// Return a value between 0x0 and 0x03FF representing the analog value
  /// for the specified channel.
  int read(int channel) {
    var cmd = 0x80 | ((channel & 0x07) << 4);
    final result = device.send(<int>[0x00, 0x01, cmd, 0x00]);
    return (result[2] << 8) + result[3];
  }
}
