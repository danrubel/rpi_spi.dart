# rpi_spi.dart

[![pub package](https://img.shields.io/pub/v/rpi_spi.svg)](https://pub.dartlang.org/packages/rpi_spi)

rpi_spi is a Dart package for using SPI on the Raspberry Pi.

## Overview

 * The [__Spi__](lib/spi.dart) library provides the API for accessing devices
   using the [SPI protocol](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface)

 * The [__RpiSpi__](lib/rpi_spi.dart) library provides implementation of
   the SPI protocol on the Raspberry Pi derived from the WiringPi library.

## Setup

Be sure to enable SPI on the Raspberry Pi using
```
    sudo raspi-config
```

[__RpiSpi__](lib/rpi_spi.dart) uses a native library written in C.
For security reasons, authors cannot publish binary content
to [pub.dartlang.org](https://pub.dartlang.org/), so there are some extra
steps necessary to compile the native library on the RPi before this package
can be used. These two steps must be performed when you install and each time
you upgrade the rpi_spi package.

1) Activate the rpi_spi package using the
[pub global](https://www.dartlang.org/tools/pub/cmd/pub-global.html) command.
```
    pub global activate rpi_spi
```

2) From your application directory (the application that references
the rpi_spi package) run the following command to build the native library
```
    pub global run rpi_spi:build_native
```

[pub global activate](https://www.dartlang.org/tools/pub/cmd/pub-global.html#activating-a-package)
makes the Dart scripts in the rpi_spi/bin directory runnable
from the command line.
[pub global run](https://www.dartlang.org/tools/pub/cmd/pub-global.html#running-a-script)
rpi_spi:build_native runs the [rpi_spi/bin/build_native.dart](bin/build_native.dart)
program which in turn calls the [build_native](lib/src/native/build_native) script
to compile the native librpi_spi_ext.so library for the rpi_spi package.

## Example

 * [example.dart](example/example.dart) demonstrates instantiating and accessing a SPI device.

 * [mcp3008.dart](example/mcp3008.dart) demonstractes how the SPI API is used
   to interact with a [MCP3008](https://cdn-shop.adafruit.com/datasheets/MCP3008.pdf)
   analog to digital converter

Connect the following [pins on the Raspberry Pi](https://www.raspberrypi.org/documentation/usage/gpio/)
to the following pins on the [Adafruit MCP3008](https://www.adafruit.com/product/856).
Pi pins 13 and 15 are connected to MCP3008 input #0 both for the example and as a predictable test input.
The other connected Pi pins are for controlling the MCP3008 and reading it's output values via the SPI API.

| Rpi Pin                            | MCP3008                         |
| ---------------------------------- | ------------------------------- |
| PIN #13 to 4.7K resistor to --->   | PIN #1 (CH0)                    |
| PIN #15 to 10K resistor to --->    | PIN #1 (CH0)                    |
| PIN #17 (3.3V)                     | PIN #16 (VDD) & PIN #15 (VREF)  |
| PIN #19 (SPI0 MOSI)                | PIN #11 (DIN)                   |
| PIN #21 (SPI0 MISO)                | PIN #12 (DOUT)                  |
| PIN #23 (SIP0 SCLK)                | PIN #13 (CLK)                   |
| PIN #24 (SPI0 CS0)                 | PIN #10 (CS/SHDN)               |
| PIN #25 (GND)                      | PIN #9 (DGND) & PIN #14 (AGND)  |
