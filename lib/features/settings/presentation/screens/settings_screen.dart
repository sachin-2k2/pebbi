import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// App Settings screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings Screen', style: AppTypography.screenTitle),
      ),
    );
  }
}
