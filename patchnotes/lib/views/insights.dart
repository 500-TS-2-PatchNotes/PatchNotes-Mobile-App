import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patchnotes/providers/user_provider.dart';
import '../widgets/top_navbar.dart';

class InsightsView extends ConsumerWidget {
  const InsightsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userState = ref.watch(userProvider);
    final wound = userState.wound;

    final images = wound?.woundImages ?? [];
    final woundStatus = wound?.woundStatus ?? 'Unknown';
    final woundTip = wound?.insightsTip ?? 'No tip available.';
    final statusMessage = wound?.insightsMessage ?? 'Status unknown.';

    return Scaffold(
      appBar: const Header(title: "Insights"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusContainer(statusMessage, woundStatus, theme),
                const SizedBox(height: 20),
                _buildSectionTitle('Most Recent Wound Images', theme),
                const SizedBox(height: 20),
                _buildImageGrid(theme, images),
                const SizedBox(height: 24),
                _buildTipContainer(woundTip, theme),
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

  Widget _buildImageGrid(ThemeData theme, List<String> images) {
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
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          if (index < images.length) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
                color: theme.cardColor,
              ),
            );
          }
        },
      ),
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
}
