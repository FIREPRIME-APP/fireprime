import 'package:fireprime/model/house.dart';
import 'package:fireprime/model/risk_assessment.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HouseController with ChangeNotifier {
  Map<dynamic, dynamic> houses = {};

  String? currentHouse;

  String? buttonVisibleHouse;

  late Box box;

  HouseController() {
    _init();
  }

  Future<void> _init() async {
    await initialiseBox();
    houses = getHouses();
  }

  Future<bool> initialiseBox() async {
    final directory = await getApplicationSupportDirectory();
    Hive.init(directory.path);
    box = await Hive.openBox('housesBox');
    return box.isOpen;
  }

  @override
  void dispose() {
    box.close();
    super.dispose();
  }

  Map<dynamic, dynamic> getHouses() {
    houses = box.toMap();
    return houses;
  }

  List<dynamic> getHousesNames() {
    return houses.keys.toList();
  }

  void updateHouse() async {
    print('updating house');
    await box.put(currentHouse, houses[currentHouse]);
    notifyListeners();
  }

  House getHouse(String houseName) {
    return houses[houseName]!;
  }

  void buttonVisible(String houseName) {
    if (buttonVisibleHouse == houseName) {
      buttonVisibleHouse = null;
    } else {
      buttonVisibleHouse = houseName;
    }
    notifyListeners();
  }

  void addHouse(House house) async {
    print(box.values);
    houses[house.name] = house;
    print('there');
    await box.put(house.name, house);
    notifyListeners();
  }

  void setCurrentHouse(String houseName) {
    currentHouse = houseName;
    notifyListeners();
  }

  void setAnswers(DateTime iniDate, String version,
      Map<String, String?> answers, String finishReason) {
    House house = houses[currentHouse];
    if (finishReason == 'Completed') {
      if (house.riskAssessments.last.completed) {
        house.riskAssessments.add(RiskAssessment(iniDate, version, answers));
      } else {
        house.riskAssessments.last.answers = answers;
      }
    } else {
      if (houses[currentHouse]!.riskAssessments.isNotEmpty) {
        if (houses[currentHouse]!.riskAssessments.last.completed) {
          houses[currentHouse]!
              .riskAssessments
              .add(RiskAssessment(iniDate, version, answers));
        } else {
          houses[currentHouse]!.riskAssessments.last.answers = answers;
        }
        houses[currentHouse]!.riskAssessments.last.answers = answers;
      } else {
        houses[currentHouse]!
            .riskAssessments
            .add(RiskAssessment(iniDate, version, answers));
      }
    }

    notifyListeners();
  }

  void setCompleted(bool completed, double probability,
      Map<String, double> subProb, DateTime endDate) {
    houses[currentHouse]!.riskAssessments.last.completed = completed;
    houses[currentHouse]!.riskAssessments.last.probability = probability;
    houses[currentHouse]!.riskAssessments.last.results = subProb;
    houses[currentHouse]!.riskAssessments.last.fiDate = endDate;

    notifyListeners();
  }

  /*void setResults(double probability, Map<String, double> subProb) {
    houses[currentHouse]!.riskAssessments.last.probability = probability;
    houses[currentHouse]!.riskAssessments.last.results = subProb;
    notifyListeners();
  }

  void setEndDate(DateTime endDate) {
    houses[currentHouse]!.riskAssessments.last.fiDate = endDate;
    notifyListeners();
  }*/

  Map<String, double> getResults() {
    return houses[currentHouse]!.riskAssessments.last.results;
  }

  double getProbability() {
    return houses[currentHouse]!.riskAssessments.last.probability;
  }

  List<RiskAssessment> getRiskAssessments() {
    return houses[currentHouse]!.riskAssessments;
  }
}
