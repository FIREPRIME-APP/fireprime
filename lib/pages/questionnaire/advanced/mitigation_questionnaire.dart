import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/fault_tree/fault_tree.dart';
import 'package:fireprime/model/event_probability.dart';
import 'package:fireprime/model/questionnaire/questionnaire.dart';
import 'package:fireprime/pages/result/advanced/results_loading_page.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/providers/images_provider.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:survey_kit/survey_kit.dart';

class MitigationQuestionnaire extends StatefulWidget {
  final Map<String, String?> answers;
  final String questionsId;

  const MitigationQuestionnaire({
    super.key,
    required this.answers,
    required this.questionsId,
  });

  @override
  State<MitigationQuestionnaire> createState() =>
      _MitigationQuestionnaireState();
}

class _MitigationQuestionnaireState extends State<MitigationQuestionnaire> {
  Map<String, dynamic> navigation = {};

  @override
  Widget build(BuildContext context) {
    HouseProvider houseCtrl =
        Provider.of<HouseProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Align(
          alignment: Alignment.center,
          child: FutureBuilder<Task>(
            future: getTask(widget.questionsId, widget.answers),
            builder: (BuildContext context, AsyncSnapshot<Task> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data != null) {
                final Task task = snapshot.data!;
                return SurveyKit(
                  showProgress: false,
                  task: task,
                  localizations: {
                    "next": context.tr('next'),
                    "cancel": context.tr('cancel'),
                  },
                  appBar: (appBarConfiguration) {
                    return AppBar(
                      title: Text(
                        context.tr('improve'),
                        style: Theme.of(context).textTheme.titleLarge!,
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                  onResult: (SurveyResult result) async {
                    if (result.finishReason == FinishReason.COMPLETED) {
                      for (var stepResult in result.results) {
                        for (var questionResult in stepResult.results) {
                          widget.answers[questionResult.id!.id] =
                              questionResult.valueIdentifier;
                        }
                      }

                      if (navigation.containsKey(widget.questionsId)) {
                        final deleteList = (navigation[widget.questionsId]
                                    ?[widget.answers[widget.questionsId]]
                                ?['delete'] as List?)
                            ?.cast<String>();

                        if (deleteList != null) {
                          for (var question in deleteList) {
                            widget.answers.remove(question);
                          }
                        }
                      }

                      await houseCtrl.setAnswers(result.startDate, '1.0',
                          widget.answers, 'Completed', null);

                      print('After pressing improve button ${widget.answers}');
                      FaultTree().setSelectedOptions(widget.answers);
                      double newVulnerability = FaultTree()
                          .calculateProbability(FaultTree().topEvent);

                      Map<String, EventProbability> allProbabilities =
                          FaultTree().getAllNodePorbabilities(
                              FaultTree().topEvent, {});

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return ResultsLoadingPage(
                                house:
                                    houseCtrl.getHouse(houseCtrl.currentHouse!),
                                vulnerability: newVulnerability,
                                allProbabilities: allProbabilities,
                                endDate: result.endDate,
                                answers: widget.answers);
                          },
                        ),
                      );
                    } else {
                      print('finish reason: ${result.finishReason}');

                      Navigator.of(context).pop();
                    }
                    /* Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          print('before loading page');
                          return ResultsLoadingPage(
                            house: houseCtrl.getHouse(houseCtrl.currentHouse!),
                            vulnerability: newVulnerability,
                            allProbabilities: allProbabilities,
                            endDate: result.endDate,
                            answers: widget.answers,
                          );
                        },
                      ),
                    );*/

                    //  Navigator.of(context).pop();
                    //TODO SI TENIA UN CUESTIONARIO EMPEZADO?
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading task: ${snapshot.error}'),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<Task> getTask(String questionId, Map<String, String?> answers) async {
    var imgCtrl = Provider.of<ImagesProvider>(context, listen: false);

    if (imgCtrl.images.isEmpty) {
      await imgCtrl.getImagesJSON(Questionnaire().environment);
    }

    navigation = await getQuestionsNavigation(questionId);

    if (!context.mounted) {
      throw Exception('Widget not mounted');
    }

    List<String> affectedQuestions = [questionId];
    String answer = answers[questionId] ?? '';

    if (navigation.containsKey(questionId)) {
      final addList =
          (navigation[questionId]?[answer]?['add'] as List?)?.cast<String>();
      if (addList != null) {
        affectedQuestions.addAll(addList);
      }
    }

    print('Affected questions: $affectedQuestions');

    List<Step> steps = [];

    List<Map<String, dynamic>> questions =
        Questionnaire().questions.where((element) {
      return affectedQuestions.contains(element['stepId']);
    }).toList();
    /*List<Map<String, dynamic>> questions = [];

    for (var qId in questionsId) {
      for (var question in Questionnaire().questions) {
        if (question['stepId'] == qId) {
          questions.add(question);
        }
      }
    }*/

    print('Questions: $questions');
    for (var question in questions) {
      if (question['type'] == 'singleChoice') {
        steps.add(
          Questionnaire().buildSingleChoiceImageStep(
            stepId: question['stepId'],
            textChoices: question['textChoices'] as List<String>,
            otherOption: false,
            context: context,
            answers: answers,
            buttonText: context.tr('next'),
          ),
        );
      } else if (question['type'] == 'multipleChoice') {
        steps.add(Questionnaire().buildMultipleChoiceImageStep(
          stepId: question['stepId'],
          textChoices: question['textChoices'] as List<String>,
          otherOption: false,
          context: context,
          answers: answers,
          buttonText: context.tr('next'),
        ));
      }
    }

    steps.add(
      CompletionStep(
          stepIdentifier: StepIdentifier(id: 'complete'),
          title: context.tr('questionnaire_finish_text'),
          buttonText: context.tr('done'),
          text: context.tr('save_answers')),
    );

    final NavigableTask task =
        NavigableTask(id: TaskIdentifier(), steps: steps);

    if (navigation.containsKey(questionId)) {
      if (navigation[questionId]?[answer]?['navigation'] != null) {
        Map<String, dynamic> navigationMap =
            navigation[questionId]?[answer]?['navigation'];

        print('navigationMap: $navigationMap');
        task.addNavigationRule(
          forTriggerStepIdentifier: StepIdentifier(id: questionId),
          navigationRule: ConditionalNavigationRule(
            resultToStepIdentifierMapper: (String? input) {
              if (navigationMap.containsKey(input)) {
                print('Im in: $input ${navigationMap[input]}');
                return StepIdentifier(id: navigationMap[input]);
              } else {
                return null;
              }
            },
          ),
        );
      }
    }

    print('STEPS: ${task.steps}');

    return Future<Task>.value(task);
  }

  Future<Map<String, dynamic>> getQuestionsNavigation(String questionId) async {
    try {
      String jsonString = await rootBundle
          .loadString('assets/mitigations_text/navigation.json');
      Map<String, dynamic> jsonData = jsonDecode(jsonString);

      Map<String, dynamic> navigation = {};

      if (jsonData.containsKey(questionId)) {
        navigation[questionId] = jsonData[questionId];
      }
      print('navigation: $navigation');
      return navigation;
    } catch (e) {
      print('Error getting questions navigation: $e');
    }
    return {};
  }
}

/*  SingleChoiceImageStep(
      stepIdentifier: StepIdentifier(id: question['stepId']),
      title: context.tr(question['title']),
      text: context.tr(question['text']),
      description: context.tr(question['description'] ?? ''),
      images: Provider.of<ImagesProvider>(context, listen: false)
              .containsKey(question['stepId'])
          ? Provider.of<ImagesProvider>(context, listen: false)
              .getImagePath(question['stepId'], context)
          : [],
      otherOption: false,
      answerFormat: SingleChoiceAnswerFormat(
        textChoices: getTextChoices(textChoices, stepId),
        defaultSelection: getChoice(stepId),
      ),
    );
        );
      } else {
        
      }*/
