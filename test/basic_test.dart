import 'package:rpi_spi/rpi_spi.dart';
import 'package:test/test.dart';

import '../example/mcp3008.dart';
import 'test_util.dart';

void main() {
  late RpiSpi spi;

  setUpAll(() {
    spi = RpiSpi();
  });

  test('one factory', () async {
    await expectThrows(() => RpiSpi());
  });

  test('invalid controller', () async {
    await expectThrows(() => Mcp3008(spi, 7, 24));
  });

  test('invalid chipSelectPin', () async {
    await expectThrows(() => Mcp3008(spi, 0, 0));
  });

  test('read', () {
    var mcp3008 = Mcp3008(spi, 0, 24);
    var value = mcp3008.read(0);
    expect(value, greaterThan(0));
  });

  tearDownAll(() {
    spi.dispose();
  });
}
