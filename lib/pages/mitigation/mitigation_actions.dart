import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/fault_tree/fault_tree.dart';
import 'package:fireprime/fault_tree/node.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/widgets/gauge.dart';
import 'package:flutter/material.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';

class MitigationActions extends StatefulWidget {
  const MitigationActions({
    super.key,
    required this.answers,
    required this.affectedQuestions,
    required this.selectedProbability,
    required this.houseVulnerability,
    this.mitigationNode,
    required this.improvementOptions,
    required this.hazard,
  });

  final Map<String, dynamic> answers;
  final Set<String> improvementOptions;
  final List<String> affectedQuestions;
  final double selectedProbability;
  final double houseVulnerability;
  final Node? mitigationNode;
  final double hazard;

  @override
  State<MitigationActions> createState() => _MitigationActionsState();
}

class _MitigationActionsState extends State<MitigationActions> {
  String? _selectedChoice;
  double? _newVulnerability;
  double? _newMitigationRisk;

  Map<String, List<String>> _options = {};
  List<String> _selectedOptions = [];

  @override
  void initState() {
    super.initState();
    for (var question in widget.affectedQuestions) {
      List<String> options = [];
      for (var option in widget.improvementOptions) {
        if ('$question.$option' != tr('$question.$option')) {
          options.add(option);
        }
      }
      _options[question] = options;
    }

    for (var question in widget.affectedQuestions) {
      if (widget.answers[question].contains(',')) {
        _selectedOptions.addAll(widget.answers[question].split(','));
      } else {
        _selectedOptions.add(widget.answers[question]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String?> auxAnswers = Map.from(widget.answers);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('mitigations_actions'),
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            saveEventdata(screenId: 'mitigation_action', buttonId: 'back');
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 8.0, 25, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Text(context.tr('actualSituation'),
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold)),
              Text(context.tr('selectedOption'),
                  style: const TextStyle(fontSize: 16.0)),
              const SizedBox(
                height: 10,
              ),
              for (var question in widget.affectedQuestions)
                Column(
                  children: [
                    for (var selectedOption in _selectedOptions) ...[
                      if ('$question.$selectedOption' !=
                          tr('$question.$selectedOption')) ...[
                        Text(context.tr('$question.$selectedOption'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15.0)),
                        const SizedBox(height: 10),
                        const Divider(
                          color: Colors.grey,
                        ),
                      ],
                    ],
                  ],
                ),
              linearGaugeWithValue(widget.selectedProbability),
              const Divider(color: Colors.grey),
              Text(context.tr('applyImprovement'),
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold)),
              Text(context.tr('improveOptions'),
                  style: const TextStyle(fontSize: 15.0)),
              for (var question in widget.affectedQuestions)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _options[question]!.length,
                  itemBuilder: (context, index) {
                    var option = _options[question]!.elementAt(index);
                    //  if ('$question.$option' != tr('$question.$option')) {
                    return ListTile(
                        title: Text(context.tr('$question.$option'),
                            style: const TextStyle(fontSize: 15)),
                        onTap: () {
                          saveEventdata(
                              screenId: 'mitigation_action',
                              buttonId: 'select_option');
                          setState(
                            () {
                              if (_selectedChoice != option) {
                                _selectedChoice = option;
                              }
                              auxAnswers[question] = option;
                              FaultTree().setSelectedOptions(auxAnswers);
                              _newVulnerability = FaultTree()
                                  .calculateProbability(FaultTree().topEvent);

                              if (widget.mitigationNode != null) {
                                _newMitigationRisk = FaultTree()
                                    .calculateProbability(
                                        widget.mitigationNode!);
                              }
                            },
                          );
                        },
                        iconColor: _selectedChoice == option
                            ? const Color.fromARGB(255, 86, 97, 123)
                            : Colors.black,
                        textColor: _selectedChoice == option
                            ? const Color.fromARGB(255, 86, 97, 123)
                            : Colors.black,
                        trailing: _selectedChoice == option
                            ? const Icon(Icons.check)
                            : null);
                  },
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.grey),
                ),
              const Divider(color: Colors.grey),
              _newMitigationRisk != null
                  ? linearGaugeWithValue(_newMitigationRisk!)
                  : linearGaugeWithValue(widget.selectedProbability),
              const SizedBox(
                height: 10,
              ),
              Text(context.tr('totalVulnerability'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18.0)),
              const SizedBox(
                height: 10,
              ),
              _newVulnerability != null
                  ? radialGauge(
                      _newVulnerability!,
                      widget.houseVulnerability,
                    )
                  : radialGauge(
                      widget.houseVulnerability,
                      widget.houseVulnerability,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  checkOptions(Set<String> improvementOptions, String question) {
    for (var option in improvementOptions) {
      if ('$question.$option' != tr('$question.$option')) {
        return true;
      }
    }
    return false;
  }

  Widget linearGaugeWithValue(double probability) {
    return Row(
      children: [
        Text((probability * 100).toStringAsFixed(0),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Expanded(child: Gauge.linearGauge(probability * 100, 25, 15, 30, null)),
      ],
    );
  }

  Widget radialGauge(double newVunlerability, double beforeVulnerability) {
    return Stack(
      children: [
        Center(
          child: SizedBox(
            height: 250,
            child: RadialGauge(
              track: const RadialTrack(
                start: 0,
                end: 100,
                hideTrack: true,
                trackStyle: TrackStyle(
                    labelStyle: TextStyle(color: Colors.black),
                    showLabel: false,
                    showPrimaryRulers: true,
                    showSecondaryRulers: false),
                thickness: 15,
              ),
              valueBar: [
                RadialValueBar(
                  value: newVunlerability * 100,
                  valueBarThickness: 13,
                  color: const Color.fromARGB(255, 137, 155, 197),
                ),
                RadialValueBar(
                  value: beforeVulnerability * 100,
                  valueBarThickness: 13,
                  color: const Color.fromARGB(255, 86, 97, 123),
                  radialOffset: 13,
                )
              ],
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              const SizedBox(height: 100),
              gaugelegend(newVunlerability, 'now',
                  const Color.fromARGB(255, 137, 155, 197)),
              gaugelegend(beforeVulnerability, 'before',
                  const Color.fromARGB(255, 86, 97, 123)),
            ],
          ),
        )
      ],
    );
  }

  Widget gaugelegend(double risk, String text, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          color: color,
        ),
        const SizedBox(width: 5),
        Text('${context.tr(text)}: ${(risk * 100).toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 15.0)),
      ],
    );
  }
}
