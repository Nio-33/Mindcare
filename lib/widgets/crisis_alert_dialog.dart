import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class CrisisAlertDialog extends StatelessWidget {
  const CrisisAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.emergency, color: AppColors.error),
          const SizedBox(width: 8),
          const Text('Immediate Help Needed'),
        ],
      ),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'We\'ve detected concerning content in your journal entry. Please reach out for immediate support:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('📞 National Suicide Prevention Lifeline'),
            Text('988 (available 24/7)', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('💬 Crisis Text Line'),
            Text('Text HOME to 741741', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('🆘 Emergency Services'),
            Text('911', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(
              'You are not alone. Help is available right now.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}