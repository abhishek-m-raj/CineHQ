import 'dart:ffi';

String? getAndroidAbiFieldName() {
  try {
    final abi = Abi.current();
    if (abi == Abi.androidArm64) return 'android_arm64';
    if (abi == Abi.androidArm) return 'android_arm32';
    if (abi == Abi.androidX64) return 'android_x86_64';
  } catch (_) {
    // Keep fallback behavior for unsupported ABI detection scenarios.
  }

  return null;
}
