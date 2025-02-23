import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ Global Navigator Key Provider
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

// ✅ Tab Index Provider (Manages Bottom Navigation State)
final tabIndexProvider = StateProvider<int>((ref) => 0);
