import 'package:hive/hive.dart';

part 'basic_result.g.dart';

@HiveType(typeId: 3)
class BasicResult {
  // @HiveField(0)
  String id = '';
  @HiveField(0)
  DateTime iniDate;
  @HiveField(1)
  Map<String, String?> answers;

  @HiveField(2)
  bool completed = false;

  @HiveField(3)
  late DateTime fiDate = DateTime.now();
  @HiveField(4)
  late int risk = -1;
  @HiveField(5)
  late String riskLevel = 'Unknown';

  BasicResult(this.iniDate, this.answers);

  void setId(String id) {
    this.id = id;
  }
}
