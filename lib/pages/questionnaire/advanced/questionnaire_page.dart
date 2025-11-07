//import 'dart:ffi';

import 'package:fireprime/fault_tree/node.dart';
//import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/model/event_probability.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/model/risk_assessment.dart';
import 'package:fireprime/pages/questionnaire/customised_question_types/customised_intro.dart';
import 'package:fireprime/pages/result/advanced/results_loading_page.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/providers/images_provider.dart';
import 'package:fireprime/fault_tree/fault_tree.dart';
import 'package:fireprime/model/questionnaire/questionnaire.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:provider/provider.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:easy_localization/easy_localization.dart';

class QuestionnairePage extends StatefulWidget {
  final String? lastQuestionId;

  const QuestionnairePage(
      {super.key, /*required this.answers,*/ this.lastQuestionId});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  @override
  void initState() {
    super.initState();
  }

  Map<String?, String?> auxResult = {};

  Questionnaire questionnaire = Questionnaire();

  String? auxStepId;

  @override
  Widget build(BuildContext context) {
    FaultTree faultTree = FaultTree();

    return Consumer<HouseProvider>(
      builder: (context, houseProvider, child) {
        Map<String, String?> answers = {};
        RiskAssessment? riskAssessment;
        if (houseProvider.currentHouse != null) {
          House house = houseProvider.getHouse(houseProvider.currentHouse!);
          if (house.riskAssessmentIds.isNotEmpty) {
            riskAssessment = houseProvider.getLastRiskAssessment();
            if (riskAssessment?.answers != null) {
              answers = riskAssessment!.answers;
            }
          }
        }

        return Scaffold(
          body: Container(
            color: Colors.white,
            child: Align(
              alignment: Alignment.center,
              child: FutureBuilder<Task>(
                future: getQuestionnaireTask(context, questionnaire.environment,
                    widget.lastQuestionId, answers),
                builder: (BuildContext context, AsyncSnapshot<Task> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData &&
                      snapshot.data != null) {
                    final Task task = snapshot.data!;
                    return SurveyKit(
                      surveyController: SurveyController(
                        onNextStep: (context, resultFunction) {
                          final result = resultFunction.call();
                          print('onNextStep');
                          print('result: $result');
                          auxStepId = result.id?.id;
                          return true;
                        },
                        onStepBack: (context, resultFunction) {
                          return true;
                        },
                        onCloseSurvey: (context, resultFunction) {
                          return true;
                        },
                      ),
                      onResult: (SurveyResult result) async {
                        Map<String, String?> results = {};

                        if (result.finishReason == FinishReason.COMPLETED) {
                          /*  saveEventdata(
                              screenId: 'questionnaire_page',
                              buttonId: 'finish'); */
                          results =
                              Questionnaire().adaptedResult(results, result);

                          await houseProvider.setAnswers(result.startDate,
                              '1.0', results, 'Completed', null);

                          faultTree.setSelectedOptions(results);
                          print('RESULTS: $results');

                          double probability = faultTree
                              .calculateProbability(faultTree.topEvent);

                          Node? topEvent = faultTree.topEvent;

                          Map<String, EventProbability> allProbabilities =
                              faultTree.getAllNodePorbabilities(topEvent, {});

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return ResultsLoadingPage(
                                    house: houseProvider.getHouse(
                                      houseProvider.currentHouse!,
                                    ),
                                    vulnerability: probability,
                                    allProbabilities: allProbabilities,
                                    endDate: result.endDate,
                                    answers: results);
                              },
                            ),
                          );
                        } else {
                          print('finishReason: ${result.finishReason}');
                          /*    saveEventdata(
                              screenId: 'questionnaire_page',
                              buttonId: 'cancel'); */
                          results =
                              Questionnaire().adaptedResult(answers, result);

                          if (auxStepId != null) {
                            print('lastStepId: $auxStepId');
                            await houseProvider.setAnswers(result.startDate,
                                '1.0', results, 'Not completed', auxStepId);
                          } else {
                            await houseProvider.setAnswers(result.startDate,
                                '1.0', results, 'Not completed', null);
                          }
                          houseProvider.updateHouse();

                          Navigator.of(context).pop();
                        }
                      },
                      task: task,
                      showProgress: true,
                      localizations: <String, String>{
                        'cancel': context.tr('cancel'),
                        // 'next': context.tr('next')
                      },
                      themeData: Theme.of(context),
                      surveyProgressbarConfiguration:
                          SurveyProgressConfiguration(
                        backgroundColor: Colors.white,
                        showLabel: true,
                        label: (from, to) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '[$from / $to]',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13.0,
                            ),
                          ),
                        ),
                        progressbarColor: Colors.grey.shade200,
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

  Future<Task> getQuestionnaireTask(BuildContext context, String environment,
      String? lastQuestionId, Map<String, String?> answers) async {
    await Provider.of<ImagesProvider>(context, listen: false)
        .getImagesJSON(environment);

    if (!context.mounted) {
      throw Exception('Widget not mounted');
    }

    List<Step> steps = setSteps(answers);

    //Step? lastStep;

    /* if (lastQuestionId != null) {
      for (var step in steps) {
        if (step.stepIdentifier.id == lastQuestionId) {
          lastStep = step;
          break;
        }
      }
    }*/

    final NavigableTask task =
        NavigableTask(id: TaskIdentifier(), steps: steps);
    addNavigationRules(task);

    /*TaskNavigator navigator = NavigableTaskNavigator(task);
    navigator.record(steps.first);*/

    return Future<Task>.value(task);
  }

  List<Step> setSteps(Map<String, String?> answers) {
    List<Step> steps = [
      IntroductionCustomisedStep(
          stepIdentifier: StepIdentifier(id: 'introduction'),
          title: context.tr('questionnaire'),
          text: context.tr('questionnaire_intro'),
          showAppBar: false,
          buttonText: context.tr('start'))
    ];

    for (var questions in questionnaire.questions) {
      if (questions['type'] == 'singleChoice') {
        steps.add(
          Questionnaire().buildSingleChoiceImageStep(
            stepId: questions['stepId'],
            textChoices: questions['textChoices'],
            otherOption: questions['otherOption'],
            context: context,
            answers: answers,
            buttonText: context.tr('next'),
          ),
        );
      } else if (questions['type'] == 'multipleChoice') {
        steps.add(Questionnaire().buildMultipleChoiceImageStep(
          stepId: questions['stepId'],
          textChoices: questions['textChoices'],
          otherOption: questions['otherOption'],
          context: context,
          answers: answers,
          buttonText: context.tr('next'),
        ));
      } else if (questions['type'] == 'specialMultipleChoice') {
        steps.add(
          Questionnaire().buildSpecialMultipleChoiceImageStep(
            stepId: questions['stepId'],
            textChoices: questions['textChoices'],
            allTextChoices: questions['allTextChoices'],
            rules: questions['rules'],
            initialSelection: questions['initialSelection'],
            specialSelection: questions['specialSelection'],
            context: context,
            answers: answers,
            buttonText: context.tr('next'),
          ),
        );
      } else if (questions['type'] == 'instructionStep') {
        steps.add(
          IntroductionCustomisedStep(
            stepIdentifier: StepIdentifier(id: questions['stepId']),
            title: context.tr('${questions['stepId']}.title'),
            text: context.tr('${questions['stepId']}.text'),
            buttonText: context.tr('next'),
          ),
        );
      }
    }

    steps.add(
      CompletionStep(
        stepIdentifier: StepIdentifier(id: 'completionStep'),
        title: context.tr('questionnaire_finish_text'),
        text: context.tr('done'),
        buttonText: context.tr('check'),
      ),
    );

    return steps;
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
        print(navigation['stepId']);
        task.addNavigationRule(
          forTriggerStepIdentifier: StepIdentifier(id: navigation['stepId']),
          navigationRule: ConditionalNavigationRule(
            resultToStepIdentifierMapper: (String? input) {
              print('input: $input');
              if (navigation['conditions'].containsKey(input)) {
                return StepIdentifier(id: navigation['conditions'][input]);
              } else {
                print('----');
                String? auxInput = auxResult[navigation['savedResult']['id']];
                //TODO SI ESTÁ NULO, MIRIAR DIRECTAMENTE ANSWERS
                if (navigation['savedResult']['conditions']
                    .containsKey(auxInput)) {
                  print('auxInput: $auxInput');
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
