import 'package:fireprime/constants.dart';
import 'package:fireprime/fault_tree/events/basic_event.dart';
import 'package:fireprime/fault_tree/fault_tree.dart';
import 'package:fireprime/fault_tree/events/intermediate_event.dart';
import 'package:fireprime/fault_tree/node.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/widgets/gauge.dart';
import 'package:fireprime/model/event_probability.dart';
import 'package:fireprime/model/risk_assessment.dart';
import 'package:fireprime/pages/house/house_page.dart';
import 'package:fireprime/pages/mitigation/mitigation_menu_page.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/widgets/utils.dart';
import 'package:fireprime/widgets/card_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class ResultPage extends StatefulWidget {
  final House house;

  const ResultPage({super.key, required this.house});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  double probability = 0.0;

  double? lastProbability;

  Map<String, String?> answers = {};

  Map<String, EventProbability>? allProbabilities = {};
  Map<String, EventProbability>? lastAllProbabilities = {};

  Map<String, bool> _showLinearGauge = {};
  Map<String, EventProbability> subProbabilities = {};
  Map<String, EventProbability> lastSubProbabilities = {};

  @override
  void initState() {
    super.initState();

    final houseProvider = Provider.of<HouseProvider>(context, listen: false);

    RiskAssessment? riskAssessment = houseProvider.getRiskAssessment();
    RiskAssessment? oldRiskAssessment = houseProvider.getOldRiskAssessment();

    if (riskAssessment != null) {
      probability = riskAssessment.probability;
      allProbabilities = riskAssessment.allProbabilities;
      answers = riskAssessment.answers;

      for (var entry in allProbabilities!.entries) {
        for (var subEntry in entry.value.subEvents!.entries) {
          subProbabilities[subEntry.key] = subEntry.value;
        }
      }
    }

    if (oldRiskAssessment != null) {
      lastProbability = oldRiskAssessment.probability;
      lastAllProbabilities = oldRiskAssessment.allProbabilities;
      for (var entry in lastAllProbabilities!.entries) {
        for (var subEntry in entry.value.subEvents!.entries) {
          lastSubProbabilities[subEntry.key] = subEntry.value;
        }
      }

      print(lastSubProbabilities);
    }

    for (var entry in subProbabilities.entries) {
      _showLinearGauge[entry.key] = false;
    }
  }

  void _toggleLinearGauge(String key) {
    print(key);
    if (_showLinearGauge.containsKey(key)) {
      setState(() {
        if (_showLinearGauge[key]!) {
          _showLinearGauge[key] = false;
          saveEventdata(
              screenId: 'result_page',
              buttonId: 'hide_${_showLinearGauge[key]}_details');
        } else {
          _showLinearGauge.updateAll((key, value) => false);
          _showLinearGauge[key] = true;

          saveEventdata(
              screenId: 'result_page', buttonId: 'show_${key}_details');
        }
      });
    }
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
            saveEventdata(screenId: 'result_page', buttonId: 'back');
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
            Text(context.tr('vulnerability_text'),
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
                  Gauge.gaugeProbabilityText(
                      probability * 100, context.tr('vulnerability'), 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 10, 20),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 200,
                        ),
                        for (var entry in subProbabilities.entries)
                          Row(
                            children: [
                              Expanded(
                                child: CardText(
                                  title: context.tr(entry.key),
                                  text: (entry.value.probability * 100)
                                      .toStringAsFixed(0),
                                  size: 15,
                                  color: Utils.textColor(
                                    (entry.value.probability * 100),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              TextButton(
                                onPressed: () {
                                  saveEventdata(
                                      screenId: 'result_page',
                                      buttonId: 'show_details');
                                  _toggleLinearGauge(entry.key);
                                },
                                child: Text(
                                  context.tr('details'),
                                  style: const TextStyle(
                                    color: Constants.blueDark,
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            for (var entry in _showLinearGauge.entries)
              if (entry.value)
                Column(
                  children: [
                    const Divider(color: Colors.grey, thickness: 1.5),
                    Text(context.tr(entry.key),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Card(
                      child: Column(
                        children: [
                          ...subProbabilities[entry.key]!
                              .subEvents!
                              .entries
                              .map(
                            (subProb) {
                              Map<String, dynamic> options = canImprove(
                                  subProb.key, subProb.value.probability);
                              print(options);
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Gauge.linearGaugeWithTitle(
                                        context.tr(subProb.key),
                                        subProb.value.probability * 100,
                                        25,
                                        15,
                                        30,
                                        getLastSubProb(entry.key, subProb.key)),
                                  ),
                                  if (checkIfCanImprove(options))
                                    ElevatedButton(
                                      child: Text(context.tr('improve')),
                                      onPressed: () {
                                        saveEventdata(
                                            screenId: 'result_page',
                                            buttonId: 'mitigation');
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return MitigationMenuPage(
                                                mitigationId: subProb.key,
                                                improvementOptions: options,
                                                answers: answers,
                                                selectedMitigationProb:
                                                    subProb.value.probability,
                                                totalRisk: probability,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    )
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
        options = getOptions(basicEvents, selectedOptions);

        if (options.isNotEmpty && options['selectedOptions'].isNotEmpty) {
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

          if (options.isNotEmpty && options['selectedOptions'].isNotEmpty) {
            improvementOptions[event.id] = {
              'improvementOptions': options['improvementOptions'],
              'selectedOptions': options['selectedOptions']
            };
          }
        }
      }
    }
    print('improvementOptions: $improvementOptions');
    return improvementOptions;
  }

  Map<String, dynamic> getOptions(Map<String, double> basicEvents,
      Map<String, double> selectedProbabilities) {
    Set<String> options = {};
    double minProb = 1.0;
    for (var basicEvent in basicEvents.entries) {
      for (var answer in answers.values) {
        if (answer != null && answer.split(',').contains(basicEvent.key)) {
          selectedProbabilities[basicEvent.key] = basicEvent.value;
          if (basicEvent.value < minProb) {
            minProb = basicEvent.value;
          }
        }
      }
    }

    for (var basicEvent in basicEvents.entries) {
      //   for (var selectedProbability in selectedProbabilities.entries) {
      if (basicEvent.value < minProb) {
        options.add(basicEvent.key);
        //   }
      }
    }
    return {
      'improvementOptions': options,
      'selectedOptions': selectedProbabilities
    };
  }

  bool checkIfCanImprove(Map<String, dynamic> options) {
    bool canImprove = false;
    for (var entry in options.entries) {
      if (entry.value['improvementOptions'].isNotEmpty) {
        canImprove = true;
      }
    }
    return canImprove;
  }

  double? getLastSubProb(String key1, String key2) {
    if (lastSubProbabilities.containsKey(key1)) {
      if (lastSubProbabilities[key1]!.subEvents!.containsKey(key2)) {
        return lastSubProbabilities[key1]!.subEvents![key2]!.probability * 100;
      }
    }
    return null;
  }
}
