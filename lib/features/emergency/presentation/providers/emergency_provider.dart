import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/bundled_emergency_repository.dart';
import '../../data/remote_emergency_repository.dart';
import '../../domain/emergency_phrasebook.dart';
import '../../domain/emergency_repository.dart';

/// Provider for the [EmergencyRepository] instance.
final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final user = ref.watch(currentUserProvider);
  return RemoteEmergencyRepository(
    apiClient: apiClient,
    fallbackRepository: BundledEmergencyRepository(),
    explanationLanguageCode: user?.explanationLanguageCode ?? 'en',
  );
});

/// Target language code for emergency phrases.
final emergencyTargetLanguageProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.targetLanguageCode ?? 'es';
});

/// Explanation language code used for meaning labels (with English fallback).
final emergencyExplanationLanguageProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.explanationLanguageCode ?? 'en';
});

/// Whether the phonetic helper line setting is enabled.
final emergencyShowHelperLineProvider = StateProvider<bool>((ref) => false);

/// Async provider for the active [EmergencyPhrasebook] model.
final emergencyPhrasebookProvider = FutureProvider<EmergencyPhrasebook?>((
  ref,
) async {
  final repository = ref.watch(emergencyRepositoryProvider);
  final targetLanguage = ref.watch(emergencyTargetLanguageProvider);

  return repository.getPhrasebook(targetLanguageCode: targetLanguage);
});
