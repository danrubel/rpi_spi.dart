import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/rpi_gpio.dart';
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

void runTests(Spi spi) {
  Mcp3008 mcp3008;
  Gpio gpio;
  GpioOutput pin13;
  GpioOutput pin15;

  setUpAll(() {
    // For these tests:
    // * pin 13 is connected to MCP3008 by a 4.7K resistor
    // * pin 15 is connected to MCP3008 by a 10K resistor.
    gpio = RpiGpio();
    pin13 = gpio.output(13);
    pin15 = gpio.output(15);
  });

  tearDownAll(() {
    gpio.dispose();
  });

  test('instantiate once', () async {
    mcp3008 = Mcp3008(spi, 0, 24);
    await expectThrows(() => Mcp3008(spi, 0, 24));
  });

  test('read low', () {
    pin13.value = false;
    pin15.value = false;
    int value = mcp3008.read(0);
    print('  value read: $value');
    expect(value, betweenInclusive(0, 10));
  });

  test('read 1/3', () {
    pin13.value = false;
    pin15.value = true;
    int value = mcp3008.read(0);
    print('  value read: $value');
    expect(value, betweenInclusive(300, 350));
  });

  test('read 2/3', () {
    pin13.value = true;
    pin15.value = false;
    int value = mcp3008.read(0);
    print('  value read: $value');
    expect(value, betweenInclusive(670, 720));
  });

  test('read high', () {
    pin13.value = true;
    pin15.value = true;
    int value = mcp3008.read(0);
    print('  value read: $value');
    expect(value, betweenInclusive(1013, 1023));
  });
}

/// Returns a matcher which matches if the match argument
/// is greater than or equal to the given [lower] value
/// and is less than or equal to the given [upper] value.
Matcher betweenInclusive(int lower, int upper) =>
    BetweenInclusiveMatcher(lower, upper);

class BetweenInclusiveMatcher extends Matcher {
  final int lower;
  final int upper;

  const BetweenInclusiveMatcher(this.lower, this.upper);

  @override
  Description describe(Description description) {
    return description
        .add('an int value between ')
        .addDescriptionOf(lower)
        .add(' and ')
        .addDescriptionOf(upper);
  }

  @override
  bool matches(item, Map matchState) {
    if (item is int) {
      return lower <= item && item <= upper;
    } else {
      return false;
    }
  }
}
