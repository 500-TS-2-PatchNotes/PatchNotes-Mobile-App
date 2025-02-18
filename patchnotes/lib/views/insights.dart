import 'package:flutter/material.dart';
import 'package:patchnotes/viewmodels/dashboard_viewmodel.dart';
import 'package:provider/provider.dart';
import '../widgets/top_navbar.dart';
import '../utils/testImage.dart';

class InsightsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final growthVM = Provider.of<BacterialGrowthViewModel>(context);
    return Scaffold(
      appBar: Header(title: "Insights"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusMessage(growthVM.currentState),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Most Recent Wound Images',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Grid of Wound Images using RandomWoundImageWidget
            Padding(
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
            ),
            const SizedBox(height: 24),

            // Tip Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTip(growthVM.currentState),
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Last Synced Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Last synced: ${_formatDateTime(DateTime.now())}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getStatusMessage(String state) {
    switch (state) {
      case 'Healthy':
        return 'Status: Your wound is healing well. Good Job!';
      case 'Observation':
        return 'Status: Your wound needs monitoring. Keep an eye on it!';
      case 'Early Infection':
        return 'Status: Your wound shows signs of infection. Take action!';
      case 'Severe Infection':
        return 'Status: Your wound is severely infected. Seek medical advice!';
      case 'Critical':
        return 'Status: Your wound is critical. Visit a healthcare provider immediately!';
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
      case 'Early Infection':
        return 'Tip: Clean the wound with an antiseptic and monitor it closely.';
      case 'Severe Infection':
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
