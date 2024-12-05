import 'package:fireprime/fault_tree/fault_tree.dart';
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

  Map<String, String?> answers = {};
  Map<String, Map<String, double>> subNodeProbabilities = {};

  @override
  void initState() {
    super.initState();

    int riskAsssessmentsSize = widget.house.riskAssessments.length;
    if (widget.house.riskAssessments.last.completed) {
      probability = widget.house.riskAssessments.last.probability;
      subProb = widget.house.riskAssessments.last.results;
      answers = widget.house.riskAssessments.last.answers;
      subNodeProbabilities =
          widget.house.riskAssessments.last.subNodeProbabilities;

      if (riskAsssessmentsSize > 1) {
        lastProbability =
            widget.house.riskAssessments[riskAsssessmentsSize - 2].probability;
        lastSubProb =
            widget.house.riskAssessments[riskAsssessmentsSize - 2].results;
      }
    } else {
      //To get the comparison with the last completed risk assessment
      if (riskAsssessmentsSize > 1) {
        probability =
            widget.house.riskAssessments[riskAsssessmentsSize - 2].probability;
        subProb =
            widget.house.riskAssessments[riskAsssessmentsSize - 2].results;
        answers =
            widget.house.riskAssessments[riskAsssessmentsSize - 2].answers;
        subNodeProbabilities = widget.house
            .riskAssessments[riskAsssessmentsSize - 2].subNodeProbabilities;

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
                            Map<String, dynamic> options =
                                canImprove(entry.key, entry.value);
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Gauge.linearGaugeWithTitle(
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
                                if (checkIfCanImprove(options))
                                  ElevatedButton(
                                    child: Text(context.tr('improve')),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (BuildContext context) {
                                            return MitigationMenuPage(
                                              mitigationId: entry.key,
                                              improvementOptions: options,
                                              answers: answers,
                                              selectedMitigationProb:
                                                  entry.value,
                                              totalRisk: probability,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
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

  Map<String, dynamic> canImprove(
      String mitigationId, double selectedMitigationProb) {
    Map<String, dynamic> improvementOptions = {};

    Node? node = FaultTree().getNode(mitigationId);

    Map<String, dynamic> options = {};
    Map<String, double> basicEvents = {};

    if (node != null && node is IntermediateEvent) {
      if (node.gate.inputEvents[0] is BasicEvent) {
        Map<String, double> selectedOptions = {};

        basicEvents = FaultTree().getBasicEvents(node, node.id);
        print(node.gate.id);
        options = getOptions(basicEvents, selectedOptions);

        if (options.isNotEmpty) {
          improvementOptions[node.id] = {
            'improvementOptions': options['improvementOptions'],
            'selectedOptions': options['selectedOptions']
          };
        }
      } else {
        for (var event in node.gate.inputEvents) {
          Map<String, double> selectedOptions = {};

          basicEvents = FaultTree().getBasicEvents(event, event.id);

          options = getOptions(basicEvents, selectedOptions);

          if (options.isNotEmpty) {
            improvementOptions[event.id] = {
              'improvementOptions': options['improvementOptions'],
              'selectedOptions': options['selectedOptions']
            };
          }
        }
      }
    }
    print(improvementOptions);
    return improvementOptions;
  }

  Map<String, dynamic> getOptions(Map<String, double> basicEvents,
      Map<String, double> selectedProbabilities) {
    Set<String> options = {};

    for (var basicEvent in basicEvents.entries) {
      if (answers.containsValue(basicEvent.key)) {
        selectedProbabilities[basicEvent.key] = basicEvent.value;
      }
    }

    for (var basicEvent in basicEvents.entries) {
      for (var selectedProbability in selectedProbabilities.entries) {
        if (basicEvent.value < selectedProbability.value) {
          options.add(basicEvent.key);
        }
      }
    }
    return {
      'improvementOptions': options,
      'selectedOptions': selectedProbabilities
    };
  }

  checkIfCanImprove(Map<String, dynamic> options) {
    for (var entry in options.entries) {
      if (entry.value['improvementOptions'].isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}
