import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/widgets/gauge.dart';
import 'package:fireprime/model/event_probability.dart';
import 'package:fireprime/model/risk_assessment.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HistoricalResultsPage extends StatefulWidget {
  final List<RiskAssessment> riskAssessments;

  const HistoricalResultsPage({super.key, required this.riskAssessments});

  @override
  State<HistoricalResultsPage> createState() => _HistoricalResultsPageState();
}

class _HistoricalResultsPageState extends State<HistoricalResultsPage> {
  int _touchedIndex = -1;

  double? lastProbability;
  Map<String, EventProbability>? lastAllProbabilities = {};
  Map<String, EventProbability>? allProbabilities = {};

  Map<String, EventProbability> lastSubProbabilities = {};
  Map<String, EventProbability> subProbabilities = {};

  List<RiskAssessment> riskAssessmentsToShow = [];
  @override
  void initState() {
    super.initState();
    _touchedIndex = 0;

    if (widget.riskAssessments.isNotEmpty) {
      if (widget.riskAssessments.length > 10) {
        for (int i = widget.riskAssessments.length - 10;
            i < widget.riskAssessments.length;
            i++) {
          riskAssessmentsToShow.add(widget.riskAssessments[i]);
        }
      } else {
        riskAssessmentsToShow = widget.riskAssessments;
      }

      if (riskAssessmentsToShow.last.completed) {
        _touchedIndex = riskAssessmentsToShow.length - 1;
      } else if (riskAssessmentsToShow.length > 1) {
        _touchedIndex = riskAssessmentsToShow.length - 2;
      }

      if (_touchedIndex > 0) {
        lastProbability = riskAssessmentsToShow[_touchedIndex - 1].probability;
        lastAllProbabilities =
            riskAssessmentsToShow[_touchedIndex - 1].allProbabilities;

        for (var entry in lastAllProbabilities!.entries) {
          for (var subEntry in entry.value.subEvents!.entries) {
            lastSubProbabilities[subEntry.key] = subEntry.value;
          }
        }
      }

      allProbabilities = riskAssessmentsToShow[_touchedIndex].allProbabilities;
      for (var entry in allProbabilities!.entries) {
        for (var subEntry in entry.value.subEvents!.entries) {
          subProbabilities[subEntry.key] = subEntry.value;
        }
      }
    }
  }

  void _toggleLinearGauge(var spotIndex) {
    saveEventdata(screenId: 'historical_result_page', buttonId: 'graphic');
    setState(
      () {
        _touchedIndex = spotIndex;
        allProbabilities =
            riskAssessmentsToShow[_touchedIndex].allProbabilities;
        for (var entry in allProbabilities!.entries) {
          for (var subEntry in entry.value.subEvents!.entries) {
            subProbabilities[subEntry.key] = subEntry.value;
          }
        }
        if (_touchedIndex > 0) {
          lastProbability =
              riskAssessmentsToShow[_touchedIndex - 1].probability;
          lastAllProbabilities =
              riskAssessmentsToShow[_touchedIndex - 1].allProbabilities;
          for (var entry in lastAllProbabilities!.entries) {
            for (var subEntry in entry.value.subEvents!.entries) {
              lastSubProbabilities[subEntry.key] = subEntry.value;
            }
          }
        } else {
          lastProbability = null;
          lastAllProbabilities = {};
          lastSubProbabilities = {};
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    for (int i = 0; i < riskAssessmentsToShow.length; i++) {
      if (riskAssessmentsToShow[i].completed) {
        spots.add(FlSpot(i.toDouble(), riskAssessmentsToShow[i].probability));
      }
      //spots.add(FlSpot(i.toDouble(), widget.riskAssessments[i].probability));
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
                        DateFormat('yyyy-MM-dd').format(
                            riskAssessmentsToShow[_touchedIndex].fiDate),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Gauge.linearGaugeWithTitle(
                          context.tr('vulnerability'),
                          riskAssessmentsToShow[_touchedIndex].probability *
                              100,
                          20,
                          15,
                          20,
                          lastProbability != null
                              ? lastProbability! * 100
                              : null),
                      const Divider(color: Colors.grey, thickness: 1.5),
                      for (var subEvent in subProbabilities.entries)
                        Column(
                          children: [
                            Gauge.linearGaugeWithTitle(
                              context.tr(subEvent.value.eventId),
                              subEvent.value.probability * 100,
                              20,
                              15,
                              20,
                              getLastProbability(
                                  lastAllProbabilities!, subEvent.key),
                            ),
                            if (subEvent.value.subEvents != null)
                              for (var subProbEvent
                                  in subEvent.value.subEvents!.entries)
                                Gauge.linearGaugeWithTitle(
                                  context.tr(subProbEvent.value.eventId),
                                  subProbEvent.value.probability * 100,
                                  20,
                                  15,
                                  20,
                                  getLastProbability(
                                      lastSubProbabilities, subProbEvent.key),
                                ),
                            const Divider(color: Colors.grey, thickness: 1.5),
                          ],
                        ),
                      // for (var subEvent in subProbabilities.entries)
                    ],
                  )
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
              _toggleLinearGauge(spotIndex);
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
    var roundedValue = (value * 100).toInt();

    String text;

    if (roundedValue % 5 == 0) {
      text = '${(value * 100).toInt()} ';
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
    if (value.toInt() >= riskAssessmentsToShow.length) {
      return const SizedBox();
    }
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    String formattedDate =
        dateFormat.format(riskAssessmentsToShow[value.toInt()].fiDate);
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

  double? getLastProbability(
      Map<String, EventProbability> probabilities, String key) {
    for (var subEvent in probabilities.entries) {
      for (var subProbEvent in subEvent.value.subEvents!.entries) {
        if (subProbEvent.key == key) {
          return subProbEvent.value.probability * 100;
        }
      }
    }
    return null;
  }
}
