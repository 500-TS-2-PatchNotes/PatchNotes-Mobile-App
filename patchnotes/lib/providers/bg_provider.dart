import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:patchnotes/providers/auth_provider.dart';
import 'package:patchnotes/services/firestore_service.dart';
import 'package:patchnotes/models/bacterial_growth.dart';
import 'package:patchnotes/models/collections/wound.dart';
import 'package:patchnotes/states/bg_state.dart';

// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

// Bacterial Growth Provider
final bacterialGrowthProvider = StateNotifierProvider<BacterialGrowthNotifier, BacterialGrowthState>((ref) {
  return BacterialGrowthNotifier(
    ref.read(firestoreServiceProvider),
    ref.read(firebaseAuthProvider),
  );
});

class BacterialGrowthNotifier extends StateNotifier<BacterialGrowthState> {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;
  Timer? _timer;
  double _currentTime = 0;

  BacterialGrowthNotifier(this._firestoreService, this._auth) : super(BacterialGrowthState()) {
    _fetchWoundData();
    _startGraph();
  }

  /// Fetch wound data from Firestore and update state
  Future<void> _fetchWoundData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      Wound? woundData = await _firestoreService.getWound(user.uid);
      if (woundData != null) {
        _updateWoundState(woundData.cfu ?? 0);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: "Error fetching wound data: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Periodically updates bacterial growth data (simulated)
  void _startGraph() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final randomGrowth = Random().nextDouble() * 50;
      _currentTime += 1;

      _updateWoundState(randomGrowth);

      final newDataPoint = BacterialGrowth(
        time: _currentTime,
        growthRate: randomGrowth,
        woundState: state.currentState,
      );

      final updatedDataPoints = List<BacterialGrowth>.from(state.dataPoints)..add(newDataPoint);
      if (updatedDataPoints.length > 30) updatedDataPoints.removeAt(0);

      state = state.copyWith(dataPoints: updatedDataPoints);
    });
  }

  void _updateWoundState(double growth) {
    String newState = _getWoundState(growth);
    if (state.currentState != newState || state.cfu != growth) {
      state = state.copyWith(
        currentState: newState,
        woundStateColor: _getWoundStateColor(newState),
        cfu: growth,
      );
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
    state = BacterialGrowthState();
  }
}
