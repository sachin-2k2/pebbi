import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';

/// Loading indicator scaffold while lesson questions or placement are prepared.
///
/// Follows AGENTS.md §3 & §4: under 60 lines, build under 40 lines.
class ExerciseLoadingView extends StatelessWidget {
  const ExerciseLoadingView({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: palette.textPrimary),
          onPressed: onClose,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: palette.brand),
            const SizedBox(height: 20),
            Text(
              'Preparing your lesson...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'First time generation may take a moment',
              style: TextStyle(fontSize: 13, color: palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

