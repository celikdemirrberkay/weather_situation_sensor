import 'dart:async';
import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:temperature_humidity_sensor_project/view/home_ui.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({Key? key, required this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  String SERVICE_UUID = "3ac996e8-95cc-4a6d-b3ee-6b672350d050";
  String CHARACTERISTIC_UUID = "0b8b669a-2949-4720-93af-b6009d61e86c";
  bool isReady = false;
  Stream<List<int>>? stream;
  List? _temphumidata;
  double _temp = 0;
  double _humidity = 0;
  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  void dispose() {
    widget.device.disconnect();
    super.dispose();
  }

  connectToDevice() async {
    if (widget.device == null) {
      Navigator.of(context).pop(true);

      return;
    }

    Timer(const Duration(seconds: 15), () {
      if (!isReady) {
        disconnectFromDevice();
        Navigator.of(context).pop(true);
      }
    });

    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      Navigator.of(context).pop(true);
      return;
    }

    widget.device.disconnect();
  }

  discoverServices() async {
    if (widget.device == null) {
      Navigator.of(context).pop(true);
      return;
    }

    List<BluetoothService> services = await widget.device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.lastValueStream;
            setState(() {
              isReady = true;
            });
          }
        }
      }
    }

    if (!isReady) {
      Navigator.of(context).pop(true);
    }
  }

  Future<dynamic> _onWillPop() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to disconnect device and go back?'),
              actions: <Widget>[
                ElevatedButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
                ElevatedButton(
                    onPressed: () {
                      disconnectFromDevice();
                      Navigator.of(context).pop(true);
                    },
                    child: new Text('Yes')),
              ],
            ));
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _onWillPop(),
      child: Scaffold(
        body: Container(
            child: !isReady
                ? const Center(child: Text("Waiting...", style: TextStyle(fontSize: 24, color: Colors.red)))
                : Container(
                    child: StreamBuilder<List<int>>(
                      stream: stream,
                      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
                        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                        if (snapshot.connectionState == ConnectionState.active) {
                          var currentValue = _dataParser(snapshot.data!);
                          _temphumidata = currentValue.split(",");

                          if (_temphumidata![0] != "nan") {
                            _temp = double.parse('${_temphumidata?[0]}');
                          }
                          if (_temphumidata![1] != "nan") {
                            _humidity = double.parse('${_temphumidata![1]}');
                          }
                          return HomeUI(humidity: _humidity, temperature: _temp);
                        } else {
                          return const Text('Check the stream');
                        }
                      },
                    ),
                  )),
      ),
    );
  }
}
