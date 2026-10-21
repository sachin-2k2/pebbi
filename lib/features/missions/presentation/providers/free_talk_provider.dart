import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/mock_free_talk_repository.dart';
import '../../domain/correction_style.dart';
import '../../domain/free_talk_repository.dart';
import '../../domain/free_talk_topic.dart';

/// Provider for the [FreeTalkRepository] instance.
final freeTalkRepositoryProvider = Provider<FreeTalkRepository>((ref) {
  return MockFreeTalkRepository();
});

/// Target language code for Free Talk.
final freeTalkTargetLanguageCodeProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.targetLanguageCode ?? 'es';
});

/// Display name of the active target language (e.g. 'Spanish', 'French').
final freeTalkTargetLanguageNameProvider = Provider<String>((ref) {
  final langCode = ref.watch(freeTalkTargetLanguageCodeProvider);
  switch (langCode) {
    case 'es':
      return 'Spanish';
    case 'fr':
      return 'French';
    case 'de':
      return 'German';
    case 'ja':
      return 'Japanese';
    case 'ar':
      return 'Arabic';
    default:
      return 'Spanish';
  }
});

/// Async provider for the active Free Talk topics catalog.
final freeTalkTopicsProvider = FutureProvider<List<FreeTalkTopic>>((ref) async {
  final repository = ref.watch(freeTalkRepositoryProvider);
  final targetLang = ref.watch(freeTalkTargetLanguageCodeProvider);
  final user = ref.watch(currentUserProvider);
  final explanationLang = user?.explanationLanguageCode ?? 'en';

  return repository.getTopics(
    targetLanguageCode: targetLang,
    explanationLanguageCode: explanationLang,
  );
});

/// State notifier managing the active user's selected [CorrectionStyle].
///
/// Follows AGENTS.md §6: Watched via [currentUserProvider] to isolate preferences across accounts.
class FreeTalkCorrectionStyleNotifier extends StateNotifier<CorrectionStyle> {
  FreeTalkCorrectionStyleNotifier(this._repository, this._userId)
    : super(CorrectionStyle.gentle) {
    _loadInitial();
  }

  final FreeTalkRepository _repository;
  final String _userId;
  bool _hasUserSelected = false;

  Future<void> _loadInitial() async {
    try {
      final style = await _repository.getDefaultCorrectionStyle(
        userId: _userId,
      );
      if (mounted && !_hasUserSelected) {
        state = style;
      }
    } catch (_) {}
  }

  Future<void> selectStyle(CorrectionStyle style) async {
    _hasUserSelected = true;
    state = style;
    try {
      await _repository.saveDefaultCorrectionStyle(
        userId: _userId,
        style: style,
      );
    } catch (_) {}
  }
}

/// Provider managing the active [CorrectionStyle] setting for the current user.
final freeTalkCorrectionStyleProvider =
    StateNotifierProvider<FreeTalkCorrectionStyleNotifier, CorrectionStyle>((
      ref,
    ) {
      final repository = ref.watch(freeTalkRepositoryProvider);
      final user = ref.watch(currentUserProvider);
      final userId = user?.userId ?? 'guest_default';

      return FreeTalkCorrectionStyleNotifier(repository, userId);
    });

/// Whether simulated or device offline mode is active.
final freeTalkIsOfflineProvider = StateProvider<bool>((ref) => false);
