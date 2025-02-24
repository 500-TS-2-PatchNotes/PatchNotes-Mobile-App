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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const Header(title: "Insights"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusContainer(growthState.currentState, theme),
                const SizedBox(height: 20),
                _buildSectionTitle('Most Recent Wound Images', theme),
                const SizedBox(height: 20),
                _buildImageGrid(theme),
                const SizedBox(height: 24),
                _buildTipContainer(growthState.currentState, theme),
                const SizedBox(height: 24),
                _buildLastSyncedInfo(theme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusContainer(String state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStateBackgroundColor(state, theme),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusMessage(state),
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
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildImageGrid(ThemeData theme) {
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
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const RandomWoundImageWidget(),
          );
        },
      ),
    );
  }

  Widget _buildTipContainer(String state, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _getTip(state),
          style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLastSyncedInfo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'Last synced: ${_formatDateTime(DateTime.now())}',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getStatusMessage(String state) {
    switch (state) {
      case 'Healthy':
        return 'Status: Your wound is healing well. Good job!';
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

  Color _getStateBackgroundColor(String state, ThemeData theme) {
    switch (state) {
      case 'Healthy':
        return Colors.cyan.withOpacity(0.2);
      case 'Observation':
        return Colors.amber.withOpacity(0.2);
      case 'Early':
        return Colors.orange.withOpacity(0.2);
      case 'Severe':
        return Colors.red.withOpacity(0.2);
      case 'Critical':
        return Colors.purple.withOpacity(0.2);
      default:
        return theme.colorScheme.surface.withOpacity(0.2);
    }
  }
}
