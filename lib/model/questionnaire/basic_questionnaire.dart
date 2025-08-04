import 'dart:convert';

import 'package:fireprime/model/area.dart';
import 'package:fireprime/model/customised_image.dart';
import 'package:flutter/services.dart';

class BasicQuestionnaire {
  final Area area;
  final List<Map<String, dynamic>> questions;
  //final List<RiskRank> resultRanks;
  final Map<String, List<CustomisedImage>> images;

  BasicQuestionnaire(
      this.area, this.questions, /*this.resultRanks,*/ this.images);

  factory BasicQuestionnaire.fromJson(
      Map<String, dynamic> questionnaireJson, Area area) {
    List<Map<String, String>> questions = [];
    Map<String, List<CustomisedImage>> images = {};

    if (questionnaireJson['questions'] != null) {
      questionnaireJson['questions'].forEach(
        (q) {
          for (var image in q['images'] ?? []) {
            if (image['path'] == null || image['description'] == null) {
              continue;
            }
            images[q['id']] ??= [];
            images[q['id']]?.add(CustomisedImage(
                'assets/images/${area.name}/basic/${image['path']}.png',
                image['description']));
          }
          print('images: $images');
          questions.add(
            {
              'id': q['id'],
              'question': q['question'],
              'description': q['description'] ?? '',
              'title': q['title'] ?? '',
            },
          );
        },
      );
    }

    print('loadedImages: $images');
    return BasicQuestionnaire(
      area,
      questions,
      images,
    );
  }

  int getResult(Map<String, String?> answers) {
    int score = 0;
    answers.forEach((questionId, answer) {
      if (answer == 'yes') {
        score++;
      }
    });
    return score;
  }

  String getRiskLevel(int score) {
    for (var rank in area.riskLevels) {
      if (score >= rank.min && score <= rank.max) {
        return rank.level;
      }
    }
    return 'Unknown';
  }

  static loadQuestionnaire(String area, String languageCode) async {
    String jsonString;
    print(area);
    try {
      jsonString = await rootBundle
          .loadString('assets/basic_questionnaires/$area/$languageCode.json');
    } catch (e) {
      jsonString = await rootBundle
          .loadString('assets/basic_questionnaires/default/$languageCode.json');
    }
    return jsonDecode(jsonString);
  }
}
