import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/model/area.dart';
import 'package:fireprime/model/basic_result.dart';
import 'package:fireprime/model/customised_image.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/model/questionnaire/basic_questionnaire.dart';
import 'package:fireprime/model/questionnaire/questionnaire.dart';
import 'package:fireprime/pages/house/basic/basic_house.dart';
import 'package:fireprime/pages/result/basic_result.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:survey_kit/survey_kit.dart';

class BasicQuestionnairePage extends StatefulWidget {
  //final String area;
  //final Map<String, String?> answers;
  const BasicQuestionnairePage({
    super.key,
    /* required this.answers*/
  });

  @override
  State<BasicQuestionnairePage> createState() => _BasicQuestionnairePageState();
}

class _BasicQuestionnairePageState extends State<BasicQuestionnairePage> {
  late BasicQuestionnaire questionnaire;

  @override
  Widget build(BuildContext context) {
    return Consumer<HouseProvider>(builder: (context, houseProvider, child) {
      Map<String, String?> answers = {};
      House? house;
      BasicResult? basicResult;
      if (houseProvider.currentHouse != null) {
        house = houseProvider.getHouse(houseProvider.currentHouse!);
        if (house.basicResultIds != null && house.basicResultIds!.isNotEmpty) {
          basicResult = houseProvider.getLastBasicResult();
          if (basicResult?.answers != null) {
            answers = basicResult!.answers;
          }
        }
      }
      return Scaffold(
        body: Container(
          color: Colors.white,
          child: FutureBuilder<Task>(
            future: getTask(
              context,
              house?.environment ?? 'default',
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
                  localizations: <String, String>{
                    'cancel': context.tr('cancel'),
                    'next': context.tr('next')
                  },
                  onResult: (result) async {
                    Map<String, String?> adaptedAnswers = {};
                    if (result.finishReason == FinishReason.COMPLETED) {
                      Map<String, String?> adaptedAnswers =
                          Questionnaire().adaptedResult({}, result);
                      int risk = questionnaire.getResult(answers);
                      String level = questionnaire.getRiskLevel(risk);

                      await houseProvider.setBasicAnswers(
                          result.startDate, adaptedAnswers, 'Completed');
                      await houseProvider.setBasicCompleted(
                        true,
                        risk,
                        result.endDate,
                        level,
                      );
                      houseProvider.updateHouse();

                      print('Task completed with result: $result');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            print('basic result page');
                            return const BasicResultPage();
                          },
                        ),
                      );
                      // print('Risk Level: $riskLevel');
                    } else {
                      print('Task not completed, result: $result');
                      adaptedAnswers =
                          Questionnaire().adaptedResult(answers, result);
                      await houseProvider.setBasicAnswers(
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
                      );
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

  Future<Task> getTask(BuildContext context, String areaCode,
      Map<String, String?> answers) async {
    if (!context.mounted) throw Exception('Context is not mounted');

    Locale currentLocale = Localizations.localeOf(context);
    String languageCode = currentLocale.languageCode;
    print('Current Locale: $currentLocale, Language Code: $languageCode');
    Map<String, dynamic> questionnaireJson =
        await BasicQuestionnaire.loadQuestionnaire(areaCode, languageCode);
    print('Questionnaire JSON: $questionnaireJson');
    Map<String, dynamic> areaJson = await Area.loadSettings(areaCode);
    print('Area JSON: $areaJson');
    Area area = Area.fromJson(areaJson);
    print('Area: $area');

    questionnaire = BasicQuestionnaire.fromJson(questionnaireJson, area);

    List<Step> steps = [];
    print('answers: $answers');
    steps.add(
      InstructionStep(
        stepIdentifier: StepIdentifier(id: 'intro'),
        title: context.tr('basic_questionnaire_title'),
        text: context.tr('basic_questionnaire_intro'),
      ),
    );

    for (var question in questionnaire.questions) {
      String questionId = question['id']!;
      String questionText = question['question']!;
      String? description = question['description'];
      String? title = question['title'];

      steps.add(
        Questionnaire().buildSingleChoiceImageStep(
          stepId: questionId,
          text: questionText,
          description: description,
          title: title,
          otherOption: false,
          context: context,
          answers: answers,
          textChoices: ['yes', 'no'],
          images: await getValidImages(questionnaire.images[questionId] ?? []),
          alwaysShowDescription: true,
        ),
      );
      print(steps);
    }

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
