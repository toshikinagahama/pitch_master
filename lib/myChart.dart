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
  List<List<FlSpot>> _dataList;

  SensorChartArea(List<List<FlSpot>> dataList) {
    _dataList = dataList;
  }

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
                spots: _dataList[0],
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
      Expanded(
          child: SizedBox(
        width: 300,
        height: 140,
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: _dataList[1],
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
      Expanded(
          child: SizedBox(
        width: 300,
        height: 140,
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: _dataList[2],
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
    ]);
  }
}
