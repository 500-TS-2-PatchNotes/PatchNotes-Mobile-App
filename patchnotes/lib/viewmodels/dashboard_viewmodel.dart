import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:patchnotes/models/collections/wound.dart';
import 'package:patchnotes/services/firestore_service.dart';
import '../models/bacterial_growth.dart';

class BacterialGrowthViewModel extends ChangeNotifier {
  final List<BacterialGrowth> _dataPoints = [];
  final FirestoreService _firestoreService = FirestoreService();

  double _currentTime = 0;
  String _currentState = 'Healthy';
  String _woundStateColor = 'Green'; 
  double _cfu = 0; 
  Timer? _timer;

  List<BacterialGrowth> get dataPoints => _dataPoints;
  String get currentState => _currentState;
  String get woundStateColor => _woundStateColor;
  double get cfu => _cfu;

  BacterialGrowthViewModel() {
    _fetchWoundData();
    _startGraph();
  }

  /// Fetch wound data from Firestore and initialize state
  Future<void> _fetchWoundData() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    Wound? woundData = await _firestoreService.getWound(userId);
    if (woundData != null) {
      _updateWoundState(woundData.cfu ?? 0); // Ensure state is updated
      notifyListeners();
    }
  }

  Future<void> fetchDashboardData(String uid) async {
  try {
    notifyListeners();

    Wound? wound = await _firestoreService.getWound(uid);
    if (wound != null) {
      _currentState = wound.woundStatus!;
      _woundStateColor = wound.colour!;
      _cfu = wound.cfu!;
    }
  } catch (e) {
    print("Error fetching dashboard data: $e");
  } finally {
    notifyListeners();
  }
}


  /// Starts generating random bacterial growth data
  void _startGraph() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final randomGrowth = Random().nextDouble() * 50;
      _currentTime += 1;

      _updateWoundState(randomGrowth); 

      _dataPoints.add(BacterialGrowth(
        time: _currentTime,
        growthRate: randomGrowth,
        woundState: _currentState, 
      ));

      if (_dataPoints.length > 30) {
        _dataPoints.removeAt(0);
      }

      notifyListeners();
    });
  }

  void _updateWoundState(double growth) {
    String newState = _getWoundState(growth);
    if (_currentState != newState || _cfu != growth) {
      _currentState = newState;
      _woundStateColor = _getWoundStateColor(newState);
      _cfu = growth;
      notifyListeners(); 
    }
  }
  

  String _getWoundState(double growth) {
    if (growth < 10) return 'Healthy';
    if (growth < 20) return 'Observation';
    if (growth < 30) return 'Early Infection';
    if (growth < 40) return 'Severe Infection';
    return 'Critical';
  }

  String _getWoundStateColor(String woundState) {
    switch (woundState) {
      case "Healthy": return "Green";
      case "Observation": return "Yellow";
      case "Early Infection": return "Orange";
      case "Severe Infection": return "Red";
      case "Critical": return "Black";
      default: return "Unknown";
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void reset() {
  _currentState = "Unknown";  
  _woundStateColor = "";  
  _cfu = 0.0;  
  notifyListeners();
}

}
