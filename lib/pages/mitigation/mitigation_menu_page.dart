import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/fault_tree/fault_tree.dart';
import 'package:fireprime/fault_tree/node.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/pages/house/house_list_page.dart';
import 'package:fireprime/pages/mitigation/mitigation_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MitigationMenuPage extends StatefulWidget {
  final String mitigationId;

  final Map<String, dynamic> answers;
  final Map<String, dynamic> improvementOptions;

  final double selectedMitigationProb;
  final double totalRisk;

  const MitigationMenuPage({
    super.key,
    required this.mitigationId, //'glazing system'
    required this.answers, // userSelected Answers
    required this.improvementOptions, // possible improvements
    required this.selectedMitigationProb, // probability mitigationId
    required this.totalRisk,
  }); // total risk

  @override
  State<MitigationMenuPage> createState() => _MitigationMenuPageState();
}

class _MitigationMenuPageState extends State<MitigationMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            context.tr('mitigations_actions'),
            style: Theme.of(context).textTheme.titleLarge!,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            saveEventdata(screenId: 'mitigation_menu', buttonId: 'back');
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                saveEventdata(screenId: 'mitigation_menu', buttonId: 'home');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const HouseListPage();
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.improvementOptions.isNotEmpty) //
              ...widget.improvementOptions.entries.map(
                (entry) => entry.value['improvementOptions'].isNotEmpty &&
                        entry.value['selectedOptions'].isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 20.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Card(
                            child: GestureDetector(
                              onTap: () {
                                saveEventdata(
                                    screenId: 'mitigation_menu',
                                    buttonId: widget.mitigationId);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      Node? mitigationNode = FaultTree()
                                          .getNode(widget.mitigationId);

                                      List<String> affectedQuestions =
                                          getAffectedQuestions(widget.answers,
                                              entry.value['selectedOptions']);
                                      /*widget
                                          .answers.keys
                                          .where((answerKey) => entry
                                              .value['selectedOptions']
                                              .containsKey(
                                                  widget.answers[answerKey]))
                                          .toList();*/
                                      print(
                                          'afectedQuestions: $affectedQuestions');
                                      return MitigationActions(
                                        answers: widget.answers,
                                        selectedProbability:
                                            widget.selectedMitigationProb,
                                        totalRisk: widget.totalRisk,
                                        mitigationNode: mitigationNode,
                                        improvementOptions:
                                            entry.value['improvementOptions'],
                                        affectedQuestions: affectedQuestions,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 15.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        context.tr(entry.key),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_right,
                                        color: Color.fromARGB(255, 86, 97, 123),
                                        size: 30),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            /*...widget.options!.entries.map(
                  (entry) => ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value.toString()),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            Node? mitigationNode =
                                FaultTree().getNode(widget.mitigationId);

                            Map<String, double> basicEvents = FaultTree()
                                .getBasicEvents(
                                    FaultTree().topEvent, entry.key);

                            List<String> affectedQuestions = widget.answers.keys
                                .where((answerKey) => basicEvents
                                    .containsKey(widget.answers[answerKey]))
                                .toList();

                            return MitigationActions(
                              answers: widget.answers,
                              affectedQuestions: affectedQuestions,
                              basicEvents: basicEvents,
                              selectedProbability:
                                  widget.selectedMitigationProb,
                              totalRisk: widget.totalRisk,
                              mitigationNode: mitigationNode,
                              options: widget.options,
                            );
                          },
                        ),
                      );
                    },
                  ),
                )*/
            //else
            /* ListTile(
              title: Text(widget.mitigationId.toString()),
              subtitle: Text(widget.selectedMitigationProb.toString()),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const MitigationActions(
                        answers: {}, affectedQuestions: [],
                        basicEvents: {},
                        selectedProbability: 0.0,
                        totalRisk: 0.0,
                        mitigationNode: null,
                        options: {},
                        //answers: widget.answers[widget.mitigationId],
                        //options: widget.options
                      );
                    },
                  ),
                );
              },
            ),*/
          ],
        ),
      ),
      /*FutureBuilder<Map<String, dynamic>>(
        future: _loadMitigations(languageCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontFamily: 'OpenSans'),
              ),
            );
          }
          if (snapshot.hasData) {
            Map<String, dynamic> mitigations = snapshot.data!;
            if (mitigations.containsKey(widget.mitigationId)) {
              var mitigationsById = mitigations[widget.mitigationId];

              if (mitigationsById == null) {
                return Center(
                  child: Text(
                    context.tr('no_mitigations'),
                    style: const TextStyle(fontFamily: 'OpenSans'),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              var menuItems = mitigationsById['mitigations_menu'];

              return SingleChildScrollView(
                child: Column(
                  children: [
                    for (var item in menuItems)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 20.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Card(
                            child: GestureDetector(
                              onTap: () {
                                print('tap');
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return MitigationPage(
                                        mitigationTitle: item['title'],
                                        mitigationActions: item['mitigations'],
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 15.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['title'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_right,
                                        color: Color.fromARGB(255, 86, 97, 123),
                                        size: 30),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              );
            } else {
              return Center(
                child: Text(
                  context.tr('no_mitigations'),
                  style: const TextStyle(fontFamily: 'OpenSans'),
                  textAlign: TextAlign.center,
                ),
              );
            }
          }
          return Center(
            child: Text(
              context.tr('no_mitigations'),
              style: const TextStyle(fontFamily: 'OpenSans'),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),*/
    );
  }

  Future<Map<String, dynamic>> _loadMitigations(String languageCode) async {
    try {
      String filePath = 'assets/mitigations_text/$languageCode.json';
      String data = await rootBundle.loadString(filePath);
      return json.decode(data);
    } catch (e) {
      print(e);
      throw Exception('Failed to load mitigations');
    }
  }

  List<String> getAffectedQuestions(Map<String, dynamic> answers, value) {
    List<String> affectedQuestions = [];

    for (var entry in answers.entries) {
      if (entry.value is String) {
        List<String> answerValues = (entry.value as String).split(',');

        if (answerValues.any((answer) => value.containsKey(answer.trim()))) {
          affectedQuestions.add(entry.key);
        }
      }
    }
    return affectedQuestions;
  }
}
