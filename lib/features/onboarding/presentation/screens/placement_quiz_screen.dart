import 'package:flutter/material.dart';
import '../../../lesson/presentation/screens/exercise_screen.dart';

/// Interactive Placement Quiz screen presenting the exact pre-existing exercise design.
///
/// Follows AGENTS.md §3 & §4: under 50 lines, responsive constraints,
/// delegates cleanly to [ExerciseScreen].
class PlacementQuizScreen extends StatelessWidget {
  const PlacementQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseScreen(
      finishRoute: '/onboarding/placement-results',
    );
  }
}
