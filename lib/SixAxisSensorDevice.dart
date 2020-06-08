import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

class SixAxisSensorDevice {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice device = null;
  BluetoothCharacteristic chara = null;

  void startMeas() {
    chara.write([0x31, 0x31, 0x31, 0x31], withoutResponse: false);
  }

  void stopMeas() {
    chara.write([0x32, 0x32, 0x32, 0x32], withoutResponse: false);
  }

  void disconnect() {
    if (device != null) {
      device.disconnect();
    }
  }

  // void a(void Function s()) {}

  void receiveSensorValueListener(value) {
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
    print(str);
  }

  void connect() async {
    bool isFoundDevice = false;
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
                            chara.value.listen((value) =>
                                this.receiveSensorValueListener(value));
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
}
