import 'dart:ui';

class CalibrationLevel {
  final double cfu;
  final Color color;
  final String healthState;

  CalibrationLevel({
    required this.cfu,
    required this.color,
    required this.healthState,
  });

  Map<String, dynamic> toMap() => {
        'cfu': cfu,
        'color': color.value,
        'healthState': healthState,
      };

  factory CalibrationLevel.fromMap(Map<String, dynamic> data) {
  final rawColor = data['color'];
  return CalibrationLevel(
    cfu: (data['cfu'] as num).toDouble(),
    color: rawColor is int ? Color(rawColor) : const Color(0xFFCCCCCC),
    healthState: data['healthState'] ?? 'Unknown',
  );
}

}
