import 'package:fireprime/hazard/hazard.dart';
import 'package:fireprime/model/basic_result.dart';
import 'package:fireprime/model/event_probability.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/model/risk_assessment.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HouseProvider with ChangeNotifier {
  Map<dynamic, dynamic> houses = {};

  String? currentHouse;

  String? buttonVisibleHouse;

  late Box box;
  late Box riskAssessmentBox;
  late Box basicResultBox;

  HouseProvider() {
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
    riskAssessmentBox = await Hive.openBox('riskAssessmentBox');
    basicResultBox = await Hive.openBox('basicResultBox');
    return box.isOpen;
  }

  @override
  void dispose() {
    box.close();
    riskAssessmentBox.close();
    basicResultBox.close();
    super.dispose();
  }

  Map<dynamic, dynamic> getHouses() {
    houses = box.toMap();
    return houses;
  }

  Map<dynamic, dynamic> getRiskAssessmentsBox() {
    return riskAssessmentBox.toMap();
  }

  Future<void> deleteRiskAssessment(String id) async {
    await riskAssessmentBox.delete(id);
    notifyListeners();
  }

  Map<dynamic, dynamic> getBasicResultsBox() {
    return basicResultBox.toMap();
  }

  Future<void> deleteBasicResult(String id) async {
    await basicResultBox.delete(id);
    notifyListeners();
  }

  Future<void> delete(String houseName) async {
    houses.remove(houseName);
    await box.delete(houseName);
    notifyListeners();
  }

  Future<void> updateHouse() async {
    print('updating house');
    await box.put(currentHouse, houses[currentHouse]);
    notifyListeners();
  }

  Future<void> updateRiskAssesment(
      String id, RiskAssessment riskAssessment) async {
    await riskAssessmentBox.put(id, riskAssessment);
    notifyListeners();
  }

  Future<void> updateBasicResult(String id, BasicResult basicResult) async {
    await basicResultBox.put(id, basicResult);
    notifyListeners();
  }

  House getHouse(String houseName) {
    return houses[houseName]!;
  }

  /* void buttonVisible(String houseName) {
    if (buttonVisibleHouse == houseName) {
      buttonVisibleHouse = null;
    } else {
      buttonVisibleHouse = houseName;
    }
    notifyListeners();
  }
*/

  Future<int> getNextId(String boxName) async {
    final idBox = await Hive.openBox<int>(boxName);
    int currentId = idBox.get('lastId') ?? 0;
    int newId = currentId + 1;
    await idBox.put('lastId', newId);
    return newId;
  }

  /*Future getNextRiskAssessmentId() async {
    final idBox = await Hive.openBox<int>('riskAssessmentIds');
    int currentId = idBox.get('lastId') ?? 0;
    int newId = currentId + 1;
    await idBox.put('lastId', newId);
    return newId;
  }

  Future getNextBasicResultId() async {
    final idBox = await Hive.openBox<int>('basicResultIds');
    int currentId = idBox.get('lastId') ?? 0;
    int newId = currentId + 1;
    await idBox.put('lastId', newId);
    return newId;
  }*/

  Future<String> addRiskAssessment(RiskAssessment riskAssessment) async {
    int newId = await getNextId('riskAssessmentIds');
    riskAssessment.setId('riskAssessment_$newId');
    riskAssessmentBox.put('riskAssessment_$newId', riskAssessment);
    notifyListeners();

    return 'riskAssessment_$newId';
  }

  void addHouse(House house) async {
    int newId = await getNextId('ids');
    houses['house_$newId'] = house;
    await box.put('house_$newId', house);
    notifyListeners();
  }

  Future<String> addBasicResult(BasicResult basicResult) async {
    int newId = await getNextId('basicResultIds');
    basicResult.setId('basicResult_$newId');
    basicResultBox.put('basicResult_$newId', basicResult);
    notifyListeners();

    return 'basicResult_$newId';
  }

  void setCurrentHouse(String houseId) {
    currentHouse = houseId;
    notifyListeners();
  }

  bool existsHouse(String name) {
    for (var house in houses.entries) {
      if (house.value.name == name) {
        return true;
      }
    }
    return false;
  }

  Future<void> editHouse(String name, String address, String zipCode) async {
    houses[currentHouse].address = address;
    houses[currentHouse].name = name;
    houses[currentHouse].zipCode = zipCode;

    /*if (houses[currentHouse].name != name) {
      House editedHouse = houses[currentHouse];
      editedHouse.name = name;
      houses.remove(currentHouse);
      await box.delete(currentHouse);
      houses[name] = editedHouse;
      currentHouse = name;
    }*/

    await box.put(currentHouse, houses[currentHouse]);

    notifyListeners();
  }

  Future<void> deleteHouse() async {
    House house = houses[currentHouse]!;

    for (var ra in house.riskAssessmentIds) {
      await riskAssessmentBox.delete(ra);
    }

    houses.remove(currentHouse);
    await box.delete(currentHouse);

    currentHouse = null;
    notifyListeners();
  }

  Future<void> getHazardValue() async {
    House house = houses[currentHouse]!;
    double hazard = -1.0;
    if (house.lat != null && house.long != null) {
      hazard = await getHazard(house.lat!, house.long!);
    }
    if (hazard != -1.0) {
      house.hazard = hazard;
    }
    await box.put(currentHouse, house);
    notifyListeners();
  }

  Future<void> setAnswers(
      DateTime iniDate,
      String version,
      Map<String, String?> answers,
      String finishReason,
      String? lastStepId) async {
    House house = houses[currentHouse];
    RiskAssessment? riskAssessment = getLastRiskAssessment();
    if (finishReason == 'Completed') {
      if (riskAssessment == null || (riskAssessment.completed)) {
        print('isEmpty or Lastcompleted');
        RiskAssessment newRiskAssessment =
            RiskAssessment(iniDate, version, answers, null);
        String raId = await addRiskAssessment(newRiskAssessment);
        //newRiskAssessment.setId(raId);
        house.riskAssessmentIds.add(raId);
      } else {
        riskAssessment.answers = answers;
        riskAssessment.lastStepId = null;
        await updateRiskAssesment(riskAssessment.id, riskAssessment);
      }
    } else {
      if (riskAssessment != null) {
        print('lastStep in SetAnswers: $lastStepId');

        if (riskAssessment.completed) {
          RiskAssessment newRiskAssessment =
              RiskAssessment(iniDate, version, answers, lastStepId);
          String raId = await addRiskAssessment(newRiskAssessment);
          //newRiskAssessment.setId(raId);
          house.riskAssessmentIds.add(raId);
        } else {
          riskAssessment.answers = answers;
          riskAssessment.lastStepId = lastStepId;
          await updateRiskAssesment(riskAssessment.id, riskAssessment);
        }
      } else {
        RiskAssessment newRiskAssessment =
            RiskAssessment(iniDate, version, answers, lastStepId);
        String raId = await addRiskAssessment(newRiskAssessment);
        // newRiskAssessment.setId(raId);
        house.riskAssessmentIds.add(raId);
      }

      /*if (houses[currentHouse]!.riskAssessments.isNotEmpty) {
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
      }*/
    }

    notifyListeners();
  }

  /*void setCompleted(
      bool completed,
      double probability,
      Map<String, double> subProb,
      Map<String, Map<String, double>> subNodeProbabilities,
      DateTime endDate) {
    houses[currentHouse]!.riskAssessments.last.completed = completed;
    houses[currentHouse]!.riskAssessments.last.probability = probability;
    houses[currentHouse]!.riskAssessments.last.results = subProb;
    houses[currentHouse]!.riskAssessments.last.subNodeProbabilities =
        subNodeProbabilities;
    houses[currentHouse]!.riskAssessments.last.fiDate = endDate;

    notifyListeners();
  }*/

  Future<double> setCompleted(
    bool completed,
    double vulnerability,
    Map<String, EventProbability> allProbabilities,
    DateTime endDate,
  ) async {
    House house = houses[currentHouse]!;
    String raId = house.riskAssessmentIds.last;
    RiskAssessment riskAssessment = riskAssessmentBox.get(raId);
    riskAssessment.completed = completed;
    riskAssessment.vulnerability = vulnerability;
    riskAssessment.allProbabilities = allProbabilities;
    riskAssessment.fiDate = endDate;
    print('before Hazard');
    await getHazardValue();
    print('after hazard');
    riskAssessment.hazard = house.hazard;
    riskAssessment.risk = house.hazard! * vulnerability;
    await updateRiskAssesment(raId, riskAssessment);
    await updateHouse();
    notifyListeners();
    return riskAssessment.risk;
  }

  /*Map<String, double> getResults() {
    return houses[currentHouse]!.riskAssessments.last.results;
  }*/
