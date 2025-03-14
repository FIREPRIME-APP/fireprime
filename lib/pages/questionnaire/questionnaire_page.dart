import 'package:fireprime/fault_tree/node.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/model/event_probability.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/model/risk_assessment.dart';
import 'package:fireprime/pages/questionnaire/customised_intro.dart';
import 'package:fireprime/pages/questionnaire/multiple_choice_image.dart';
import 'package:fireprime/pages/result/results_loading_page.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/providers/images_provider.dart';
import 'package:fireprime/fault_tree/fault_tree.dart';
import 'package:fireprime/model/questionnaire.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:provider/provider.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:fireprime/pages/questionnaire/single_choice_image.dart';
import 'package:easy_localization/easy_localization.dart';

class QuestionnairePage extends StatefulWidget {
  final Map<String, String?> answers;

  const QuestionnairePage({super.key, required this.answers});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  @override
  void initState() {
    super.initState();
    // final houseProvider = Provider.of<HouseProvider>(context, listen: false);
    // houseProvider.getHazardValue();
  }

  Map<String?, String?> auxResult = {};

  Questionnaire questionnaire = Questionnaire();

  @override
  Widget build(BuildContext context) {
    // print('environment: ${questionnaire.environment}');

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
                      onResult: (SurveyResult result) async {
                        Map<String, String?> results = {};

                        if (result.finishReason == FinishReason.COMPLETED) {
                          saveEventdata(
                              screenId: 'questionnaire_page',
                              buttonId: 'finish');
                          results = _adaptedResult(results, result);

                          await houseProvider.setAnswers(
                              result.startDate, '1.0', results, 'Completed');

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

                          //await houseProvider.getHazardValue();
/*
                          await houseProvider.setCompleted(true, probability,
                              allProbabilities, result.endDate);
                          houseProvider.updateHouse();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return ResultPage(
                                    house: houseProvider
                                        .getHouse(houseProvider.currentHouse!));
                              },
                            ),
                          );*/
                        } else {
                          print('finishReason: ${result.finishReason}');
                          saveEventdata(
                              screenId: 'questionnaire_page',
                              buttonId: 'cancel');
                          results = _adaptedResult(answers, result);
                          print('answers in no completed: $answers');
                          await houseProvider.setAnswers(result.startDate,
                              '1.0', results, 'Not completed');
                          houseProvider.updateHouse();
                          Navigator.of(context).pop();
                        }
                      },
                      task: task,
                      showProgress: true,
                      localizations: <String, String>{
                        'cancel': context.tr('cancel'),
                        'next': context.tr('next')
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
                              progressbarColor: Colors.grey.shade200),
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
    await Provider.of<ImagesProvider>(context, listen: false)
        .getImagesJSON(environment);

    if (!context.mounted) {
      throw Exception('Widget not mounted');
    }

    List<Step> steps = setSteps();

    final NavigableTask task =
        NavigableTask(id: TaskIdentifier(), steps: steps);
    addNavigationRules(task);
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
      images: Provider.of<ImagesProvider>(context, listen: false)
              .containsKey(stepId)
          ? Provider.of<ImagesProvider>(context, listen: false)
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
          text: context.tr('questionnaire_intro'),
          showAppBar: true)
    ];

    for (var questions in questionnaire.questions) {
      if (questions['type'] == 'singleChoice') {
        steps.add(
          buildSingleChoiceImageStep(
              stepId: questions['stepId'],
              textChoices: questions['textChoices'],
              otherOption: questions['otherOption']),
        );
      } else if (questions['type'] == 'multipleChoice') {
        steps.add(
          buildMultipleChoiceImageStep(
              stepId: questions['stepId'],
              textChoices: questions['textChoices'],
              otherOption: questions['otherOption']),
        );
      } else if (questions['type'] == 'instructionStep') {
        steps.add(
          IntroductionCustomisedStep(
            stepIdentifier: StepIdentifier(id: questions['stepId']),
            title: context.tr('${questions['stepId']}.title'),
            text: context.tr('${questions['stepId']}.text'),
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

  MultipleChoiceImageStep buildMultipleChoiceImageStep(
      {required stepId, required textChoices, required otherOption}) {
    return MultipleChoiceImageStep(
      stepIdentifier: StepIdentifier(id: stepId),
      title: context.tr('$stepId.title'),
      text: context.tr('$stepId.question'),
      description: context.tr('$stepId.description'),
      images: Provider.of<ImagesProvider>(context, listen: false)
              .containsKey(stepId)
          ? Provider.of<ImagesProvider>(context, listen: false)
              .getImagePath(stepId, context)
          : [],
      otherOption: otherOption,
      answerFormat: MultipleChoiceAnswerFormat(
        textChoices: getTextChoices(textChoices, stepId),
        defaultSelection: getMultipleChoice(stepId),
        maxAnswers: 3,
      ),
    );
  }

  List<TextChoice> getMultipleChoice(String key) {
    List<TextChoice> choices = [];
    if (widget.answers.containsKey(key)) {
      for (var element in widget.answers[key]!.split(',')) {
        choices
            .add(TextChoice(text: context.tr('$key.$element'), value: element));
      }
    }
    return choices;
  }
}
