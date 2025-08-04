import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/model/area.dart';
import 'package:fireprime/model/questionnaire/basic_questionnaire.dart';
import 'package:fireprime/model/questionnaire/questionnaire.dart';
import 'package:fireprime/pages/result/basic_result.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:survey_kit/survey_kit.dart';

class BasicQuestionnairePage extends StatefulWidget {
  final String area;
  const BasicQuestionnairePage({super.key, required this.area});

  @override
  State<BasicQuestionnairePage> createState() => _BasicQuestionnairePageState();
}

class _BasicQuestionnairePageState extends State<BasicQuestionnairePage> {
  late BasicQuestionnaire questionnaire;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: FutureBuilder<Task>(
          future: getTask(context, widget.area),
          builder: (BuildContext context, AsyncSnapshot<Task> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final task = snapshot.data;
              return SurveyKit(
                task: task!,
                onResult: (result) {
                  if (result.finishReason == FinishReason.COMPLETED) {
                    Map<String, String?> answers =
                        Questionnaire().adaptedResult({}, result);
                    print(answers);
                    int score = questionnaire.getResult(answers);
                    print(score);
                    print('Task completed with result: $result');

                    //String riskLevel = questionnaire.getRiskLevel(score);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return BasicResultPage(
                            questionnaire: questionnaire,
                            score: score,
                          );
                        },
                      ),
                    );
                    // print('Risk Level: $riskLevel');
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<Task> getTask(BuildContext context, String areaCode) async {
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
          answers: {},
          textChoices: ['yes', 'no'],
          images: questionnaire.images[questionId] ?? [],
          alwaysShowDescription: true,
        ),
      );
      print(steps);
    }

    final NavigableTask task =
        NavigableTask(id: TaskIdentifier(), steps: steps);
    return Future<Task>.value(task);
  }
}
