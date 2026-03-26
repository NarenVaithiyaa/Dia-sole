// DEPRECATED: Use BluetoothService instead. This file is kept for backward compatibility.
// All Bluetooth operations should go through lib/services/bluetooth_service.dart

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

@Deprecated('Use BluetoothService from bluetooth_service.dart instead')
class AppBluetoothService {
  static Future<bool> isBluetoothOn() async {
    // Check if Bluetooth is supported
    if (await FlutterBluePlus.isSupported == false) {
      return false;
    }

    // Check Bluetooth state
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }
}
