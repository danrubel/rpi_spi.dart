import 'package:rpi_spi/spi.dart';
import 'package:test/test.dart';

expectThrows(f()) async {
  try {
    await f();
    fail('expected exception');
  } on SpiException {
    // Expected... fall through
  }
}
