import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bacterial_growth.dart';

class BacterialGrowthViewModel extends ChangeNotifier {
  final List<BacterialGrowth> _dataPoints = [];
  double _currentTime = 0;
  String _currentState = 'Healthy';
  Timer? _timer;

  List<BacterialGrowth> get dataPoints => _dataPoints;
  String get currentState => _currentState;

  BacterialGrowthViewModel() {
    _startGraph();
  }

  void _startGraph() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final randomGrowth = Random().nextDouble() * 50;
      _currentTime += 1;
      _currentState = _getWoundState(randomGrowth);
      _dataPoints.add(BacterialGrowth(time: _currentTime, growthRate: randomGrowth, woundState: _currentState));

      if (_dataPoints.length > 30) {
        _dataPoints.removeAt(0);
      }
      
      notifyListeners(); // Notify UI to update
    });
  }

  String _getWoundState(double growth) {
    if (growth < 10) return 'Healthy';
    if (growth < 20) return 'Observation';
    if (growth < 30) return 'Early Infection';
    if (growth < 40) return 'Severe Infection';
    return 'Critical';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
