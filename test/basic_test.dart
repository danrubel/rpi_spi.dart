import 'package:rpi_spi/rpi_spi.dart';
import 'package:rpi_spi/spi.dart';
import 'package:test/test.dart';

import '../example/mcp3008.dart';
import 'test_util.dart';

main() {
  final spi = RpiSpi();
  runTests(spi);
  test('dispose', () => spi.dispose());
}

runTests(Spi spi) {
  test('one factory', () async {
    await expectThrows(() => RpiSpi());
  });

  test('invalid controller', () async {
    await expectThrows(() => Mcp3008(spi, 7, 24));
  });

  test('invalid chipSelectPin', () async {
    await expectThrows(() => Mcp3008(spi, 0, 0));
  });
}