/*
  double getProbability() {
    return houses[currentHouse]!.riskAssessments.last.probability;
  }*/

  List<RiskAssessment> getRiskAssessments() {
    List<RiskAssessment> riskAssessments = [];
    for (int i = 0; i < houses[currentHouse]!.riskAssessmentIds.length; i++) {
      var riskAssessmentId = houses[currentHouse]!.riskAssessmentIds[i];

      RiskAssessment riskAssessment = riskAssessmentBox.get(riskAssessmentId);
      if (riskAssessment.completed) {
        riskAssessments.add(riskAssessment);
      }
      /*riskAssessments.add(
          riskAssessmentBox.get(houses[currentHouse]!.riskAssessmentIds[i]));*/
    }
    return riskAssessments;
  }

  RiskAssessment? getLastRiskAssessment() {
    House house = houses[currentHouse]!;
    //print('getLastIds:' + house.riskAssessmentIds.last);
    if (house.riskAssessmentIds.isEmpty) {
      return null;
    } else {
      String id = house.riskAssessmentIds.last;
      //print(riskAssessmentBox.get(id));
      return riskAssessmentBox.get(id);
    }
  }

  double? getLastProbability() {
    if (currentHouse != null) {
      RiskAssessment? riskAssessment = getLastRiskAssessment();
      House house = houses[currentHouse]!;

      if (riskAssessment == null) {
        return null;
      } else if (riskAssessment.completed) {
        return riskAssessment.risk;
      } else if (house.riskAssessmentIds.length >= 2) {
        String raId =
            house.riskAssessmentIds[house.riskAssessmentIds.length - 2];
        RiskAssessment riskAssessment2 = riskAssessmentBox.get(raId);
        if (riskAssessment2.completed) {
          return riskAssessment2.risk;
        }
      }
    }
    return null;

    /*if (house.riskAssessments.isEmpty) {
        return null;
      } else if (house.riskAssessments.last.completed) {
        return house.riskAssessments.last.probability;
      } else if (house.riskAssessments.length >= 2 &&
          house.riskAssessments[house.riskAssessments.length - 2].completed) {
        return house
            .riskAssessments[house.riskAssessments.length - 2].probability;
      }
    }
    return null;*/
  }

  Map<String, double> getLastResults() {
    if (currentHouse == null) {
      return {};
    }
    House house = houses[currentHouse]!;
    RiskAssessment? riskAssessment = getLastRiskAssessment();

    if (riskAssessment == null) {
      return {};
    } else if (riskAssessment.completed) {
      return riskAssessment.results;
    } else if (house.riskAssessmentIds.length >= 2) {
      String raId = house.riskAssessmentIds[house.riskAssessmentIds.length - 2];
      RiskAssessment riskAssessment2 = riskAssessmentBox.get(raId);
      if (riskAssessment2.completed) {
        return riskAssessment2.results;
      } else {
        return {};
      }
    } else {
      return {};
    }
/*
      if (house.riskAssessments.isEmpty) {
        return {};
      } else if (house.riskAssessments.last.completed) {
        return house.riskAssessments.last.results;
      } else if (house.riskAssessments.length >= 2 &&
          house.riskAssessments[house.riskAssessments.length - 2].completed) {
        return house.riskAssessments[house.riskAssessments.length - 2].results;
      } else {
        return {};
      }*/
  }

  RiskAssessment? getCompletedRiskAssessment() {
    House house = houses[currentHouse]!;
    RiskAssessment? riskAssessment = getLastRiskAssessment();

    if (riskAssessment == null) {
      return null;
    } else {
      if (riskAssessment.completed) {
        return riskAssessment;
      } else if (house.riskAssessmentIds.length >= 2) {
        String raId =
            house.riskAssessmentIds[house.riskAssessmentIds.length - 2];
        RiskAssessment riskAssessment2 = riskAssessmentBox.get(raId);
        if (riskAssessment2.completed) {
          return riskAssessment2;
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  RiskAssessment? getOldRiskAssessment() {
    House house = houses[currentHouse]!;
    RiskAssessment? riskAssessment = getLastRiskAssessment();
    if (riskAssessment == null) {
      return null;
    } else {
      if (riskAssessment.completed) {
        if (house.riskAssessmentIds.length > 1) {
          String raId =
              house.riskAssessmentIds[house.riskAssessmentIds.length - 2];
          return riskAssessmentBox.get(raId);
        }
      } else {
        if (house.riskAssessmentIds.length > 2) {
          String raId =
              house.riskAssessmentIds[house.riskAssessmentIds.length - 3];
          return riskAssessmentBox.get(raId);
        }
      }
    }
    return null;
  }

  List<BasicResult> getBasicResults() {
    List<BasicResult> basicResults = [];
    for (int i = 0; i < houses[currentHouse]!.basicResultIds.length; i++) {
      var brId = houses[currentHouse]!.basicResultIds[i];
      BasicResult basicResult = basicResultBox.get(brId);
      if (basicResult.completed) {
        basicResults.add(basicResult);
      }
    }
    return basicResults;
  }

  BasicResult? getLastBasicResult() {
    House house = houses[currentHouse]!;
    //print('getLastIds:' + house.riskAssessmentIds.last);
    if (house.basicResultIds != null) {
      if (house.basicResultIds!.isEmpty) {
        return null;
      } else {
        String id = house.basicResultIds!.last;
        return basicResultBox.get(id);
      }
    }
  }

  BasicResult? getOldBasicResult() {
    House house = houses[currentHouse]!;
    BasicResult? basicResult = getLastBasicResult();
    if (basicResult == null) {
      return null;
    } else {
      if (basicResult.completed) {
        if (house.basicResultIds!.length > 1) {
          String brId = house.basicResultIds![house.basicResultIds!.length - 2];
          return basicResultBox.get(brId);
        }
      } else {
        if (house.basicResultIds!.length > 2) {
          String brId = house.basicResultIds![house.basicResultIds!.length - 3];
          return basicResultBox.get(brId);
        }
      }
    }
    return null;
  }

  BasicResult? getCompletedBasicResult() {
    House house = houses[currentHouse]!;
    BasicResult? basicResult = getLastBasicResult();

    if (basicResult == null) {
      return null;
    } else {
      if (basicResult.completed) {
        return basicResult;
      } else if (house.basicResultIds != null &&
          house.basicResultIds!.length >= 2) {
        String brId = house.basicResultIds![house.basicResultIds!.length - 2];
        BasicResult basicResult2 = basicResultBox.get(brId);
        if (basicResult2.completed) {
          return basicResult2;
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  Future<int> setBasicCompleted(
    bool completed,
    int risk,
    DateTime endDate,
    String riskLevel,
  ) async {
    House house = houses[currentHouse]!;
    String brId = house.basicResultIds!.last;
    BasicResult basicResult = basicResultBox.get(brId);
    basicResult.completed = completed;
    basicResult.risk = risk;
    basicResult.riskLevel = riskLevel;
    basicResult.fiDate = endDate;
    await updateBasicResult(brId, basicResult);
    await updateHouse();
    notifyListeners();
    return basicResult.risk;
  }

  Future<void> setBasicAnswers(DateTime iniDate, Map<String, String?> answers,
      String finishReason) async {
    House house = houses[currentHouse];
    BasicResult? basicResult = getLastBasicResult();
    print('-------setAnswers');
    if (finishReason == 'Completed') {
      if (basicResult == null || (basicResult.completed)) {
        BasicResult newBasicResult = BasicResult(iniDate, answers);
        String brId = await addBasicResult(newBasicResult);
        // newBasicResult.setId(brId);
        house.basicResultIds!.add(brId);
      } else {
        basicResult.answers = answers;
        await updateBasicResult(basicResult.id, basicResult);
      }
    } else {
      if (basicResult != null) {
        print('is not null');
        if (basicResult.completed) {
          BasicResult newBasicResult = BasicResult(iniDate, answers);
          String brId = await addBasicResult(newBasicResult);
          newBasicResult.setId(brId);
          house.basicResultIds!.add(brId);
        } else {
          basicResult.answers = answers;
          await updateBasicResult(basicResult.id, basicResult);
        }
      } else {
        BasicResult newBasicResult = BasicResult(iniDate, answers);
        print('newBasicResult: $newBasicResult');
        String baId = await addBasicResult(newBasicResult);
        house.basicResultIds ??= [];
        house.basicResultIds!.add(baId);
      }
    }
    notifyListeners();
  }
}
