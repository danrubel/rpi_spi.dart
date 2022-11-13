//
// Generated from native/rpi_spi_ext.cc
//
import 'dart:ffi' as ffi;

const nativePkgName = 'rpi_spi';

class NativePgkLib {
  final DisposeDevice disposeDeviceMth;
  final SetupDevice setupDeviceMth;
  final WriteThenRead writeThenReadMth;

  NativePgkLib(ffi.DynamicLibrary dylib)
      : disposeDeviceMth = dylib
            .lookup<ffi.NativeFunction<DisposeDeviceFfi>>('disposeDevice')
            .asFunction<DisposeDevice>(),
        setupDeviceMth = dylib
            .lookup<ffi.NativeFunction<SetupDeviceFfi>>('setupDevice')
            .asFunction<SetupDevice>(),
        writeThenReadMth = dylib
            .lookup<ffi.NativeFunction<WriteThenReadFfi>>('writeThenRead')
            .asFunction<WriteThenRead>();
}

typedef DisposeDevice = int Function(int fd);
typedef DisposeDeviceFfi = ffi.Int64 Function(ffi.Int64 fd);

typedef SetupDevice = int Function(
    int controller, int chipSelect, int speed, int mode);
typedef SetupDeviceFfi = ffi.Int64 Function(ffi.Int64 controller,
    ffi.Int64 chipSelect, ffi.Int64 speed, ffi.Int64 mode);

typedef WriteThenRead = int Function(
    int fd, int speed, int numBytes, ffi.Pointer<ffi.Uint8> listPtr);
typedef WriteThenReadFfi = ffi.Int64 Function(ffi.Int64 fd, ffi.Int64 speed,
    ffi.Int64 numBytes, ffi.Pointer<ffi.Uint8> listPtr);
