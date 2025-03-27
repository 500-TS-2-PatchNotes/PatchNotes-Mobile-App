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
    return CalibrationLevel(
      cfu: data['cfu'],
      color: Color(data['color']),
      healthState: data['healthState'],
    );
  }
}
