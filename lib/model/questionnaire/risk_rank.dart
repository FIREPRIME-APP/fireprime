class RiskRank {
  final String level;
  final int min;
  final int max;

  RiskRank({
    required this.level,
    required this.min,
    required this.max,
  });

  factory RiskRank.fromJson(Map<String, dynamic> json) {
    return RiskRank(
      level: json['level'] ?? '',
      min: json['min'] as int? ?? 0,
      max: json['max'] as int? ?? 0,
    );
  }
}
