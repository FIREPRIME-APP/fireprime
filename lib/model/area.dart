import 'dart:convert';

import 'package:fireprime/model/questionnaire/risk_rank.dart';
import 'package:flutter/services.dart';

class Area {
  final String name;
  final List<RiskRank> riskLevels;

  Area({required this.name, required this.riskLevels});

  factory Area.fromJson(Map<String, dynamic> json) {
    List<RiskRank> resultRanks = [];
    if (json['resultRanks'] != null) {
      json['resultRanks'].forEach((rank) {
        resultRanks.add(RiskRank.fromJson(rank));
      });
    }
    print('Result Ranks: $resultRanks');
    return Area(name: json['area'], riskLevels: resultRanks);
  }

  static loadSettings(String area) async {
    String jsonString;
    try {
      jsonString = await rootBundle.loadString(
        'assets/basic_questionnaires/$area/area_settings.json',
      );
    } catch (e) {
      jsonString = await rootBundle
          .loadString('assets/basic_questionnaires/default/area_settings.json');
    }
    return jsonDecode(jsonString);
  }
}
