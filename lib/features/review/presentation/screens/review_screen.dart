import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Spaced repetition Review screen.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Review Screen', style: AppTypography.screenTitle),
      ),
    );
  }
}
