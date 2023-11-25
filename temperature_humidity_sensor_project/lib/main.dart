import 'dart:async';
import 'package:dart_vader/dart_vader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:temperature_humidity_sensor_project/sensor.dart';
import 'package:temperature_humidity_sensor_project/widgets.dart';

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
  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Column(
        children: <Widget>[
          StreamBuilder<List<BluetoothDevice>>(
            stream: Stream.periodic(const Duration(seconds: 2)).asyncMap((_) => FlutterBluePlus.connectedDevices),
            initialData: [],
            builder: (c, snapshot) => Column(
              children: snapshot.data != null
                  ? snapshot.data!
                      .map((d) => ListTile(
                            title: Text(d.platformName, style: GoogleFonts.roboto(color: Colors.red)),
                            subtitle: Text(d.toString()),
                            trailing: StreamBuilder<BluetoothConnectionState>(
                              stream: d.connectionState,
                              initialData: BluetoothConnectionState.disconnected,
                              builder: (c, snapshot) {
                                if (snapshot.data == BluetoothConnectionState.connected) {}
                                return Text(snapshot.data.toString());
                              },
                            ),
                          ))
                      .toList()
                  : [
                      Text(
                        'data',
                        style: TextStyle(color: Colors.red),
                      )
                    ],
            ),
          ),
          StreamBuilder<List<ScanResult>>(
            stream: FlutterBluePlus.scanResults,
            initialData: [],
            builder: (c, snapshot) => Column(
              children: snapshot.data!
                  .map(
                    (r) => ScanResultTile(
                      result: r,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        r.device.connect();
                        return SensorPage(device: r.device);
                      })),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBluePlus.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              onPressed: () => FlutterBluePlus.stopScan(),
              backgroundColor: Colors.red,
              child: const Icon(Icons.stop),
            );
          } else {
            return FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () async {
                  var status = await Permission.bluetoothScan.status;
                  if (status.isDenied) {
                    await Permission.bluetoothScan.request();
                  } else if (await Permission.bluetoothScan.status.isPermanentlyDenied) {
                    openAppSettings();
                  } else {
                    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
                  }
                });
          }
        },
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
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
