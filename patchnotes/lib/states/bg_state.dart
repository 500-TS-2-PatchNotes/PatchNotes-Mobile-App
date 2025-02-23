import 'package:patchnotes/models/bacterial_growth.dart';

class BacterialGrowthState {
  final List<BacterialGrowth> dataPoints;
  final String currentState;
  final String woundStateColor;
  final double cfu;
  final bool isLoading;
  final String? errorMessage;

  BacterialGrowthState({
    this.dataPoints = const [],
    this.currentState = "Healthy",
    this.woundStateColor = "Green",
    this.cfu = 0.0,
    this.isLoading = false,
    this.errorMessage,
  });

  BacterialGrowthState copyWith({
    List<BacterialGrowth>? dataPoints,
    String? currentState,
    String? woundStateColor,
    double? cfu,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BacterialGrowthState(
      dataPoints: dataPoints ?? this.dataPoints,
      currentState: currentState ?? this.currentState,
      woundStateColor: woundStateColor ?? this.woundStateColor,
      cfu: cfu ?? this.cfu,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
