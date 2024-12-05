import 'package:hive/hive.dart';

part 'risk_assessment.g.dart';

@HiveType(typeId: 1)
class RiskAssessment {
  @HiveField(0)
  DateTime iniDate;
  @HiveField(1)
  String version;
  @HiveField(2)
  Map<String, String?> answers;

  @HiveField(3)
  bool completed = false;

  @HiveField(4)
  late DateTime fiDate = DateTime.now();
  @HiveField(5)
  late double probability = -1;
  @HiveField(6)
  late Map<String, double> results = {};
  @HiveField(7)
  late Map<String, Map<String, double>> subNodeProbabilities = {};

  RiskAssessment(this.iniDate, this.version, this.answers);
}
