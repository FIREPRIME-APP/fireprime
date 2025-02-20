import 'package:fireprime/model/event_probability.dart';
import 'package:hive/hive.dart';

part 'risk_assessment.g.dart';

@HiveType(typeId: 1)
class RiskAssessment {
  // @HiveField(0)
  String id = '';
  @HiveField(0)
  DateTime iniDate;
  @HiveField(1)
  String version; //innecessario TODO
  @HiveField(2)
  Map<String, String?> answers;

  @HiveField(3)
  bool completed = false;

  @HiveField(4)
  late DateTime fiDate = DateTime.now();
  @HiveField(5)
  late double risk = -1;
  @HiveField(6)
  late Map<String, double> results = {}; //innecesario TODO
  @HiveField(7)
  late Map<String, Map<String, double>> subNodeProbabilities =
      {}; //innecesario TODO
  @HiveField(8)
  late Map<String, EventProbability>? allProbabilities = {};
  @HiveField(9)
  late double? vulnerability = -1.0;
  @HiveField(10)
  late double? hazard = 1.0;

  RiskAssessment(this.iniDate, this.version, this.answers);

  void setId(String id) {
    this.id = id;
  }
}
