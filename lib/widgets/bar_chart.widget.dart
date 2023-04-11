import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:slurp/model/SlurpAtom.dart';
import 'package:slurp/services/database.service.dart';

class PastWeekBarChart extends StatefulWidget {
  const PastWeekBarChart({super.key});

  @override
  State<StatefulWidget> createState() => PastWeekBarChartState();
}

class PastWeekBarChartState extends State<PastWeekBarChart> {
  final dbService = DatabaseService.instance;
  final Color barBackgroundColor = Colors.black;
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Colors.blue,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Your Slurp data',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: "OdibeeSans",
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  const Text(
                    '7 day Report',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: "OdibeeSans",
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 38,
                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: FutureBuilder(
                            future: mainBarData(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.connectionState ==
                                      ConnectionState.done) {
                                return BarChart(
                                  snapshot.data!,
                                  swapAnimationDuration: animDuration,
                                );
                              }
                              return Container();
                            })),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 22,
    int aim = 2500,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? Colors.blue.shade800 : barColor,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: Colors.blue.shade800)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: aim.toDouble(),
            color: barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  Future<List<BarChartGroupData>> _showingGroups() async {
    List<BarChartGroupData> res = [];
    await Future.forEach([0, 1, 2, 3, 4, 5, 6], (i) async {
      var date = DateTime.now().subtract(Duration(days: 6 - i));

      var value = await dbService.getById<SlurpAtom>(
          id: "${date.year}${date.month}${date.day}", table: slurpTable);
      res.add(makeGroupData(i, value != null ? value.value.toDouble() : 0.0,
          isTouched: i == touchedIndex, aim: value != null ? value.aim : 2500));
    });
    return res;
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 5, isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, 6.5, isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, 5, isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, 7.5, isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, 9, isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, 11.5, isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, 6.5, isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  Future<BarChartData> mainBarData() async {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.blue.shade800,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String weekDay = DateFormat("EEEE").format(
                DateTime.now().subtract(Duration(days: 6 - group.x.toInt())));
            return BarTooltipItem(
              '$weekDay\n',
              const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  fontFamily: "OdibeeSans"),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY - 1).toString(),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: "OdibeeSans"),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          // setState(() {
          if (!event.isInterestedForInteractions ||
              barTouchResponse == null ||
              barTouchResponse.spot == null) {
            touchedIndex = -1;
            return;
          }
          touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          // });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: await _showingGroups(),
      gridData: FlGridData(show: false),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        fontSize: 16,
        fontFamily: "OdibeeSans");
    Widget text = Text(
        DateFormat("EEE")
            .format(DateTime.now().subtract(Duration(days: 6 - value.toInt()))),
        style: style);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
      animDuration + const Duration(milliseconds: 50),
    );
  }
}
