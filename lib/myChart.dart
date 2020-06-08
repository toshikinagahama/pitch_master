import 'dart:async';
import 'dart:math';

/// Example of a stacked area chart.
import 'package:flutter/material.dart';
import "package:fl_chart/fl_chart.dart";

//センサーのデータを描画するクラス
class SensorChartArea extends StatelessWidget {
  double _counter = 0.0;
  bool _isMeasuring = false;
  String _measButtonText = "Start";
  Timer _timer;
  List<FlSpot> _data_X;

  SensorChartArea(List<FlSpot> data) {
    _data_X = data;
  }

  // void _toggleMeasurement() {
  //   _isMeasuring = !_isMeasuring;
  //   if (_isMeasuring) {
  //     _measButtonText = "Stop";
  //     _timer = Timer.periodic(
  //       Duration(milliseconds: 10),
  //       _onTimer,
  //     );
  //   } else {
  //     _measButtonText = "Start";
  //     _timer?.cancel();
  //   }
  // }

  // void _onTimer(Timer timer) {
  //   setState(() {
  //     var rng = new Random();
  //     double val = rng.nextDouble();
  //     _data_X.add(FlSpot(_counter, val));
  //     if (_data_X.length > 500) {
  //       _data_X.removeAt(0);
  //     }
  //     _counter += 0.1;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Expanded(
          child: SizedBox(
        width: 300,
        height: 140,
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: _data_X,
                isCurved: false,
                barWidth: 2,
                colors: [
                  Colors.red,
                ],
                dotData: FlDotData(
                  show: false,
                ),
              ),
            ],
            // gridData: FlGridData(),
          ),
          swapAnimationDuration: Duration(milliseconds: 0),
        ),
      )),
      // RaisedButton(
      //   child: Text(_measButtonText),
      //   onPressed: _toggleMeasurement,
      // ),
    ]);
  }
  // SensorChartArea({Key key, this.title}) : super(key: key);
  // final String title;

  // @override
  // _SensorChartAreaState createState() => _SensorChartAreaState();
}

// class _SensorChartAreaState extends State<SensorChartArea> {
//   double _counter = 0.0;
//   bool _isMeasuring = false;
//   String _measButtonText = "Start";
//   Timer _timer;
//   List<FlSpot> _data_X;

//   _SensorChartAreaState(List<FlSpot> data) {
//     _data_X = data;
//   }

//   void _toggleMeasurement() {
//     _isMeasuring = !_isMeasuring;
//     if (_isMeasuring) {
//       _measButtonText = "Stop";
//       _timer = Timer.periodic(
//         Duration(milliseconds: 10),
//         _onTimer,
//       );
//     } else {
//       _measButtonText = "Start";
//       _timer?.cancel();
//     }
//   }

//   void _onTimer(Timer timer) {
//     setState(() {
//       var rng = new Random();
//       double val = rng.nextDouble();
//       _data_X.add(FlSpot(_counter, val));
//       if (_data_X.length > 500) {
//         _data_X.removeAt(0);
//       }
//       _counter += 0.1;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: <Widget>[
//       Expanded(
//           child: SizedBox(
//         width: 300,
//         height: 140,
//         child: LineChart(
//           LineChartData(
//             lineTouchData: LineTouchData(enabled: false),
//             lineBarsData: [
//               LineChartBarData(
//                 spots: _data_X,
//                 isCurved: false,
//                 barWidth: 2,
//                 colors: [
//                   Colors.red,
//                 ],
//                 dotData: FlDotData(
//                   show: false,
//                 ),
//               ),
//             ],
//             // gridData: FlGridData(),
//           ),
//           swapAnimationDuration: Duration(milliseconds: 0),
//         ),
//       )),
//       // RaisedButton(
//       //   child: Text(_measButtonText),
//       //   onPressed: _toggleMeasurement,
//       // ),
//     ]);
//   }
// }
