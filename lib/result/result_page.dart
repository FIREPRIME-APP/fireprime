import 'package:fireprime/gauge.dart';
import 'package:fireprime/house/house_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ResultPage extends StatefulWidget {
  final Map<String, double> subProb;
  final double probability;

  const ResultPage(
      {super.key, required this.probability, required this.subProb});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _showLinearGauge = false;

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
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Text(context.tr('vulnerability'),
                style: Theme.of(context).textTheme.titleLarge!),
            Card(
              child: Stack(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        _toggleLinearGauge();
                      },
                      child: Container(
                        height: 200,
                        width: 200,
                        padding: const EdgeInsets.all(20),
                        color: Colors.transparent,
                        child:
                            Gauge.radialGauge(widget.probability * 100, 15, 6),
                      ),
                    ),
                  ),
                  Gauge.gaugeProbabilityText(widget.probability * 100,
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
                        ...widget.subProb.entries.map(
                          (entry) {
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Gauge.linearGaugeProb(
                                  context.tr(entry.key),
                                  entry.value * 100,
                                  25,
                                  15,
                                  30),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ResultPage(
      probability: 0.2,
      subProb: {'Structural Vulnerability': 0.2, 'Roof': 0.3, 'Glazing': 0.8},
    ),
  ));
}
