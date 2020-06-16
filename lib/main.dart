import 'dart:convert';
import 'dart:math';

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
  //複数のBLEデバイスからのセンサの状態を管理する
  //最大2個とする。
  List<List<double>> _valsList = [
    [0],
    [0]
  ];
  List<List<FlSpot>> _dataList = [
    [FlSpot(0, 0)],
    [FlSpot(0, 0)],
    [FlSpot(0, 0)]
  ];
  List<double> _counterList = [0.0, 0.0];
  double _counter = 0.0;

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> deviceList = [null, null];
  List<DeviceIdentifier> deviceIDList = [null, null];
  List<BluetoothCharacteristic> charaList = [null, null];

  void startMeas() {
    _counterList[0] = 0.1;
    _counterList[1] = 0.1;
    _counter = 0.1;
    for (int i = 0; i < this._dataList.length; i++) {
      this._dataList[i] = [FlSpot(0, 0)];
    }
    for (int i = 0; i < charaList.length; i++) {
      if (charaList[i] != null)
        charaList[i].write([0x31, 0x31, 0x31, 0x31], withoutResponse: false);
    }
  }

  void stopMeas() {
    for (int i = 0; i < charaList.length; i++) {
      if (charaList[i] != null)
        charaList[i].write([0x32, 0x32, 0x32, 0x32], withoutResponse: false);
    }
  }

  void DeviceDisconnect(index) {
    if (deviceList.length <= index) return;
    if (deviceList[index] != null) {
      deviceList[index].disconnect();
      deviceList[index] = null;
      charaList[index] = null;
    }
  }

  void DeviceConnect(index) async {
    print(deviceList.length);
    if (deviceList.length <= index) return;
    bool isFoundDevice = false;
    _counterList[index] = 0.1;
    print("scan start");
    flutterBlue.startScan(timeout: Duration(seconds: 1));
    // Listen to scan results
    flutterBlue.scanResults.listen((results) async {
      // do something with scan results
      if (!isFoundDevice) {
        for (ScanResult r in results) {
          print('${r.device.name} found! rssi: ${r.rssi}');
          if (r.device.name == "M5StickC") {
            print("M5StickC is found!");
            print(r.device.id);
            if (deviceIDList.contains(r.device.id)) {
              //重複してたら飛ばす
              continue;
            }
            deviceIDList[index] = r.device.id;
            deviceList[index] = r.device;
            isFoundDevice = true;

            if (deviceList[index] != null) {
              try {
                deviceList[index].connect().then((value1) {
                  deviceList[index].discoverServices().then((services) {
                    deviceList[index].requestMtu(120).then((value2) async {
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
                            charaList[index] = characteristic;
                            // print("Get Characteristic!!");
                            await charaList[index].setNotifyValue(true);
                            charaList[index].value.listen((value) {
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
                              print(index);
                              print(str);
                              print(sensorValArray);
                              update(index, sensorValArray);
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
            } else {}
            break;
          }
        }
      }
    });
// Stop scanning
    flutterBlue.stopScan();
    print("stop Scan!!");
  }

  void update(int index, List<double> vals) {
    if (vals.length < 6) return;
    _dataList[index].add(FlSpot(_counterList[index],
        sqrt(vals[0] * vals[0] + vals[1] * vals[1] + vals[2] * vals[2])));
    if (_dataList[index].length > 50) {
      _dataList[index].removeAt(0);
      if (_dataList[0].length >= 50 &&
          _dataList[1].length >= 50 &&
          index == 0) {
        if (_dataList[1][49].y >= 0.0001) {
          _dataList[2].add(FlSpot(
              _counterList[index], _dataList[0][49].y / _dataList[1][49].y));
        } else {
          _dataList[2].add(FlSpot(_counterList[index], 0.0));
        }
        if (_dataList[2].length > 50) {
          _dataList[2].removeAt(0);
        }
      }
    }
    _counterList[index] += 1 / 32;
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
              child:
                  SensorChartArea(context.watch<SensorValueState>()._dataList)),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  child: const Text('デバイス1接続'),
                  onPressed: () {
                    context.read<SensorValueState>().DeviceConnect(0);
                  },
                ),
                RaisedButton(
                  child: const Text('デバイス1接続解除'),
                  onPressed: () {
                    context.read<SensorValueState>().DeviceDisconnect(0);
                  },
                )
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  child: const Text('デバイス2接続'),
                  onPressed: () {
                    context.read<SensorValueState>().DeviceConnect(1);
                  },
                ),
                RaisedButton(
                  child: const Text('デバイス2接続解除'),
                  onPressed: () {
                    context.read<SensorValueState>().DeviceDisconnect(1);
                  },
                )
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
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
              ]),
        ],
      ),
    );
  }
}
