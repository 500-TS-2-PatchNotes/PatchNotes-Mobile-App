import 'dart:math';

import 'package:patchnotes/models/calibration_level.dart';

String getStatusMessage(String state) {
  switch (state) {
    case 'Healthy':
      return 'Status: Your wound is healing well. Keep it up!';
    case 'Monitor Needed':
      return 'Status: Monitor your wound. Follow care instructions.';
    case 'Unhealthy':
      return 'Status: Wound condition is serious. Seek medical attention.';
    default:
      return 'Status: Unknown wound status.';
  }
}

String getTip(String state) {
  switch (state) {
    case 'Healthy':
      return 'Tip: Keep the wound clean and covered to prevent infection.';
    case 'Monitor Needed':
      return 'Tip: Change bandages regularly and monitor for any changes.';
    case 'Unhealthy':
      return 'Tip: Contact your healthcare provider for professional treatment.';
    default:
      return 'Tip: No specific advice available.';
  }
}

String getWoundStateFromCFU(List<CalibrationLevel> levels, double cfu) {
  if (levels.isEmpty) return 'Unknown';
  for (int i = 0; i < levels.length; i++) {
    if (cfu <= levels[i].cfu) return levels[i].healthState;
  }
  return levels.last.healthState;
}

double estimateCFUFromLevel(List<dynamic> calibration, double level) {
    return pow(10, level).toDouble();
  }
