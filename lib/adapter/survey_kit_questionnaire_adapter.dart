import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:fireprime/adapter/IQuestionnaire.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyKitQuestionnaireAdapter implements IQuestionnaireadapter {
  @override
  Future<SurveyKit> loadQuestionnaire(
      String? languageCode, BuildContext context) async {
    try {
      final String taskJson =
          await rootBundle.loadString('assets/general_questionnaire.json');
      final Map<String, dynamic> questionnaire = json.decode(taskJson);

      if (!context.mounted) {
        throw Exception('Widget not mounted');
      }

      var adaptedJSON = adaptJson(questionnaire, context);
      var task = Task.fromJson(adaptedJSON);

      return SurveyKit(
        onResult: (SurveyResult result) {
          final jsonResult = result.toJson();
          debugPrint(jsonEncode(jsonResult));
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
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  adaptJson(Map<String, dynamic> questionnaire, BuildContext context) {
    List<String> questionGroups = ["questionsGroup1", "questionsGroup2"];
    List<String> answerGroups = ["answersGroup1", "answersGroup2"];

    Map<String, dynamic> adaptedJSON = {
      "id": questionnaire["id"],
      "type": questionnaire["type"],
      "rules": questionnaire["rules"],
      "steps": [],
    };
    for (var step in questionnaire["steps"]["start"]) {
      adaptedJSON["steps"].add({
        "stepIdentifier": {"id": step["stepIdentifier"]["id"]},
        "type": step["type"],
        "title": AppLocalizations.of(context)!.start(step["title"]),
        "text": AppLocalizations.of(context)!.start(step["text"]),
      });
    }
    for (var i = 1; i < questionnaire["steps"].length; i++) {
      var stepGroup = questionnaire["steps"].values.toList()[i];

      for (var step in stepGroup) {
        adaptedJSON["steps"].add({
          "stepIdentifier": {"id": step["stepIdentifier"]["id"]},
          "type": step["type"],
          "title": getQuestionsTranslation(
              context, questionGroups[i - 1], step["title"]),
          "answerFormat": //step["answerFormat"]
              adaptAnswerFormat(
                  step["answerFormat"], context, answerGroups[i - 1])
        });
      }
    }

    print("adaptedJSON: $adaptedJSON");
    return adaptedJSON;
  }

  dynamic adaptAnswerFormat(
      dynamic answerFormat, BuildContext context, String group) {
    switch (answerFormat["type"]) {
      case "single":
        answerFormat["textChoices"] =
            adaptTextChoices(answerFormat["textChoices"], context, group);
        print("I'm in single");
        print("answerFormat: $answerFormat");
      case "text":
        print("I'm in text");
        print("answerFormat: $answerFormat");
    }
    return answerFormat;
  }

  List<Map<String, dynamic>> adaptTextChoices(
      List<dynamic> textChoices, BuildContext context, String group) {
    return textChoices.map((choice) {
      print("I'm in choice " + choice["text"]);
      return {
        "text": getAnswersTranslation(context, group, choice["text"]),
        "value": choice["value"],
      };
    }).toList();
  }

  getQuestionsTranslation(BuildContext context, String group, String text) {
    switch (group) {
      case "questionsGroup1":
        return AppLocalizations.of(context)!.questionsGroup1(text);
      case "questionsGroup2":
        return AppLocalizations.of(context)!.questionsGroup2(text);
    }
  }

  getAnswersTranslation(BuildContext context, String group, String text) {
    switch (group) {
      case "answersGroup1":
        return AppLocalizations.of(context)!.answersGroup1(text);
      case "answersGroup2":
        return AppLocalizations.of(context)!.answersGroup2(text);
    }
  }
}
