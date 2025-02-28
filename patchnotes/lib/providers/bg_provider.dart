import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:patchnotes/providers/auth_provider.dart';
import 'package:patchnotes/providers/user_provider.dart';
import 'package:patchnotes/services/firestore_service.dart';
import 'package:patchnotes/models/bacterial_growth.dart';
import 'package:patchnotes/models/collections/wound.dart';
import 'package:patchnotes/states/bg_state.dart';

// Firestore Service Provider
final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

// Bacterial Growth Provider
final bacterialGrowthProvider =
    StateNotifierProvider<BacterialGrowthNotifier, BacterialGrowthState>((ref) {
  final authState = ref.watch(authStateProvider).asData?.value;
  final user = authState;
  return BacterialGrowthNotifier(
    ref.read(firestoreServiceProvider),
    ref.read(firebaseAuthProvider),
    user?.uid,
  );
});

class BacterialGrowthNotifier extends StateNotifier<BacterialGrowthState> {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;
  final String? uid;
  Timer? _timer;
  double _currentTime = 0;

  BacterialGrowthNotifier(
    this._firestoreService,
    this._auth,
    this.uid,
  ) : super(BacterialGrowthState()) {
    if (uid != null) {
      _fetchWoundData();
    }
    _startGraph();
  }

  Future<void> _fetchWoundData() async {
    final user = _auth.currentUser;
    if (user == null || !mounted) return;

    state = state.copyWith(isLoading: true);

    try {
      Wound? woundData = await _firestoreService.getWound(user.uid);
      if (!mounted) return;

      if (woundData != null) {
        _currentTime = woundData.imageTimestamp?.seconds.toDouble() ??
            0;
        double lastCfu = woundData.cfu ?? 0;
        state = state.copyWith(
          cfu: lastCfu,
          currentState: _getWoundState(lastCfu),
          woundStateColor: _getWoundStateColor(_getWoundState(lastCfu)),
        );

        final newDataPoint = BacterialGrowth(
          time: _currentTime,
          growthRate: lastCfu,
          woundState: _getWoundState(lastCfu),
        );

        state = state.copyWith(dataPoints: [...state.dataPoints, newDataPoint]);
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(errorMessage: "Error fetching wound data: $e");
    } finally {
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    }
  }

  void _startGraph() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final randomGrowth = Random().nextDouble() * 50;
      _currentTime += 1;

      await _updateWoundState(randomGrowth);

      final newDataPoint = BacterialGrowth(
        time: _currentTime,
        growthRate: randomGrowth,
        woundState: state.currentState,
      );

      final updatedDataPoints = List<BacterialGrowth>.from(state.dataPoints)
        ..add(newDataPoint);
      if (updatedDataPoints.length > 30) {
        updatedDataPoints.removeAt(0);
      }

      // Remap the x-values to be the index of each point.
      final remappedDataPoints = List.generate(updatedDataPoints.length, (i) {
        return updatedDataPoints[i].copyWith(time: i.toDouble());
      });

      state = state.copyWith(dataPoints: remappedDataPoints);
    });
  }

  void _updateGraph() {
    final randomGrowth = Random().nextDouble() * 50;
    _currentTime += 1;
    _updateWoundState(randomGrowth);

    final newDataPoint = BacterialGrowth(
      time: _currentTime,
      growthRate: randomGrowth,
      woundState: state.currentState,
    );

    final updatedDataPoints = List<BacterialGrowth>.from(state.dataPoints)
      ..add(newDataPoint);
    if (updatedDataPoints.length > 30) {
      updatedDataPoints.removeAt(0);
    }

    // Remap each data point's time to its index.
    final remappedDataPoints = List.generate(updatedDataPoints.length, (i) {
      return updatedDataPoints[i].copyWith(time: i.toDouble());
    });

    state = state.copyWith(dataPoints: remappedDataPoints);
  }

  void pauseGraph() {
    _timer?.cancel();
    _timer = null;
  }

  /// Resume the graph simulation from the current state.
  void resumeGraph() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateGraph();
    });
  }

  Future<void> _updateWoundState(double growth) async {
    if (!mounted) return;

    String newState = _getWoundState(growth);

    // Only update if the state or cfu value changed.
    if (state.currentState != newState || state.cfu != growth) {
      // Update local state.
      state = state.copyWith(
        currentState: newState,
        woundStateColor: _getWoundStateColor(newState),
        cfu: growth,
      );

      final user = _auth.currentUser;
      if (user != null) {
        final updatedWoundData = {
          'woundStatus': newState,
          'cfu': growth,
          'lastSynced': Timestamp.now(),
          'colour': _getWoundStateColor(newState),
        };

        try {
          await _firestoreService.updateWound(user.uid, updatedWoundData);
        } catch (e) {
          state = state.copyWith(errorMessage: "Error updating wound: $e");
        }
      }
    }
  }

  String _getWoundState(double growth) {
    if (growth < 10) return 'Healthy';
    if (growth < 20) return 'Observation';
    if (growth < 30) return 'Early';
    if (growth < 40) return 'Severe';
    return 'Critical';
  }

  String _getWoundStateColor(String woundState) {
    switch (woundState) {
      case "Healthy":
        return "Green";
      case "Observation":
        return "Yellow";
      case "Early":
        return "Orange";
      case "Severe":
        return "Red";
      case "Critical":
        return "Black";
      default:
        return "Unknown";
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void reset() {
    state = BacterialGrowthState();
  }
}
