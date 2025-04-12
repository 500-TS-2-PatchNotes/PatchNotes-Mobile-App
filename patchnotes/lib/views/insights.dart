import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patchnotes/providers/calibration_provider.dart';
import 'package:patchnotes/providers/navigation.dart';
import 'package:patchnotes/providers/user_provider.dart';
import 'package:patchnotes/utils/insights_helper.dart';
import '../widgets/top_navbar.dart';

class InsightsView extends ConsumerStatefulWidget {
  const InsightsView({Key? key}) : super(key: key);

  @override
  _InsightsViewState createState() => _InsightsViewState();
}

class _InsightsViewState extends ConsumerState<InsightsView> {
  final Map<int, bool> _showOverlayMap = {};

  Stream<List<Map<String, dynamic>>> getWoundDataStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wound_data')
        .where(FieldPath.documentId, isNotEqualTo: 'info')
        .orderBy('analyze_time', descending: true)
        .limit(9)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  List<Map<String, dynamic>> recentDocs = [];
  bool isLoading = true;
  bool _hasFetched = false;

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(userProvider).uid;
    final wound = ref.watch(userProvider).wound;
    final woundStatus = wound?.woundStatus ?? 'Unknown';
    final woundTip = wound?.insightsTip ?? 'No tip available.';
    final statusMessage = wound?.insightsMessage ?? 'Status unknown.';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: uid == null
          ? const Center(child: Text("User not authenticated"))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: getWoundDataStream(uid),
              builder: (context, snapshot) {
                final docs = snapshot.data ?? [];

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStatusContainer(
                              statusMessage, woundStatus, Theme.of(context)),
                          const SizedBox(height: 20),
                          _buildSectionTitle(
                              'Most Recent Wound Images', Theme.of(context)),
                          const SizedBox(height: 20),
                          _buildImageGrid(Theme.of(context), docs),
                          const SizedBox(height: 24),
                          _buildTipContainer(woundTip, Theme.of(context)),
                          const SizedBox(height: 24),
                          _buildLastSyncedInfo(Theme.of(context)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusContainer(String message, String state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStateBackgroundColor(state),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style:
            theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildImageGrid(ThemeData theme, List<Map<String, dynamic>> docs) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final isToggled = _showOverlayMap[index] ?? false;
        final doc = index < docs.length ? docs[index] : null;
        final imageUrl = doc?['URL'];

        return GestureDetector(
          onTap: () => setState(() => _showOverlayMap[index] = !isToggled),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Container(color: theme.dividerColor),
                ),
              ),
              if (isToggled && doc != null)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: _buildOverlayInfo(theme, doc),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipContainer(String tip, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          tip,
          style:
              theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLastSyncedInfo(ThemeData theme) {
    final now = DateTime.now();
    final formattedDate =
        '${now.month}/${now.day}/${now.year} at ${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'Last synced: $formattedDate',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOverlayInfo(ThemeData theme, Map<String, dynamic> doc) {
    final calibration = ref.read(calibrationStreamProvider).value ?? [];
    final level = (doc['level'] ?? 0.0).toDouble();
    final estimatedCFU = estimateCFUFromLevel(calibration, level);
    final state = getWoundStateFromCFU(calibration, estimatedCFU);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Lvl: ${level.toStringAsFixed(2)}",
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text("CFU: ${estimatedCFU.toStringAsExponential(1)}",
            style: theme.textTheme.titleSmall),
        Text("State: $state",
            style: theme.textTheme.titleSmall
                ?.copyWith(color: getStateColor(state))),
      ],
    );
  }


  Future<void> fetchRecentWoundData() async {
    final uid = ref.read(userProvider).uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wound_data')
        .where(FieldPath.documentId, isNotEqualTo: 'info')
        .orderBy('imageTimestamp', descending: true)
        .limit(9)
        .get();

    final docs = snapshot.docs.map((doc) => doc.data()).toList();

    debugPrint("Fetched ${docs.length} wound_data docs:");
    for (final doc in docs) {
      debugPrint(" - ${doc['URL']} | Level: ${doc['level']}");
    }

    setState(() {
      recentDocs = docs;
      isLoading = false;
    });
  }

  Color _getStateBackgroundColor(String state) {
    switch (state) {
      case 'Healthy':
        return Colors.cyan.withOpacity(0.2);
      case 'Monitor Needed':
        return Colors.orange.withOpacity(0.2);
      case 'Unhealthy':
        return Colors.purple.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Color getStateColor(String state) {
    switch (state) {
      case 'Healthy':
        return Colors.green;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
