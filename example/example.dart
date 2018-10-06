import 'dart:async';

import 'package:rpi_spi/rpi_spi.dart';

import 'mcp3008.dart';

main() async {
  final spi = new RpiSpi();
  await readSensor(new Mcp3008(spi, 0, 24));
  spi.dispose();
}

Future readSensor(Mcp3008 mcp3008) async {
  StringBuffer out;
  print('Read analog values from MCP3008 channels 0 - 7:');

  print('      | Channel');
  out = new StringBuffer('      ');
  for (int channel = 0; channel < 8; ++channel) {
    out.write('| ${channel.toString().padLeft(4)} ');
  }
  print(out.toString());
  print('-' * 63);

  for (int count = 1; count <= 10; ++count) {
    out = new StringBuffer(' ${count.toString().padLeft(4)} ');
    for (int channel = 0; channel < 8; ++channel) {
      var value = mcp3008.read(channel);
      out.write('| ${value.toString().padLeft(4)} ');
    }
    print(out.toString());
    await new Future.delayed(new Duration(milliseconds: 10));
  }
}
