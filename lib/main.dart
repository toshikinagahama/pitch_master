import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

import "package:fl_chart/fl_chart.dart";
import 'myChart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ChangeNotifierProvider(
            create: (context) => SensorValueState(), child: MyHomePage()));
  }
}

class SensorValueState extends ChangeNotifier {
  List<double> _vals = [];
  List<FlSpot> _data = [FlSpot(0, 0)];
  double _counter = 0.0;
  List<double> get vals => this._vals;
  List<FlSpot> get data => this._data;
  double get counter => this._counter;

  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice device = null;
  BluetoothCharacteristic chara = null;

  void startMeas() {
    _counter = 0.1;
    this._data = [FlSpot(0, 0)];
    chara.write([0x31, 0x31, 0x31, 0x31], withoutResponse: false);
  }

  void stopMeas() {
    chara.write([0x32, 0x32, 0x32, 0x32], withoutResponse: false);
  }

  void DeviceDisconnect() {
    if (device != null) {
      device.disconnect();
    }
  }

  void DeviceConnect() async {
    bool isFoundDevice = false;
    _counter = 0.1;
    this._vals.clear();
    this._data = [FlSpot(0, 0)];
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 1));
    // Listen to scan results
    flutterBlue.scanResults.listen((results) async {
      // do something with scan results
      if (!isFoundDevice) {
        for (ScanResult r in results) {
          print('${r.device.name} found! rssi: ${r.rssi}');
          if (r.device.name == "M5StickC") {
            print("M5StickC is found!");
            isFoundDevice = true;
            device = r.device;

            if (device != null) {
              try {
                device.connect().then((value1) {
                  device.discoverServices().then((services) {
                    device.requestMtu(120).then((value2) async {
                      print("change Mtu");
                      await new Future.delayed(new Duration(seconds: 2));
                      services.forEach((service) async {
                        print(service.uuid);
                        var characteristics = service.characteristics;
                        for (BluetoothCharacteristic characteristic
                            in characteristics) {
                          print(characteristic.uuid);
                          if (characteristic.uuid ==
                              Guid("beb5483e-36e1-4688-b7f5-ea07361b26a8")) {
                            chara = characteristic;
                            print("Get Characteristic!!");
                            print(chara);
                            await chara.setNotifyValue(true);
                            chara.value.listen((value) {
                              // do something with new value
                              String str = utf8.decode(value);
                              List<String> strArray = str.split(",");
                              List<double> sensorValArray = [];
                              for (String s in strArray) {
                                double val;
                                try {
                                  val = double.parse(s);
                                } catch (exception) {
                                  val = 0.0;
                                }
                                sensorValArray.add(val);
                              }
                              update(sensorValArray);
                              print(str);
                            });
                          }
                        }
                      });
                    }).catchError((onError) {
                      print(onError);
                    });
                  }).catchError((onError) {
                    print(onError);
                  });
                });
              } catch (e) {
                print(e.toString());
              }
            } else {
              print(device);
            }
            break;
          }
        }
      }
    });
// Stop scanning
    flutterBlue.stopScan();
    print("stop Scan!!");
  }

  void update(List<double> vals) {
    _data.add(FlSpot(_counter, vals[0]));
    if (_data.length > 50) {
      _data.removeAt(0);
    }
    _counter += 0.01;

    _counter += 0.01;
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  //Bluetooth関係

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("title"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 50,
          ),
          Expanded(
              child: SensorChartArea(context.watch<SensorValueState>()._data)),
          RaisedButton(
            child: const Text('デバイス接続'),
            onPressed: () {
              context.read<SensorValueState>().DeviceConnect();
            },
          ),
          RaisedButton(
            child: const Text('デバイス接続解除'),
            onPressed: () {
              context.read<SensorValueState>().DeviceDisconnect();
            },
          ),
          RaisedButton(
            child: const Text('計測開始'),
            onPressed: () {
              context.read<SensorValueState>().startMeas();
            },
          ),
          RaisedButton(
            child: const Text('計測終了'),
            onPressed: () {
              context.read<SensorValueState>().stopMeas();
            },
          )
        ],
      ),
    );
  }
}
