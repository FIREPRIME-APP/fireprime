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
    print(box.toMap());
    houses = box.toMap();
    return houses;
  }

  void delete(String houseName) async {
    houses.remove(houseName);
    await box.delete(houseName);
    notifyListeners();
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
    print('getHouse housename:' + houseName);
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

    print(house.name);
    if (finishReason == 'Completed') {
      if (house.riskAssessments.isEmpty ||
          house.riskAssessments.last.completed) {
        print('isEmpty or Lastcompleted');
        house.riskAssessments.add(RiskAssessment(iniDate, version, answers));
      } else {
        print('not isNotEmpty or not Lastcompleted');
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

  Future<void> editHouse(String name, String address) async {
    print(currentHouse.toString());

    houses[currentHouse].address = address;

    if (houses[currentHouse].name != name) {
      House editedHouse = houses[currentHouse];
      editedHouse.name = name;
      houses.remove(currentHouse);
      await box.delete(currentHouse);
      houses[name] = editedHouse;
      currentHouse = name;
    }

    await box.put(currentHouse, houses[currentHouse]);

    notifyListeners();
  }

  Future<void> deleteHouse() async {
    print('delete, currentHouse: $currentHouse');
    houses.remove(currentHouse);
    await box.delete(currentHouse);

    print('houses: $houses');
    currentHouse = null;
    notifyListeners();
  }

  Map<String, double> getResults() {
    return houses[currentHouse]!.riskAssessments.last.results;
  }

  double getProbability() {
    return houses[currentHouse]!.riskAssessments.last.probability;
  }

  List<RiskAssessment> getRiskAssessments() {
    return houses[currentHouse]!.riskAssessments;
  }

  void modifyHouse() {
    currentHouse = 'House1';
    notifyListeners();
  }

  bool existsHouse(String text) {
    return houses.containsKey(text);
  }
}
