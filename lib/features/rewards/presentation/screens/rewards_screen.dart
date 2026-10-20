import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Gamification and Rewards screen.
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Rewards Screen', style: AppTypography.screenTitle),
      ),
    );
  }
}
