import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/model/basic_result.dart';
import 'package:fireprime/widgets/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BasicHistoricalResultsPage extends StatefulWidget {
  final List<BasicResult> basicResults;

  const BasicHistoricalResultsPage({super.key, required this.basicResults});

  @override
  State<BasicHistoricalResultsPage> createState() =>
      _BasicHistoricalResultsPageState();
}

class _BasicHistoricalResultsPageState
    extends State<BasicHistoricalResultsPage> {
  int _touchedIndex = -1;

  int? lastRisk;
  String lastLevel = 'Unknown';

  List<BasicResult> basicResultsToShow = [];

  @override
  void initState() {
    super.initState();
    _touchedIndex = 0;

    if (widget.basicResults.isNotEmpty) {
      if (widget.basicResults.length > 10) {
        for (int i = widget.basicResults.length - 10;
            i < widget.basicResults.length;
            i++) {
          basicResultsToShow.add(widget.basicResults[i]);
        }
      } else {
        basicResultsToShow = widget.basicResults;
      }

      if (basicResultsToShow.last.completed) {
        _touchedIndex = basicResultsToShow.length - 1;
      } else if (basicResultsToShow.length > 1) {
        _touchedIndex = basicResultsToShow.length - 2;
      }
      if (_touchedIndex > 0) {
        lastRisk = basicResultsToShow[_touchedIndex - 1].risk;
        lastLevel = basicResultsToShow[_touchedIndex - 1].riskLevel;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    for (int i = 0; i < basicResultsToShow.length; i++) {
      if (basicResultsToShow[i].completed) {
        spots.add(
            FlSpot(i.toDouble(), basicResultsToShow[i].risk.toDouble() / 10));
      }
      //spots.add(FlSpot(i.toDouble(), widget.basicResults[i].probability));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('myResults'),
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          onPressed: () {
            saveEventdata(screenId: 'historical_result_page', buttonId: 'back');
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: lineChart(spots),
                ),
                if (_touchedIndex != -1)
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        DateFormat('yyyy-MM-dd')
                            .format(basicResultsToShow[_touchedIndex].fiDate),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          color: Utils.getBasicRiskColor(
                              basicResultsToShow[_touchedIndex].riskLevel),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${basicResultsToShow[_touchedIndex].risk}/10',
                              style: Theme.of(context).textTheme.bodyMedium!,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '${context.tr('result_intro')}: ${context.tr('risk_levels.${basicResultsToShow[_touchedIndex].riskLevel}')[0].toUpperCase() + context.tr('risk_levels.${basicResultsToShow[_touchedIndex].riskLevel}').substring(1)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget lineChart(var spots) {
    return LineChart(
      LineChartData(
        borderData: FlBorderData(
          show: true,
          border: const Border(
              bottom: BorderSide(
                  color: Color.fromARGB(255, 86, 97, 123), width: 2)),
        ),
        gridData: const FlGridData(
          show: false,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: const Color.fromARGB(255, 127, 142, 176),
            barWidth: 5,
            isCurved: true,
            curveSmoothness: 0.5,
            preventCurveOverShooting: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (FlSpot spot, double xPercentage,
                  LineChartBarData bar, int index) {
                if (_touchedIndex == index) {
                  return FlDotCirclePainter(
                    radius: 8,
                    color: const Color.fromARGB(255, 86, 97, 123),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }

                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color.fromARGB(255, 134, 149, 185),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 86, 97, 123),
                  Color.fromARGB(255, 134, 149, 185)
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchSpotThreshold: 20,
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            if (response == null || response.lineBarSpots == null) {
              return;
            }
            if (event is FlTapUpEvent) {
              final spotIndex = response.lineBarSpots!.first.spotIndex;
              setState(() {
                _touchedIndex = spotIndex;
                if (_touchedIndex > 0) {
                  lastRisk = basicResultsToShow[_touchedIndex - 1].risk;
                  lastLevel = basicResultsToShow[_touchedIndex - 1].riskLevel;
                } else {
                  lastRisk = null;
                  lastLevel = 'Unknown';
                }
              });
            }
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(
            axisNameSize: 20,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: leftTilesWidgets,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 90,
              getTitlesWidget: bottomTitlesWidgets,
            ),
          ),
        ),
        minY: 0,
        maxY: 1,
      ),
    );
  }

  Widget leftTilesWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12, color: Colors.black);
    var roundedValue = (value * 10).toInt();

    String text;

    if (roundedValue % 5 == 0) {
      text = '${(value * 10).toInt()} ';
    } else {
      text = '';
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  Widget bottomTitlesWidgets(double value, TitleMeta meta) {
    if (value.toInt() >= basicResultsToShow.length) {
      return const SizedBox();
    }
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    String formattedDate =
        dateFormat.format(basicResultsToShow[value.toInt()].fiDate);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      angle: 30,
      fitInside: const SideTitleFitInsideData(
          axisPosition: 10,
          distanceFromEdge: 0,
          enabled: true,
          parentAxisSize: 80),
      child: Text(
        formattedDate.toString(),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
