class BacterialGrowth {
  final double time;
  final double growthRate;
  final String woundState;

  BacterialGrowth({
    required this.time,
    required this.growthRate,
    required this.woundState,
  });

  BacterialGrowth copyWith({
    double? time,
    double? growthRate,
    String? woundState,
  }) {
    return BacterialGrowth(
      time: time ?? this.time,
      growthRate: growthRate ?? this.growthRate,
      woundState: woundState ?? this.woundState,
    );
  }
}
