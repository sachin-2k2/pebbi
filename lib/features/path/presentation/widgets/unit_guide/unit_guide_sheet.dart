import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/layout/adaptive_sheet.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../settings/presentation/providers/app_settings_provider.dart';
import '../../../domain/guide_phrase.dart';
import '../../providers/unit_guide_player_provider.dart';
import '../../providers/unit_guide_provider.dart';
import 'unit_guide_content.dart';
import 'unit_guide_player_overlay.dart';
import 'unit_guide_skeleton.dart';
import 'unit_guide_unavailable.dart';

/// Entry sheet orchestrating the guidebook presentation and playback controls.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines, traps focus,
/// supports Escape dismiss, and manages audio lifecycle interruptions.
class UnitGuideSheet extends ConsumerStatefulWidget {
  const UnitGuideSheet({super.key, required this.unitId});

  final String unitId;
  static final Map<String, double> _savedScrollOffsets = {};

  @visibleForTesting
  static void clearSavedScrollOffsets() => _savedScrollOffsets.clear();

  static Future<void> show(
    BuildContext context, {
    required String unitId,
    FocusNode? returnFocusNode,
  }) async {
    await AdaptiveSheet.show<void>(
      context: context,
      maxWidth: AppSpacing.maxDialogWidth,
      builder: (ctx) => UnitGuideSheet(unitId: unitId),
    );
    returnFocusNode?.requestFocus();
  }

  @override
  ConsumerState<UnitGuideSheet> createState() => _UnitGuideSheetState();
}

class _UnitGuideSheetState extends ConsumerState<UnitGuideSheet>
    with WidgetsBindingObserver {
  late final ScrollController _scrollController;
  late final UnitGuidePlayer _player;

  @override
  void initState() {
    super.initState();
    _player = ref.read(unitGuidePlayerProvider.notifier);
    final offset = UnitGuideSheet._savedScrollOffsets[widget.unitId] ?? 0.0;
    _scrollController = ScrollController(initialScrollOffset: offset)
      ..addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      UnitGuideSheet._savedScrollOffsets[widget.unitId] =
          _scrollController.offset;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _player.interrupt();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _player.cancelPlayback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guideAsync = ref.watch(unitGuideProvider(widget.unitId));
    final player = ref.watch(unitGuidePlayerProvider);
    final showHelper = ref.watch(
      appSettingsProvider.select((s) => s.showHelperLine),
    );
    final reduceMotion = ref.watch(
      appSettingsProvider.select((s) => s.reduceMotion),
    );
    final pop = Navigator.of(context).pop;

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): pop},
      child: FocusScope(
        autofocus: true,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.88,
          child: Material(
            color: context.palette.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
            child: Stack(
              children: [
                guideAsync.when(
                  loading: () => const UnitGuideSkeleton(),
                  error: (_, _) => UnitGuideUnavailable(onClosePressed: pop),
                  data: (guide) => guide == null
                      ? UnitGuideUnavailable(onClosePressed: pop)
                      : UnitGuideContent(
                          guide: guide,
                          playerState: player,
                          scrollController: _scrollController,
                          showHelperLine: showHelper,
                          reduceMotion: reduceMotion,
                          onClosePressed: pop,
                          onListenPressed: () =>
                              _handleListen(guide.keyPhrases),
                          onPhraseTap: _handlePhraseTap,
                        ),
                ),
                if (player.isPlaying &&
                    !player.isSinglePhrase &&
                    player.currentPhrase != null)
                  UnitGuidePlayerOverlay(
                    phrase: player.currentPhrase!,
                    currentIndex: player.currentIndex,
                    totalPhrases: guideAsync.valueOrNull?.keyPhrases.length ?? 0,
                    onStopPressed: () => _player.stop(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleListen(List<GuidePhrase> phrases) =>
      ref.read(unitGuidePlayerProvider).isPlaying
          ? _player.stop()
          : _player.playUnit(phrases);

  void _handlePhraseTap(GuidePhrase phrase) => _player.playSinglePhrase(phrase);
}
