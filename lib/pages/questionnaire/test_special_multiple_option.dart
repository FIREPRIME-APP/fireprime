import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/model/customised_image.dart';
import 'package:fireprime/model/questionnaire/basic_questionnaire.dart';
import 'package:fireprime/model/questionnaire/questionnaire.dart';
import 'package:fireprime/pages/questionnaire/customised_question_types/customised_intro.dart';
import 'package:fireprime/pages/questionnaire/customised_question_types/special_multiple_choice.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:survey_kit/survey_kit.dart';

class TestQuestionnairePage extends StatefulWidget {
  const TestQuestionnairePage({
    super.key,
  });

  @override
  State<TestQuestionnairePage> createState() => _TestQuestionnairePageState();
}

class _TestQuestionnairePageState extends State<TestQuestionnairePage> {
  late BasicQuestionnaire questionnaire;

  @override
  Widget build(BuildContext context) {
    return Consumer<HouseProvider>(builder: (context, houseProvider, child) {
      Map<String, String?> answers = {};

      return Scaffold(
        body: Container(
          color: Colors.white,
          child: FutureBuilder<Task>(
            future: getTask(
              context,
              // house?.environment ?? 'default',
              answers,
            ),
            builder: (BuildContext context, AsyncSnapshot<Task> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final task = snapshot.data;

                return SurveyKit(
                  task: task!,
                  showProgress: true,
                  surveyController: SurveyController(
                    onNextStep: (context, resultFunction) {
                      return true;
                    },
                    onStepBack: (context, resultFunction) {
                      return true;
                    },
                    onCloseSurvey: (context, resultFunction) => true,
                  ),
                  localizations: <String, String>{
                    'cancel': context.tr('cancel'),
                    'next': context.tr('next')
                  },
                  surveyProgressbarConfiguration: SurveyProgressConfiguration(
                    backgroundColor: Colors.white,
                    showLabel: true,
                    label: (from, to) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '[$from / $to]',
                        style: const TextStyle(
                            color: Colors.black, fontSize: 13.0),
                      ),
                    ),
                    progressbarColor: Colors.grey.shade200,
                  ),
                  onResult: (result) async {
                    Map<String, String?> adaptedAnswers = {};
                    if (result.finishReason == FinishReason.COMPLETED) {
                      Map<String, String?> adaptedAnswers =
                          Questionnaire().adaptedResult({}, result);
                      /* int risk = questionnaire.getResult(adaptedAnswers);
                      String level = questionnaire.getRiskLevel(risk);
                      print(risk);
                      await houseProvider.setBasicAnswers(
                          result.startDate, adaptedAnswers, 'Completed');
                      await houseProvider.setBasicCompleted(
                        true,
                        risk,
                        result.endDate,
                        level,
                      );
                      await houseProvider.updateHouse();

                      print('Task completed with result: $result');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            print('basic result page');
                            return const BasicResultPage();
                          },
                        ),
                      );
                      // print('Risk Level: $riskLevel');*/
                      print('Task completed with result: $adaptedAnswers');
                    } else {
                      print('Task not completed, result: $result');
                      adaptedAnswers =
                          Questionnaire().adaptedResult(answers, result);
                      /* await houseProvider.setBasicAnswers(
                          result.startDate, adaptedAnswers, 'Not completed');
                      print('---');
                      houseProvider.updateHouse();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            print('return');
                            return const BasicHousePage();
                          },
                        ),
                      );*/
                      print('Adapted Answers: $adaptedAnswers');
                    }
                  },
                );
              }
            },
          ),
        ),
      );
    });
  }

  Future<Task> getTask(
      BuildContext context,
      /*String areaCode,*/
      Map<String, String?> answers) async {
    if (!context.mounted) throw Exception('Context is not mounted');

    List<Step> steps = [];
    print('answers: $answers');
    steps.add(
      IntroductionCustomisedStep(
          stepIdentifier: StepIdentifier(id: 'intro'),
          title: 'Test',
          text: 'This is a test questionnaire.',
          showAppBar: false,
          buttonText: 'Start'),
    );

    steps.add(
      SpecialMultipleChoiceImageStep(
          stepIdentifier: StepIdentifier(id: 'test_special_multiple_option'),
          title: 'Test Special Multiple Option',
          text: 'Select all that apply.',
          description: 'This is a special multiple option question.',
          answerFormat: const MultipleChoiceAnswerFormat(
            textChoices: [
              TextChoice(value: 'option1', text: 'Option 1'),
              TextChoice(value: 'option2', text: 'Option 2'),
              TextChoice(value: 'option3', text: 'Option 3'),
              TextChoice(value: 'optionSpecial', text: 'Option Special'),
            ],
          ),
          images: [],
          allTextChoices: {
            'option1.1':
                const TextChoice(value: 'option1.1', text: 'Option 1.1'),
            'option1': const TextChoice(value: 'option1', text: 'Option 1'),
            'option2.1':
                const TextChoice(value: 'option2.1', text: 'Option 2.1'),
            'option2': const TextChoice(value: 'option2', text: 'Option 2'),
            'option3.1':
                const TextChoice(value: 'option3.1', text: 'Option 3.1'),
            'option3': const TextChoice(value: 'option3', text: 'Option 3'),
          },
          initialSelection: [
            const TextChoice(value: 'option1.1', text: 'Option 1.1'),
            const TextChoice(value: 'option2.1', text: 'Option 2.1'),
            const TextChoice(value: 'option3.1', text: 'Option 3.1'),
          ],
          rules: {
            'option1': 'option1.1',
            'option2': 'option2.1',
            'option3': 'option3.1',
          },
          specialSelection: 'optionSpecial',
          buttonText: 'Next'),
    );

    steps.add(CompletionStep(
        stepIdentifier: StepIdentifier(id: 'completion'),
        title: 'Thank you',
        text: 'You have completed the questionnaire.',
        buttonText: 'Finish'));

    final NavigableTask task =
        NavigableTask(id: TaskIdentifier(), steps: steps);
    return Future<Task>.value(task);
  }

  Future<bool> _checkImageExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<CustomisedImage>> getValidImages(
      List<CustomisedImage> images) async {
    final List<CustomisedImage> validImages = [];
    if (images.isEmpty) return validImages;
    for (final image in images) {
      if (await _checkImageExists(image.path)) {
        validImages.add(image);
      }
    }
    return validImages;
  }
}
