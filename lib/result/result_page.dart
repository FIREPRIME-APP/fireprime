import 'package:fireprime/gauge.dart';
import 'package:fireprime/house/house_page.dart';
import 'package:fireprime/mitigation/mitigation_menu_page.dart';
import 'package:fireprime/model/house.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ResultPage extends StatefulWidget {
  //final Map<String, double> subProb;
  //final double probability;
  final House house;

  const ResultPage(
      {super.key,
      required this.house /*required this.probability, required this.subProb*/});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _showLinearGauge = false;

  double probability = 0.0;
  Map<String, double> subProb = {};

  double? lastProbability;
  Map<String, double> lastSubProb = {};

  @override
  void initState() {
    super.initState();

    int riskAsssessmentsSize = widget.house.riskAssessments.length;
    if (widget.house.riskAssessments.last.completed) {
      probability = widget.house.riskAssessments.last.probability;
      subProb = widget.house.riskAssessments.last.results;

      if (riskAsssessmentsSize > 1) {
        lastProbability =
            widget.house.riskAssessments[riskAsssessmentsSize - 2].probability;
        lastSubProb =
            widget.house.riskAssessments[riskAsssessmentsSize - 2].results;
      }
    } else {
      if (riskAsssessmentsSize > 1) {
        probability =
            widget.house.riskAssessments[riskAsssessmentsSize - 2].probability;
        subProb =
            widget.house.riskAssessments[riskAsssessmentsSize - 2].results;

        if (riskAsssessmentsSize > 2) {
          lastProbability = widget
              .house.riskAssessments[riskAsssessmentsSize - 3].probability;
          lastSubProb =
              widget.house.riskAssessments[riskAsssessmentsSize - 3].results;
        }
      }
    }
  }

  void _toggleLinearGauge() {
    setState(() {
      _showLinearGauge = !_showLinearGauge;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('results'),
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const HousePage();
                },
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(context.tr('vulnerability'),
                style: Theme.of(context).textTheme.titleLarge!),
            Card(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 200,
                      width: 200,
                      padding: const EdgeInsets.all(20),
                      color: Colors.transparent,
                      child: Gauge.radialGauge(probability * 100, 15, 6),
                    ),
                  ),
                  Gauge.gaugeProbabilityText(probability * 100,
                      context.tr('structural_vulnerabilities'), 20),
                ],
              ),
            ),
            if (_showLinearGauge)
              Column(
                children: [
                  const Divider(color: Colors.grey, thickness: 1.5),
                  Card(
                    child: Column(
                      children: [
                        ...subProb.entries.map(
                          (entry) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Gauge.linearGaugeProb(
                                      context.tr(entry.key),
                                      entry.value * 100,
                                      25,
                                      15,
                                      30,
                                      lastSubProb.isNotEmpty &&
                                              lastSubProb.containsKey(entry.key)
                                          ? lastSubProb[entry.key]! * 100
                                          : null),
                                ),
                                ElevatedButton(
                                    child: Text(context.tr('improve')),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (BuildContext context) {
                                            print(entry.key);
                                            return MitigationMenuPage(
                                              mitigationId: entry.key,
                                            );
                                          },
                                        ),
                                      );
                                    }),
                              ],
                            );
                          },
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ElevatedButton(
                onPressed: () {
                  _toggleLinearGauge();
                },
                child: _showLinearGauge
                    ? Text(context.tr('hide_details'))
                    : Text(context.tr('show_details'))),
          ],
        ),
      ),
    );
  }
}
