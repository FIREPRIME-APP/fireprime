import 'dart:convert';

import 'package:flutter/services.dart';

class Mitigation {
  static Future<Map<String, dynamic>>? loadMitigations(
      String languageCode) async {
    try {
      String filePath = 'assets/mitigations_text/$languageCode.json';
      String data = await rootBundle.loadString(filePath);
      return json.decode(data);
    } catch (e) {
      String filePath = 'assets/mitigations_text/en.json';
      String data = await rootBundle.loadString(filePath);
      return json.decode(data);
    }
  }

  static Map<String, List<Map<String, String>>> getMitigationsTextsByAnswer(
      Map<String, dynamic> mitigations, Map<String, String?> answers) {
    Map<String, List<Map<String, String>>> mitigationTexts = {};

    for (var mitigation in mitigations.entries) {
      for (var answer in answers.entries) {
        if (answer.value != null &&
            answer.value!.split(',').contains(mitigation.key)) {
          if (mitigationTexts[mitigation.value['title']] == null) {
            mitigationTexts[mitigation.value['title']] = [
              {
                'text': mitigation.value['text'],
                'questionId': mitigation.value['questionId'] ?? '',
                'url': mitigation.value['url'] ?? '',
                'url_text': mitigation.value['url_text'] ?? ''
              }
            ];
          } else {
            mitigationTexts[mitigation.value['title']]!.add({
              'text': mitigation.value['text'],
              'questionId': mitigation.value['questionId'] ?? '',
              'url': mitigation.value['url'] ?? '',
              'url_text': mitigation.value['url_text'] ?? ''
            });
          }
        }
      }
    }
    return mitigationTexts;
  }

  static loadNavigation() {}
}
