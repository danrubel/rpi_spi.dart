# rpi_spi.dart

[![pub package](https://img.shields.io/pub/v/rpi_spi.svg)](https://pub.dartlang.org/packages/rpi_ic2)
[![Build Status](https://travis-ci.org/danrubel/rpi_spi.dart.svg?branch=master)](https://travis-ci.org/danrubel/rpi_spi.dart)

rpi_spi is a Dart package for using SPI on the Raspberry Pi.

## Overview

 * The [__Spi__](lib/spi.dart) library provides the API for accessing devices
   using the [SPI protocol](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface)

 * The [__RpiSpi__](lib/rpi_spi.dart) library provides implementation of
   the SPI protocol on the Raspberry Pi derived from the [WiringPi](http://wiringpi.com/) library.

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
    pub global run rpi_spi:build_lib
```

[pub global activate](https://www.dartlang.org/tools/pub/cmd/pub-global.html#activating-a-package)
makes the Dart scripts in the rpi_spi/bin directory runnable
from the command line.
[pub global run](https://www.dartlang.org/tools/pub/cmd/pub-global.html#running-a-script)
rpi_spi:build_lib runs the [rpi_spi/bin/build_lib.dart](bin/build_lib.dart)
program which in turn calls the [build_lib](lib/src/native/build_lib) script
to compile the native librpi_spi_ext.so library for the rpi_spi package.

## Example

TBD
