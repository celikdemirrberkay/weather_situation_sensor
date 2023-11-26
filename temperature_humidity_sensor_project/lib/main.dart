import 'package:dart_vader/dart_vader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:temperature_humidity_sensor_project/colors.dart';
import 'package:temperature_humidity_sensor_project/service/ble_service.dart';
import 'package:temperature_humidity_sensor_project/service/ble_service_interface.dart';
import 'package:temperature_humidity_sensor_project/view/sensor.dart';
import 'package:temperature_humidity_sensor_project/view/widgets.dart';

void main() {
  runApp(FlutterBlueApp());
}

class FlutterBlueApp extends StatefulWidget {
  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.lightBlue,
      theme: ThemeData(useMaterial3: true),
      home: StreamBuilder<BluetoothAdapterState>(
          stream: FlutterBluePlus.adapterState,
          initialData: BluetoothAdapterState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data != null ? snapshot.data! : BluetoothAdapterState.unknown;
            if (state == BluetoothAdapterState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatefulWidget {
  final BluetoothAdapterState state;

  const BluetoothOffScreen({Key? key, required this.state}) : super(key: key);

  @override
  State<BluetoothOffScreen> createState() => _BluetoothOffScreenState();
}

class _BluetoothOffScreenState extends State<BluetoothOffScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.lightBlue,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              context.spacerWithFlex(flex: 1),
              Expanded(child: Lottie.asset('assets/bluetoothoff.json', repeat: true)),
              Expanded(child: _bluetoothOfText(context)),
              context.spacerWithFlex(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bluetoothOfText(BuildContext context) => Padding(
        padding: context.symmetricPaddingHigh,
        child: FittedBox(
          child: Text(
            widget.state == BluetoothAdapterState.off
                ? 'Bluetooth is ${widget.state.name}.\nPlease turn on your device settings'
                : 'Bluetooth turning on...',
            style: context.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: context.fontWeightBold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
}

class FindDevicesScreen extends StatefulWidget {
  const FindDevicesScreen({super.key});

  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  final IBLEService _bleService = BLEService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: StreamBuilder<List<ScanResult>>(
        stream: BLEService.scanResults,
        initialData: const [],
        builder: (c, snapshot) => Column(
          children: [
            Expanded(flex: 3, child: Lottie.asset('assets/bluetooth_scan.json')),
            Divider(thickness: 2, color: AppColors.black),
            Expanded(flex: 1, child: _scannedDeviceText()),
            Divider(thickness: 2, color: AppColors.black),
            Expanded(flex: 5, child: _deviceListViewBuilder(snapshot, context)),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: BLEService.isScaning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return _stopScanFAB();
          } else {
            return _startScanFAB();
          }
        },
      ),
    );
  }

  Widget _scannedDeviceText() => Padding(
        padding: context.symmetricPaddingHigh,
        child: FittedBox(
          child: Text('Scanned Device',
              style: context.bodyLarge?.copyWith(
                fontWeight: context.fontWeight300,
              )),
        ),
      );

  Widget _deviceListViewBuilder(AsyncSnapshot<List<ScanResult>> snapshot, BuildContext context) {
    return ListView.builder(
      itemCount: snapshot.data!.length,
      itemBuilder: (c, index) => ScanResultTile(
        result: snapshot.data![index],
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          snapshot.data![index].device.connect();
          return SensorPage(device: snapshot.data![index].device);
        })),
      ),
    );
  }

  Widget _startScanFAB() {
    return FloatingActionButton.large(
        backgroundColor: AppColors.mainColor,
        onPressed: () async {
          var status = await Permission.bluetoothScan.status;
          if (status.isDenied) {
            await Permission.bluetoothScan.request();
          } else if (await Permission.bluetoothScan.status.isPermanentlyDenied) {
            openAppSettings();
          } else {
            _bleService.startScan(timeout: const Duration(seconds: 4));
          }
        },
        child: Icon(
          Icons.search,
          color: AppColors.white,
        ));
  }

  FloatingActionButton _stopScanFAB() {
    return FloatingActionButton.large(
      onPressed: () => _bleService.stopScan(),
      backgroundColor: Colors.red,
      child: Icon(Icons.stop, color: AppColors.white),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: AppColors.mainColor,
      title: FittedBox(
        child: Text(
          'Temperature & Humidity Checker',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black,
              ),
        ),
      ),
    );
  }
}
