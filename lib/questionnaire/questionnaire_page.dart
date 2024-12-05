import 'package:fireprime/controller/house_controller.dart';
import 'package:fireprime/controller/image_controller.dart';
import 'package:fireprime/fault_tree/fault_tree.dart';
import 'package:fireprime/model/questionnaire.dart';
import 'package:fireprime/result/result_page.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:provider/provider.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:fireprime/questionnaire/single_choice_image.dart';
import 'package:easy_localization/easy_localization.dart';

class QuestionnairePage extends StatefulWidget {
  final Map<String, String?> answers;

  const QuestionnairePage({super.key, required this.answers});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  Map<String?, String?> auxResult = {};

  Questionnaire questionnaire = Questionnaire();

  @override
  Widget build(BuildContext context) {
    // print('environment: ${questionnaire.environment}');

    FaultTree faultTree = FaultTree();

    return Consumer<HouseController>(
      builder: (context, house, child) {
        Map<String, String?> answers = {};
        if (house.currentHouse != null) {
          if (house.getHouse(house.currentHouse!).riskAssessments.isNotEmpty) {
            answers = house
                .getHouse(house.currentHouse!)
                .riskAssessments
                .last
                .answers;
          }
        }
        //  print('answersFromController: $answers');
        //  print('answersFromWidget: ${widget.answers}');
        return Scaffold(
          body: Container(
            color: Colors.white,
            child: Align(
              alignment: Alignment.center,
              child: FutureBuilder<Task>(
                future:
                    getQuestionnaireTask(context, questionnaire.environment),
                builder: (BuildContext context, AsyncSnapshot<Task> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData &&
                      snapshot.data != null) {
                    final Task task = snapshot.data!;
                    return SurveyKit(
                      onResult: (SurveyResult result) {
                        // print('onResult');

                        //print('afteradaptedResult');
                        Map<String, String?> results = {};

                        if (result.finishReason == FinishReason.COMPLETED) {
                          results = _adaptedResult(results, result);
                          house.setAnswers(
                              result.startDate, '1.0', results, 'Completed');
                          faultTree.setSelectedOptions(results);
                          double probability = faultTree
                              .calculateProbability(faultTree.topEvent);
                          Map<String, double> subProb =
                              faultTree.getProbabilities(faultTree.topEvent);

                          Map<String, Map<String, double>>
                              subNodeProbabilities = {};

                          for (var element in subProb.entries) {
                            Map<String, double> probabilities =
                                faultTree.getSubNodeProbabilities(element.key);
                            subNodeProbabilities[element.key] = probabilities;
                          }

                          house.setCompleted(true, probability, subProb,
                              subNodeProbabilities, result.endDate);
                          house.updateHouse();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return ResultPage(
                                    house: house.getHouse(house.currentHouse!));
                              },
                            ),
                          );
                        } else {
                          print('finishReason: ${result.finishReason}');
                          /*House currentHouse =
                              house.getHouse(house.currentHouse!);*/
                          /* if (currentHouse.riskAssessments.isEmpty ||
                              !currentHouse.riskAssessments.last.completed) {*/
                          results = _adaptedResult(answers, result);
                          print('answers in no completed: $answers');
                          house.setAnswers(result.startDate, '1.0', results,
                              'Not completed');
                          // }
                          house.updateHouse();
                          Navigator.of(context).pop();
                        }
                      },
                      task: task,
                      showProgress: true,
                      localizations: <String, String>{
                        'cancel': context.tr(
                            'cancel'), //AppLocalizations.of(context)!.cancel,
                        'next': context
                            .tr('next') //AppLocalizations.of(context)!.next,
                      },
                      themeData: Theme.of(context),
                      surveyProgressbarConfiguration:
                          SurveyProgressConfiguration(
                        backgroundColor: Colors.white,
                      ),
                    );
                  }
                  return const CircularProgressIndicator.adaptive();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Task> getQuestionnaireTask(
      BuildContext context, String environment) async {
    await Provider.of<ImageController>(context, listen: false)
        .getImagesJSON(environment);

    if (!context.mounted) {
      throw Exception('Widget not mounted');
    }

    List<Step> steps = setSteps();

    final NavigableTask task = NavigableTask(
        id: TaskIdentifier(),
        steps:
            steps/*<Step>[
        InstructionStep(
          title: context.tr('questionnaire'),
          text: context.tr('startFill'),
          showAppBar: true,
        ),
        buildSingleChoiceImageStep(
            stepId: 'material-1',
            textChoices: ['timber', 'vinylSiding', 'concreteBricks'],
            otherOption: true),
        buildSingleChoiceImageStep(
            stepId: 'roof-1',
            textChoices: ['roofFireRated', 'roofNonFireRated'],
            otherOption: false),
        buildSingleChoiceImageStep(
            stepId: 'roof-2',
            textChoices: ['roofPoorlyMaintaned', 'roofWellMaintained'],
            otherOption: false),
        buildSingleChoiceImageStep(
            stepId: 'glazing-1',
            textChoices: ['singlePane', 'doublePane', 'tempered'],
            otherOption: false),
        buildSingleChoiceImageStep(
            stepId: 'glazing-2',
            textChoices: [
              'notAllProtected',
              'wood',
              'aluminium',
              'pvc',
              'fireRated'
            ],
            otherOption: false),
        buildSingleChoiceImageStep(
            stepId: 'vents-1',
            textChoices: ['noVentProtection', 'allProtected', 'noVents'],
            otherOption: false),
        buildSingleChoiceImageStep(
            stepId: 'vents-2',
            textChoices: [
              'combustibleProtection',
              'nonCombBadCond',
              'nonCombGoodCond'
            ],
            otherOption: false),
        buildSingleChoiceImageStep(
            stepId: 'semiConf-1',
            textChoices: ['yesSemiConf', 'noSemiConf'],
            otherOption: false),
        buildSingleChoiceImageStep(
            stepId: 'semiConf-2',
            textChoices: ['glazingSystems', 'noGlazingSystems'],
            otherOption: false),
        buildSingleChoiceImageStep(
            stepId: 'semiConf-3',
            textChoices: ['combustibleEnvelope', 'nonCombThin', 'nonCombThick'],
            otherOption: false),
        CompletionStep(
          stepIdentifier: StepIdentifier(id: 'completionStep'),
          text: context.tr('checkVuln'),
          title: context.tr('done'),
          buttonText: context.tr('check'),
        ),
      ],*/
        );

    addNavigationRules(task);

    /* task.addNavigationRule(
      forTriggerStepIdentifier: StepIdentifier(id: 'material-1'),
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (String? input) {
          auxResult['material-1'] = input;

          return StepIdentifier(id: 'roof-1');
        },
      ),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: StepIdentifier(id: 'glazing-1'),
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (String? input) {
          auxResult['glazing-1'] = input;
          // print(auxResult);
          return StepIdentifier(id: 'glazing-2');
        },
      ),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: StepIdentifier(id: 'vents-1'),
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (String? input) {
          if (input == 'noVentProtection' || input == 'noVents') {
            return StepIdentifier(id: 'semiConf-1');
            //return StepIdentifier(id: 'vents-2');
          } else {
            return StepIdentifier(id: 'vents-2');
          }
        },
      ),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: StepIdentifier(id: 'semiConf-1'),
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (String? input) {
          if (input == 'yesSemiConf') {
            return StepIdentifier(id: 'semiConf-2');
            //return StepIdentifier(id: 'vents-2');
          } else {
            if (auxResult['glazing-1'] == 'singlePane') {
              return StepIdentifier(id: 'completionStep'); //TODO
              //return StepIdentifier(id: 'fuels-close-1a');
            } else {
              return StepIdentifier(id: 'completionStep'); //TODO
              //return StepIdentifier(id: 'fuels-close-1b');
            }
          }
        },
      ),
    );*/
    /*task.addNavigationRule(
      forTriggerStepIdentifier: StepIdentifier(id: 'fuels-close-2a'),
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (String? input) {
          if (auxResult['material-1'] == 'timber' ||
              auxResult['material-1'] == 'vinylSiding') {
            return StepIdentifier(id: 'fuels-close-3');
          } else {
            return StepIdentifier(id: 'fuels-close-4');
          }
        },
      ),
    );*/
    /* task.addNavigationRule(
      forTriggerStepIdentifier: StepIdentifier(id: 'fuels-close-1b'),
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (String? input) {
          if (auxResult['material-1'] == 'timber' ||
              auxResult['material-1'] == 'vinylSiding') {
            return StepIdentifier(id: 'fuels-close-3');
          } else {
            return StepIdentifier(id: 'fuels-close-4');
          }
        },
      ),
    );*/
    // print('after');
    return Future<Task>.value(task);
  }

  SingleChoiceImageStep buildSingleChoiceImageStep({
    required String stepId,
    required List<String> textChoices,
    required bool otherOption,
  }) {
    return SingleChoiceImageStep(
      stepIdentifier: StepIdentifier(id: stepId),
      title: context.tr('$stepId.title'),
      text: context.tr('$stepId.question'),
      description: context.tr('$stepId.description'),
      images: Provider.of<ImageController>(context, listen: false)
              .containsKey(stepId)
          ? Provider.of<ImageController>(context, listen: false)
              .getImagePath(stepId, context)
          : [],
      otherOption: otherOption,
      answerFormat: SingleChoiceAnswerFormat(
        textChoices: getTextChoices(textChoices, stepId),
        defaultSelection: getChoice(stepId),
      ),
    );
  }

  List<Step> setSteps() {
    List<Step> steps = [
      InstructionStep(
          title: context.tr('questionnaire'),
          text: context.tr('startFill'),
          showAppBar: true)
    ];

    for (var questions in questionnaire.questions) {
      steps.add(
        buildSingleChoiceImageStep(
            stepId: questions['stepId'],
            textChoices: questions['textChoices'],
            otherOption: questions['otherOption']),
      );
    }

    steps.add(
      CompletionStep(
        stepIdentifier: StepIdentifier(id: 'completionStep'),
        title: context.tr('checkVuln'),
        text: context.tr('done'),
        buttonText: context.tr('check'),
      ),
    );

    return steps;
  }

  List<TextChoice> getTextChoices(List<String> choices, String stepId) {
    List<TextChoice> textChoices = [];
    for (var element in choices) {
      textChoices.add(
          TextChoice(text: context.tr('$stepId.$element'), value: element));
    }
    return textChoices;
  }

  TextChoice? getChoice(String key) {
    return widget.answers.containsKey(key)
        ? TextChoice(
            text: context.tr('$key.${widget.answers[key]}'),
            value: widget.answers[key]!)
        : null;
  }

  Map<String, String?> _adaptedResult(
    Map<String, String?> adaptedResult,
    SurveyResult result,
  ) {
    print('adaptedResult');

    for (var stepResult in result.results) {
      for (var questionResult in stepResult.results) {
        adaptedResult[stepResult.id!.id] = questionResult.valueIdentifier;
      }
    }
    return adaptedResult;
  }

  void addNavigationRules(NavigableTask task) {
    for (var navigation in questionnaire.navigations) {
      if (navigation['type'] == 'saveResult') {
        task.addNavigationRule(
          forTriggerStepIdentifier: StepIdentifier(id: navigation['stepId']),
          navigationRule: ConditionalNavigationRule(
            resultToStepIdentifierMapper: (String? input) {
              auxResult[navigation['stepId']] = input;
              print(auxResult[navigation['stepId']]);
              print('navigation: ${navigation['nextStep']}');
              if (navigation.containsKey('conditions')) {
                return StepIdentifier(id: navigation['conditions'][input]);
              } else {
                return StepIdentifier(id: navigation['nextStep']);
              }
            },
          ),
        );
      } else if (navigation['type'] == 'conditional') {
        task.addNavigationRule(
          forTriggerStepIdentifier: StepIdentifier(id: navigation['stepId']),
          navigationRule: ConditionalNavigationRule(
            resultToStepIdentifierMapper: (String? input) {
              return StepIdentifier(id: navigation['conditions'][input]);
            },
          ),
        );
      } else if (navigation['type'] == 'conditionalSavedResult') {
        task.addNavigationRule(
          forTriggerStepIdentifier: StepIdentifier(id: navigation['stepId']),
          navigationRule: ConditionalNavigationRule(
            resultToStepIdentifierMapper: (String? input) {
              if (navigation['conditions'].containsKey(input)) {
                return StepIdentifier(id: navigation['conditions'][input]);
              } else {
                String? auxInput = auxResult[navigation['savedResult']['id']];
                if (navigation['savedResult']['conditions']
                    .containsKey(auxInput)) {
                  return StepIdentifier(
                      id: navigation['savedResult']['conditions'][auxInput]);
                } else {
                  print(auxInput);
                  throw Exception('No navigation rule found');
                }
              }
            },
          ),
        );
      }
    }
  }
}
