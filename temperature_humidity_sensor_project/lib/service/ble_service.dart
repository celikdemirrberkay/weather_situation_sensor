import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:temperature_humidity_sensor_project/service/ble_service_interface.dart';

class BLEService with IBLEService {
  /// FlutterBluePlus package return is scanning or not info.
  static Stream<bool> get isScaning => FlutterBluePlus.isScanning;

  /// FlutterBluePlus returns scan results list. Like bluetooth device.
  static Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  /// FlutterBluePlus returns adapter state. Like bluetooth on or off.
  static Stream<BluetoothAdapterState> get adapterState => FlutterBluePlus.adapterState;

  /// Starting scan for BLE device.
  @override
  Future<void> startScan({Duration? timeout}) async {
    FlutterBluePlus.startScan(timeout: timeout);
  }

  /// Stopping scan for BLE device.
  @override
  Future<void> stopScan() async {
    FlutterBluePlus.stopScan();
  }
}
