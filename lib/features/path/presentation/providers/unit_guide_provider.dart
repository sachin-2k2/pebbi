import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/mock_unit_guide_repository.dart';
import '../../domain/unit_guide.dart';
import '../../domain/unit_guide_repository.dart';

/// Provider exposing the [UnitGuideRepository] implementation.
final unitGuideRepositoryProvider = Provider<UnitGuideRepository>((ref) {
  return MockUnitGuideRepository();
});

/// Family provider loading [UnitGuide] for a given [unitId].
final unitGuideProvider = FutureProvider.autoDispose.family<UnitGuide?, String>(
  (ref, unitId) async {
    final repository = ref.watch(unitGuideRepositoryProvider);
    final user = ref.watch(currentUserProvider);

    final languageCode = user?.targetLanguageCode ?? 'fr';
    final explanationLanguageCode = user?.explanationLanguageCode ?? 'en';

    return repository.getUnitGuide(
      unitId,
      languageCode: languageCode,
      explanationLanguageCode: explanationLanguageCode,
    );
  },
);
