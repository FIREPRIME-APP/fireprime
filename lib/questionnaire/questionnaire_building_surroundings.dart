/*import 'package:flutter/material.dart' hide Step;
import 'package:survey_kit/survey_kit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fireprime/questionnaire/introduction_customised.dart';
import 'package:fireprime/questionnaire/single_choice_image.dart';

class QuestionnaireBuildingSurroundWidget extends StatefulWidget {
  final Map<String, String?> characteristicsResults;

  const QuestionnaireBuildingSurroundWidget(
      {super.key, required this.characteristicsResults});

  @override
  State<QuestionnaireBuildingSurroundWidget> createState() =>
      _QuestionnaireBuildingSurroundWidgetState();
}

class _QuestionnaireBuildingSurroundWidgetState
    extends State<QuestionnaireBuildingSurroundWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Align(
          alignment: Alignment.center,
          child: FutureBuilder<Task>(
            future: getSurroundingsTask(context, widget.characteristicsResults),
            builder: (BuildContext context, AsyncSnapshot<Task> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data != null) {
                final Task task = snapshot.data!;
                return SurveyKit(
                  onResult: (SurveyResult result) {
                    print(result.finishReason);
                    Navigator.pushNamed(context, '/');
                  },
                  task: task,
                  showProgress: true,
                  localizations: <String, String>{
                    'cancel': AppLocalizations.of(context)!.cancel,
                    'next': AppLocalizations.of(context)!.next,
                  },
                  themeData: Theme.of(context),
                  surveyProgressbarConfiguration: SurveyProgressConfiguration(
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
  }

  Future<Task> getSurroundingsTask(
      BuildContext context, Map<String, String?> result) {
    final NavigableTask task = NavigableTask(
      id: TaskIdentifier(),
      steps: <Step>[
        /* InstructionStep(
          stepIdentifier: StepIdentifier(id: 'surroundings-start'),
          title: AppLocalizations.of(context)!.questionnaire,
          text: AppLocalizations.of(context)!.startFill,
          showAppBar: true,
        ),*/
        IntroductionCustomisedStep(
            stepIdentifier: StepIdentifier(id: 'h'),
            title: 'Hello',
            text: 'helloollololo'),
        SingleChoiceImageStep(
          stepIdentifier: StepIdentifier(id: 'fuels-close-1a'),
          title: AppLocalizations.of(context)!.fuels_close + '1',
          text: AppLocalizations.of(context)!.fuels_close_1a_question,
          description: AppLocalizations.of(context)!.fuels_close_1a_description,
          images: {},
          otherOption: false,
          answerFormat: SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: AppLocalizations.of(context)!.yes, value: 'yes'),
              TextChoice(text: AppLocalizations.of(context)!.no, value: 'no'),
            ],
          ),
        ),
        SingleChoiceImageStep(
          stepIdentifier: StepIdentifier(id: 'fuels-close-2a'),
          title: AppLocalizations.of(context)!.fuels_close + '2',
          text: AppLocalizations.of(context)!.fuels_close_2a_question,
          description: AppLocalizations.of(context)!.fuels_close_2a_description,
          images: {},
          otherOption: false,
          answerFormat: SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: AppLocalizations.of(context)!.yes, value: 'yes'),
              TextChoice(text: AppLocalizations.of(context)!.no, value: 'no'),
            ],
          ),
        ),
        SingleChoiceImageStep(
          stepIdentifier: StepIdentifier(id: 'fuels-close-1b'),
          title: AppLocalizations.of(context)!.fuels_close + '1b',
          text: AppLocalizations.of(context)!.fuels_close_1b_question,
          description: AppLocalizations.of(context)!.fuels_close_1b_description,
          images: {},
          otherOption: false,
          answerFormat: SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: AppLocalizations.of(context)!.yes, value: 'yes'),
              TextChoice(text: AppLocalizations.of(context)!.no, value: 'no'),
            ],
          ),
        ),
        SingleChoiceImageStep(
          stepIdentifier: StepIdentifier(id: 'fuels-close-3'),
          title: AppLocalizations.of(context)!.fuels_close + '3',
          text: AppLocalizations.of(context)!.fuels_close_3_question,
          description: AppLocalizations.of(context)!.fuels_close_3_description,
          images: {},
          otherOption: false,
          answerFormat: SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: AppLocalizations.of(context)!.yes, value: 'yes'),
              TextChoice(text: AppLocalizations.of(context)!.no, value: 'no'),
              TextChoice(
                  text: AppLocalizations.of(context)!.notApplicable,
                  value: 'notApplicable'),
            ],
          ),
        ),
        SingleChoiceImageStep(
          stepIdentifier: StepIdentifier(id: 'fuels-close-4'),
          title: AppLocalizations.of(context)!.fuels_close + '4',
          text: AppLocalizations.of(context)!.fuels_close_4_question,
          description: AppLocalizations.of(context)!.fuels_close_4_description,
          images: {},
          otherOption: false,
          answerFormat: SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: AppLocalizations.of(context)!.yes, value: 'yes'),
              TextChoice(text: AppLocalizations.of(context)!.no, value: 'no'),
              TextChoice(
                  text: AppLocalizations.of(context)!.notApplicable,
                  value: 'notApplicable'),
            ],
          ),
        ),
        SingleChoiceImageStep(
          stepIdentifier: StepIdentifier(id: 'fuels-close-5'),
          title: AppLocalizations.of(context)!.fuels_close + '5',
          text: AppLocalizations.of(context)!.fuels_close_5_question,
          description: AppLocalizations.of(context)!.fuels_close_5_description,
          images: {},
          otherOption: false,
          answerFormat: SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: AppLocalizations.of(context)!.yes, value: 'yes'),
              TextChoice(text: AppLocalizations.of(context)!.no, value: 'no'),
              TextChoice(
                  text: AppLocalizations.of(context)!.notApplicable,
                  value: 'notApplicable'),
            ],
          ),
        ),
        CompletionStep(
          stepIdentifier: StepIdentifier(id: '321'),
          text: AppLocalizations.of(context)!.checkVuln,
          title: AppLocalizations.of(context)!.done,
          buttonText: AppLocalizations.of(context)!.check,
        ),
      ],
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: StepIdentifier(id: 'h'),
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (String? input) {
          print('------------------------------');
          print(widget.characteristicsResults['glazing-1']);
          if (widget.characteristicsResults['glazing-1'] == 'singlePane') {
            print('fuels1a');
            return StepIdentifier(id: 'fuels-close-1a');
          } else {
            print('fuels1b');
            return StepIdentifier(id: 'fuels-close-1b');
          }
        },
      ),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: StepIdentifier(id: 'fuels-close-2a'),
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (String? input) {
          print('....');
          if (widget.characteristicsResults['material-1'] == 'timber' ||
              widget.characteristicsResults['material-1'] == 'vinylSiding') {
            return StepIdentifier(id: 'fuels-close-3');
          } else {
            return StepIdentifier(id: 'fuels-close-4');
          }
        },
      ),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: StepIdentifier(id: 'fuels-close-1b'),
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (String? input) {
          if (widget.characteristicsResults['material-1'] == 'timber' ||
              widget.characteristicsResults['material-1'] == 'vinylSiding') {
            return StepIdentifier(id: 'fuels-close-3');
          } else {
            return StepIdentifier(id: 'fuels-close-4');
          }
        },
      ),
    );
    return Future<Task>.value(task);
  }
}*/
