import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/gauge.dart';
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
  Map<String, double> lastSubProb = {};

  @override
  void initState() {
    super.initState();
    _touchedIndex = 0;
    if (widget.riskAssessments.isNotEmpty) {
      if (widget.riskAssessments.last.completed) {
        _touchedIndex = widget.riskAssessments.length - 1;
      } else if (widget.riskAssessments.length > 1) {
        _touchedIndex = widget.riskAssessments.length - 2;
      }

      if (_touchedIndex > 0) {
        lastProbability = widget.riskAssessments[_touchedIndex - 1].probability;
        lastSubProb = widget.riskAssessments[_touchedIndex - 1].results;
      }
    }
  }

  void _toggleLinearGauge(var spotIndex) {
    setState(
      () {
        _touchedIndex = spotIndex;
        if (_touchedIndex > 0) {
          lastProbability =
              widget.riskAssessments[_touchedIndex - 1].probability;
          lastSubProb = widget.riskAssessments[_touchedIndex - 1].results;
        } else {
          lastProbability = null;
          lastSubProb = {};
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    for (int i = 0; i < widget.riskAssessments.length; i++) {
      if (widget.riskAssessments[i].completed) {
        spots.add(FlSpot(i.toDouble(), widget.riskAssessments[i].probability));
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
                            widget.riskAssessments[_touchedIndex].fiDate),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Gauge.linearGaugeProb(
                          context.tr('structural_vulnerabilities'),
                          widget.riskAssessments[_touchedIndex].probability *
                              100,
                          20,
                          15,
                          20,
                          lastProbability != null
                              ? lastProbability! * 100
                              : null),
                      const Divider(color: Colors.grey, thickness: 1.5),
                      ...widget.riskAssessments[_touchedIndex].results.entries
                          .map(
                        (entry) {
                          return Gauge.linearGaugeProb(
                              context.tr(entry.key),
                              entry.value * 100,
                              20,
                              15,
                              20,
                              lastSubProb.containsKey(entry.key)
                                  ? lastSubProb[entry.key]! * 100
                                  : null);
                        },
                      )
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
    if (value.toInt() >= widget.riskAssessments.length) {
      return const SizedBox();
    }
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    String formattedDate =
        dateFormat.format(widget.riskAssessments[value.toInt()].fiDate);
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
