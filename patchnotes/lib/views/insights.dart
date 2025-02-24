import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patchnotes/providers/bg_provider.dart';
import '../widgets/top_navbar.dart';
import '../utils/testImage.dart';

class InsightsView extends ConsumerWidget {
  const InsightsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final growthState = ref.watch(bacterialGrowthProvider);

    return Scaffold(
      appBar: const Header(title: "Insights"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusContainer(growthState.currentState),
                const SizedBox(height: 20),
                _buildSectionTitle('Most Recent Wound Images'),
                const SizedBox(height: 20),
                _buildImageGrid(),
                const SizedBox(height: 24),
                _buildTipContainer(growthState.currentState),
                const SizedBox(height: 24),
                _buildLastSyncedInfo(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusContainer(String state) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusMessage(state),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildImageGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const RandomWoundImageWidget(),
          );
        },
      ),
    );
  }

  Widget _buildTipContainer(String state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _getTip(state),
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLastSyncedInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'Last synced: ${_formatDateTime(DateTime.now())}',
        style: const TextStyle(fontSize: 14, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getStatusMessage(String state) {
    switch (state) {
      case 'Healthy':
        return 'Status: Your wound is healing well. Good Job!';
      case 'Observation':
        return 'Status: Your wound needs monitoring. Keep an eye on it!';
      case 'Early':
        return 'Status: Your wound shows signs of infection. Take action!';
      case 'Severe':
        return 'Status: Your wound is severely infected. Seek medical advice!';
      case 'Critical':
        return 'Status: Your wound is critical. Visit a healthcare provider ASAP!';
      default:
        return 'Status: Unknown wound status.';
    }
  }

  String _getTip(String state) {
    switch (state) {
      case 'Healthy':
        return 'Tip: Keep the wound clean and moisturized.';
      case 'Observation':
        return 'Tip: Ensure the wound is properly dressed.';
      case 'Early':
        return 'Tip: Clean the wound with an antiseptic and monitor it closely.';
      case 'Severe':
        return 'Tip: Consult a healthcare professional for immediate attention.';
      case 'Critical':
        return 'Tip: Seek emergency medical care immediately!';
      default:
        return 'Tip: Unknown advice.';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatMonth(dateTime.month)} ${dateTime.day}, ${dateTime.year}, ${_formatTime(dateTime)}';
  }

  String _formatMonth(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
