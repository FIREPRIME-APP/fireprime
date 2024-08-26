import 'package:fireprime/model/risk_assessment.dart';
import 'package:hive/hive.dart';

part 'house.g.dart';

@HiveType(typeId: 0)
class House {
  @HiveField(0)
  String name;
  @HiveField(1)
  String address;
  @HiveField(2)
  String environment;

  @HiveField(3)
  List<RiskAssessment> riskAssessments = [];

  House(this.name, this.address, this.environment);
}
