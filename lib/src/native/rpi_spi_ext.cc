#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <fcntl.h>
#include <linux/spi/spidev.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include "include/dart_api.h"
#include "include/dart_native_api.h"

Dart_Handle HandleError(Dart_Handle handle) {
  if (Dart_IsError(handle)) {
    Dart_PropagateError(handle);
  }
  return handle;
}

// === from wiringPiI2C.c ===

const static char *spiDev0  = "/dev/spidev0.0";
const static char *spiDev1  = "/dev/spidev0.1";

const static uint8_t  spiBPW   = 8;
const static uint16_t spiDelay = 0;

// === end from wiringPiI2C.c ===

// SPI Notes:
/// * https://elinux.org/RPi_SPI
/// * https://en.wikipedia.org/wiki/Serial_Peripheral_Interface
/// * https://www.kernel.org/doc/html/v4.16/driver-api/spi.html
/// * https://www.raspberrypi.org/documentation/hardware/raspberrypi/spi

// Setup the SPI device with the specified controller, chip select, speed, and mode.
// Negative return values indicate an error.
//int _setupDevice(int controller, int chipSelect, int speed, int mode) native "setupDevice";
void setupDevice(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle arg1 = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_Handle arg2 = HandleError(Dart_GetNativeArgument(arguments, 2));
  Dart_Handle arg3 = HandleError(Dart_GetNativeArgument(arguments, 3));
  Dart_Handle arg4 = HandleError(Dart_GetNativeArgument(arguments, 4));

  int64_t controller, chipSelect, speed, mode;
  HandleError(Dart_IntegerToInt64(arg1, &controller));
  HandleError(Dart_IntegerToInt64(arg2, &chipSelect));
  HandleError(Dart_IntegerToInt64(arg3, &speed));
  HandleError(Dart_IntegerToInt64(arg4, &mode));

  int fd;
  int64_t result;

  fd = open(chipSelect == 0 ? spiDev0 : spiDev1, O_RDWR);
  if (fd < 0) {
    result = -1;
  } else if (ioctl(fd, SPI_IOC_WR_MODE, &mode) < 0) {
    result = -2;
  } else if (ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &spiBPW) < 0) {
    result = -3;
  } else if (ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed) < 0) {
    result = -4;
  } else {
    result = fd;
  }

  Dart_SetIntegerReturnValue(arguments, result);
  Dart_ExitScope();
}

// Dispose of the SPI device and return 0 to indicate success.
// Negative return values indicate an error.
//int _disposeDevice(int fd) native "disposeDevice";
void disposeDevice(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle arg1 = HandleError(Dart_GetNativeArgument(arguments, 1));

  int64_t fd;
  HandleError(Dart_IntegerToInt64(arg1, &fd));

  int64_t result;
  if (close(fd) < 0) {
    result = -1;
  } else {
    result = 0;
  }

  Dart_SetIntegerReturnValue(arguments, result);
  Dart_ExitScope();
}

// Send bytes to the device and receive the same number of bytes.
// Negative return values indicate an error.
//int _send(int fd, int speed, List<int> txData, Uint8List rxData, int len) native "send";
void send(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle arg1 = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_Handle arg2 = HandleError(Dart_GetNativeArgument(arguments, 2));
  Dart_Handle txData = HandleError(Dart_GetNativeArgument(arguments, 3));
  Dart_Handle rxData = HandleError(Dart_GetNativeArgument(arguments, 4));
  Dart_Handle arg5 = HandleError(Dart_GetNativeArgument(arguments, 5));

  int64_t fd, speed, len;
  HandleError(Dart_IntegerToInt64(arg1, &fd));
  HandleError(Dart_IntegerToInt64(arg2, &speed));
  HandleError(Dart_IntegerToInt64(arg5, &len));

  uint8_t data[40];
  HandleError(Dart_ListGetAsBytes(txData, 0, data, len));

  struct spi_ioc_transfer spi;

  // From spidev.h:
  // Zero-initialize the structure, including currently unused fields,
  // to accommodate potential future updates.
  memset(&spi, 0, sizeof (spi));

  spi.tx_buf        = (unsigned long) data;
  spi.rx_buf        = (unsigned long) data;
  spi.len           = len;
  spi.delay_usecs   = spiDelay;
  spi.speed_hz      = speed;
  spi.bits_per_word = spiBPW;

  int64_t result = ioctl(fd, SPI_IOC_MESSAGE(1), &spi);
  if (result >= 0) {
    HandleError(Dart_ListSetAsBytes(rxData, 0, data, len));
  }

  Dart_SetIntegerReturnValue(arguments, result);
  Dart_ExitScope();
}

// ===== Infrastructure methods ===============================================

struct FunctionLookup {
  const char* name;
  Dart_NativeFunction function;
};

FunctionLookup function_list[] = {
  {"disposeDevice", disposeDevice},
  {"send", send},
  {"setupDevice", setupDevice},
  {NULL, NULL}
};

FunctionLookup no_scope_function_list[] = {
  {NULL, NULL}
};

// Resolve the Dart name of the native function into a C function pointer.
// This is called once per native method.
Dart_NativeFunction ResolveName(Dart_Handle name,
                                int argc,
                                bool* auto_setup_scope) {
  if (!Dart_IsString(name)) {
    return NULL;
  }
  Dart_NativeFunction result = NULL;
  if (auto_setup_scope == NULL) {
    return NULL;
  }

  Dart_EnterScope();
  const char* cname;
  HandleError(Dart_StringToCString(name, &cname));

  for (int i=0; function_list[i].name != NULL; ++i) {
    if (strcmp(function_list[i].name, cname) == 0) {
      *auto_setup_scope = true;
      result = function_list[i].function;
      break;
    }
  }

  if (result != NULL) {
    Dart_ExitScope();
    return result;
  }

  for (int i=0; no_scope_function_list[i].name != NULL; ++i) {
    if (strcmp(no_scope_function_list[i].name, cname) == 0) {
      *auto_setup_scope = false;
      result = no_scope_function_list[i].function;
      break;
    }
  }

  Dart_ExitScope();
  return result;
}

// Initialize the native library.
// This is called once when the native library is loaded.
DART_EXPORT Dart_Handle rpi_spi_ext_Init(Dart_Handle parent_library) {
  if (Dart_IsError(parent_library)) {
    return parent_library;
  }
  Dart_Handle result_code =
      Dart_SetNativeResolver(parent_library, ResolveName, NULL);
  if (Dart_IsError(result_code)) {
    return result_code;
  }
  return Dart_Null();
}
