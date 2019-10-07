import 'package:rpi_spi/rpi_spi.dart';
import 'package:test/test.dart';

import 'basic_test.dart' as basic;
import 'mcp3008_test.dart' as mcp3008;

main() {
  final spi = RpiSpi();
  group('basic', () => basic.runTests(spi));
  group('mcp3008', () => mcp3008.runTests(spi));
  test('dispose', () => spi.dispose());
}
