import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/model/customised_image.dart';
import 'package:fireprime/pages/questionnaire/customised_question_types/multiple_choice_image.dart';
import 'package:fireprime/pages/questionnaire/customised_question_types/single_choice_image.dart';
import 'package:fireprime/pages/questionnaire/customised_question_types/special_multiple_choice.dart';
import 'package:fireprime/providers/images_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_kit/survey_kit.dart';

class Questionnaire {
  static final Questionnaire _instance = Questionnaire._internal();

  Questionnaire._internal();

  factory Questionnaire() {
    return _instance;
  }
  String version = '1.0';
  String environment = 'default';

  List<Map<String, dynamic>> questions = [
    {
      'stepId': 'I1',
      'type': 'instructionStep',
      'title': 'buildingTitle',
      'text': 'buildingText',
    },
    {
      'stepId': 'Q1',
      'textChoices': ['100comb', 'more50comb', 'less50comb', '0comb'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q2',
      'textChoices': [
        'height0',
        'height0to20',
        'height21to40',
        'height41to60',
        'height61to80',
        'height81to100',
        'heightMore100'
      ],
      'otherOption': false,
      'type': 'singleChoice',
    },
    /*{
      'stepId': 'material-1',
      'textChoices': ['timber', 'vinylSiding', 'concreteBricks'],
      'otherOption': true,
    },*/
    {
      'stepId': 'Q3',
      'textChoices': ['roofFireRated', 'roofNonFireRated'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q4-1',
      'textChoices': ['roofPoorlyMaintaned-1', 'roofWellMaintained-1'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q4-2',
      'textChoices': ['roofPoorlyMaintaned-2', 'roofWellMaintained-2'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q5',
      'textChoices': ['singlePane', 'doublePane', 'tempered'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q6',
      'textChoices': [
        'noShutters',
        'pvcShutters',
        'woodShutters',
        'aluminiumShutters',
        'fireRatedShutters'
      ],
      'otherOption': false,
      'type': 'singleChoice',
    },
    /* {
      'stepId': 'Q7',
      'textChoices': ['noVentProtection', 'allProtected', 'noVents'],
      'otherOption': false
    },*/
    {
      'stepId': 'Q7',
      'textChoices': [
        'noVents',
        'noVentProtection',
        'ventCombProtection',
        'nonCombBadCond',
        'nonCombGoodCond'
      ],
      'otherOption': false,
      'type': 'singleChoice',
    },
    /* {
      'stepId': 'vents-2',
      'textChoices': [
        'combustibleProtection',
        'nonCombBadCond',
        'nonCombGoodCond'
      ],
      'otherOption': false
    },*/
    {
      'stepId': 'Q8',
      'textChoices': ['yesSemiConf', 'noSemiConf'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q9',
      'textChoices': [
        'glazingSystemsSinglePane',
        'glazingSystemsMultiplePane',
        'glazingSystemsTempered',
        'noGlazingSystems'
      ],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q10',
      'textChoices': ['combustibleEnvelope', 'nonCombThin', 'nonCombThick'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'I2',
      'type': 'instructionStep',
      'title': 'buildSurrondingsTitle',
      'text': 'buildSurrondings',
    },
    {
      'stepId': 'Q11',
      'type': 'specialMultipleChoice',
      'textChoices': ['5closeToGlazing', 'closeToRoof', 'none'],
      'allTextChoices': [
        '5closeToGlazing',
        '5farFromGlazing',
        'closeToRoof',
        'farFromRoof'
      ],
      'initialSelection': ['5farFromGlazing', 'farFromRoof'],
      'rules': {
        '5closeToGlazing': '5farFromGlazing',
        'closeToRoof': 'farFromRoof',
      },
      'specialSelection': 'none',
    },
    /*  {
      'stepId': 'Q11-2',
      'textChoices': ['5closeToGlazing', '5farFromGlazing'],
      'otherOption': false,
      'type': 'singleChoice',
    },*/
    /* {
      'stepId': 'Q12',
      'textChoices': ['closeToRoof', 'farFromRoof', 'noCombElem'],
      'otherOption': false,
      'type': 'singleChoice',
    },*/
    {
      'stepId': 'Q12',
      'textChoices': ['fuelsNotAgainstFacade', 'fuelsAgainstFacade'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q13',
      'textChoices': ['contSurf', 'discontSurf'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q14',
      'textChoices': ['closeToLPG', 'farFromLPG', 'noLPG'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q15',
      'textChoices': ['spacingLess5', 'placedIn20', 'none'],
      'allTextChoices': [
        'spacingLess5',
        'spacingMore5',
        'placedIn20',
        'placedFurther20',
      ],
      'initialSelection': ['spacingMore5', 'placedFurther20'],
      'rules': {
        'spacingLess5': 'spacingMore5',
        'placedIn20': 'placedFurther20',
      },
      'type': 'specialMultipleChoice',
      'specialSelection': 'none',
    },
    /* {
      'stepId': 'Q17',
      'textChoices': ['placedIn20', 'placedFurther20', 'noPlacement'],
      'otherOption': false,
      'type': 'singleChoice',
    }, */
    {
      'stepId': 'Q16',
      'textChoices': ['vegIn30', 'noVegIn30'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q17',
      'textChoices': ['highFlam', 'mediumFlam', 'lowFlam', 'noVeg'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q18',
      'textChoices': ['discontVeg', 'contVeg', 'noApplicableDiscVeg'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q19',
      'textChoices': ['pruning', 'noPruning', 'noApplicablePruning'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q20',
      'textChoices': ['lowSurfaceLess10', 'lowSurfaceMore10'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q21',
      'textChoices': ['deadVeg', 'noDeadVeg'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q22',
      'textChoices': [
        'woodenFence',
        'hedgerowHigh',
        'hedgerowLow',
        'metalPosts',
        'chainLink',
        'concreteMore2',
        'concreteLess2',
        'noDelimitation'
      ],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q23',
      'textChoices': ['flatTerrain', 'midSlope', 'upperSlope'],
      'otherOption': false,
      'type': 'singleChoice',
    }
  ];

  List<Map<String, dynamic>> navigations = [
    {
      'stepId': 'Q1',
      'type': 'saveResult',
      'conditions': {
        '100comb': 'Q2',
        'more50comb': 'Q2',
        'less50comb': 'Q2',
        '0comb': 'Q3',
      },
    },
    {
      'stepId': 'Q3',
      'type': 'conditional',
      'conditions': {
        'roofFireRated': 'Q4-2',
        'roofNonFireRated': 'Q4-1',
      },
    },
    {
      'stepId': 'Q4-1',
      'type': 'conditional',
      'conditions': {
        'roofPoorlyMaintaned-1': 'Q5',
        'roofWellMaintained-1': 'Q5',
      },
    },
    /*{
      'stepId': 'material-1',
      'type': 'saveResult',
      'nextStep': 'roof-1',
    },*/
    /*{
      'stepId': 'Q5',
      'type': 'saveResult',
      'nextStep': 'Q6',
    },*/
    /*{
      'stepId': 'vents-1',
      'type': 'conditional',
      'conditions': {
        'noVentProtection': 'semiConf-1',
        'noVents': 'semiConf-1',
        'allProtected': 'vents-2',
      },
    },*/
    /*{
      'stepId': 'Q8',
      'type': 'conditionalSavedResult',
      'conditions': {
        'yesSemiConf': 'Q9',
      },
      'savedResult': {
        'id': 'Q5',
        'conditions': {
          'singlePane': 'Q11-1',
          'doublePane': 'Q11-2',
          'tempered': 'Q11-2',
        },
      }
    }*/
    {
      'stepId': 'Q8',
      'type': 'conditional',
      'conditions': {
        'yesSemiConf': 'Q9',
        'noSemiConf': 'I2',
      },
    },
    /* {
      'stepId': 'I1',
      'type': 'conditionalSavedResult',
      'conditions': {},
      'savedResult': {
        'id': 'Q5',
        'conditions': {
          'singlePane': 'Q11-1', 
          'doublePane': 'Q11-1',
          'tempered': 'Q11-1',
        },
      }
    },*/
    /* {
      'stepId': 'semiConf-1',
      'type': 'conditionalSavedResult',
      'conditions': {
        'yesSemiConf': 'semiConf-2',
      },
      'savedResult': {
        'id': 'glazing-1',
        'conditions': {
          'singlePane': 'fuels-1a',
          'doublePane': 'fuels-1b',
          'tempered': 'fuels-1b',
        },
      }
    },*/
    /*{
      'stepId': 'Q10',
      'type': 'conditionalSavedResult',
      'conditions': {},
      'savedResult': {
        'id': 'Q5',
        'conditions': {
          'singlePane': 'Q11-1',
          'doublePane': 'Q11-2',
          'tempered': 'Q11-2',
        },
      }
    },*/

    /*  {
      'stepId': 'Q11-1',
      'type': 'conditional',
      'conditions': {
        "7farFromGlazing": "Q12",
        '7closeToGlazing': 'Q12',
      },
    }, */
    {
      'stepId': 'Q11',
      'type': 'conditionalSavedResult',
      'conditions': {},
      'savedResult': {
        'id': 'Q1',
        'conditions': {
          '100comb': 'Q12',
          'more50comb': 'Q12',
          'less50comb': 'Q12',
          '0comb': 'Q13',
        },
      }
    },
    {
      'stepId': 'Q13',
      'type': 'saveResult',
      'nextStep': 'Q14',
    },
    {
      'stepId': 'Q19',
      'type': 'conditionalSavedResult',
      'conditions': {},
      'savedResult': {
        'id': 'Q13',
        'conditions': {
          'contSurf': 'Q20',
          'discontSurf': 'Q21',
        },
      }
    }
  ];

  Map<String, dynamic> getOptions(questionId) {
    Map<String, dynamic> options = {};

    for (var question in questions) {
      if (question['stepId'] == questionId) {
        options[questionId] = question['textChoices'];
        break;
      }
    }
    return options;
  }

  void setEnvironment(String environment) {
    this.environment = environment;
  }

  SingleChoiceImageStep buildSingleChoiceImageStep({
    required String stepId,
    required List<String> textChoices,
    required bool otherOption,
    required BuildContext context,
    required Map<String, String?> answers,
    String? description,
    String? title,
    String? text,
    List<CustomisedImage>? images,
    bool? alwaysShowDescription,
    required String buttonText,
  }) {
    return SingleChoiceImageStep(
      stepIdentifier: StepIdentifier(id: stepId),
      title: title ?? context.tr('$stepId.title'),
      text: text ?? context.tr('$stepId.question'),
      description: description ?? context.tr('$stepId.description'),
      images: images ??
          (Provider.of<ImagesProvider>(context, listen: false)
                  .containsKey(stepId)
              ? Provider.of<ImagesProvider>(context, listen: false)
                  .getImagePath(stepId, context)
              : []),
      otherOption: otherOption,
      answerFormat: SingleChoiceAnswerFormat(
        textChoices: getTextChoices(textChoices, stepId, context),
        defaultSelection: getChoice(answers, stepId, context),
      ),
      buttonText: buttonText,
      //alwaysShowDescription: alwaysShowDescription ?? false,
    );
  }

  MultipleChoiceImageStep buildMultipleChoiceImageStep(
      {required stepId,
      required textChoices,
      required otherOption,
      required BuildContext context,
      required Map<String, String?> answers,
      required String buttonText}) {
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
        textChoices: getTextChoices(textChoices, stepId, context),
        defaultSelection: getMultipleChoice(stepId, answers, context),
        maxAnswers: 3,
      ),
      buttonText: buttonText,
    );
  }

  SpecialMultipleChoiceImageStep buildSpecialMultipleChoiceImageStep(
      {required String stepId,
      required List<String> textChoices,
      required List<String> allTextChoices,
      required Map<String, String> rules,
      required List<String> initialSelection,
      required String specialSelection,
      required BuildContext context,
      required Map<String, String?> answers,
      required String buttonText}) {
    print('----buildSpecialMultipleChoiceImageStep----');
    return SpecialMultipleChoiceImageStep(
        stepIdentifier: StepIdentifier(id: stepId),
        title: context.tr('$stepId.title'),
        text: context.tr('$stepId.question'),
        description: context.tr('$stepId.description'),
        images: Provider.of<ImagesProvider>(context, listen: false)
                .containsKey(stepId)
            ? Provider.of<ImagesProvider>(context, listen: false)
                .getImagePath(stepId, context)
            : [],
        answerFormat: MultipleChoiceAnswerFormat(
            textChoices: getTextChoices(textChoices, stepId, context),
            defaultSelection: getMultipleChoice(stepId, answers, context)),
        buttonText: buttonText,
        rules: rules,
        initialSelection: getTextChoices(initialSelection, stepId, context),
        specialSelection: specialSelection,
        allTextChoices: getAllTextChoices(allTextChoices, stepId, context));
  }

  Map<String, TextChoice> getAllTextChoices(
      List<String> choices, String stepId, BuildContext context) {
    print('----getAllTextChoices----');
    Map<String, TextChoice> textChoices = {};
    for (var element in choices) {
      if (context.tr('$stepId.$element') == '$stepId.$element') {
        textChoices[element] =
            TextChoice(text: context.tr(element), value: element);
        continue;
      }
      textChoices[element] =
          TextChoice(text: context.tr('$stepId.$element'), value: element);
    }
    for (var entry in textChoices.entries) {
      print('key: ${entry.key}, value: ${entry.value.value}');
    }
    return textChoices;
  }

  List<TextChoice> getTextChoices(
      List<String> choices, String stepId, BuildContext context) {
    List<TextChoice> textChoices = [];
    for (var element in choices) {
      if (context.tr('$stepId.$element') == '$stepId.$element') {
        textChoices.add(TextChoice(text: context.tr(element), value: element));
        continue;
      }
      textChoices.add(
          TextChoice(text: context.tr('$stepId.$element'), value: element));
    }

    return textChoices;
  }

  TextChoice? getChoice(
      Map<String, String?> answers, String key, BuildContext context) {
    if (answers.containsKey(key)) {
      if (context.tr('$key.${answers[key]}') != '$key.${answers[key]}') {
        return TextChoice(
            text: context.tr('$key.${answers[key]}'), value: answers[key]!);
      } else if (context.tr('${answers[key]}') != '${answers[key]}') {
        return TextChoice(
            text: context.tr('${answers[key]}'), value: answers[key]!);
      } else {
        return null;
      }
    }
    return null;
  }

  List<TextChoice> getMultipleChoice(
      String key, Map<String, String?> answers, BuildContext context) {
    List<TextChoice> choices = [];
    if (answers.containsKey(key)) {
      for (var element in answers[key]!.split(',')) {
        choices
            .add(TextChoice(text: context.tr('$key.$element'), value: element));
      }
    }
    return choices;
  }

  Map<String, String?> adaptedResult(
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
}
