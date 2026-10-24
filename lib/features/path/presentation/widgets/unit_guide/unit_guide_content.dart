import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/guide_phrase.dart';
import '../../../domain/unit_guide.dart';
import '../../providers/unit_guide_player_provider.dart';
import 'guide_auto_follow.dart';
import 'guide_notes_section.dart';
import 'guide_phrase_list.dart';
import 'listen_unit_button.dart';
import 'unit_guide_header.dart';

/// Scrollable body for the unit guidebook assembling header, phrases, and notes.
///
/// Follows AGENTS.md §3 & §4: composed child widgets, under 150 lines, build under 50 lines.
class UnitGuideContent extends StatefulWidget {
  const UnitGuideContent({
    super.key,
    required this.guide,
    required this.playerState,
    required this.scrollController,
    required this.onListenPressed,
    required this.onPhraseTap,
    required this.onClosePressed,
    this.showHelperLine = false,
    this.reduceMotion = false,
  });

  final UnitGuide guide;
  final UnitGuidePlayerState playerState;
  final ScrollController scrollController;
  final VoidCallback onListenPressed;
  final ValueChanged<GuidePhrase> onPhraseTap;
  final VoidCallback onClosePressed;
  final bool showHelperLine;
  final bool reduceMotion;

  @override
  State<UnitGuideContent> createState() => _UnitGuideContentState();
}

class _UnitGuideContentState extends State<UnitGuideContent> {
  final Map<String, GlobalKey> _rowKeys = {};
  bool _userScrolledManually = false;
  String? _lastAnnouncedPhraseId;

  @override
  void initState() {
    super.initState();
    _initRowKeys();
  }

  @override
  void didUpdateWidget(UnitGuideContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.guide.keyPhrases != widget.guide.keyPhrases) {
      _initRowKeys();
    }
    _handlePlaybackStateChange(oldWidget.playerState, widget.playerState);
  }

  void _initRowKeys() {
    _rowKeys.clear();
    for (final phrase in widget.guide.keyPhrases) {
      _rowKeys[phrase.id] = GlobalKey();
    }
  }

  void _handlePlaybackStateChange(
    UnitGuidePlayerState oldState,
    UnitGuidePlayerState newState,
  ) {
    if (!oldState.isPlaying && newState.isPlaying) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        AppStrings.playbackStartedAnnouncement,
        Directionality.of(context),
      );
    } else if (oldState.isPlaying && !newState.isPlaying) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        AppStrings.playbackCompletedAnnouncement,
        Directionality.of(context),
      );
    }

    final currentId = newState.playingPhraseId;
    if (currentId != null && currentId != _lastAnnouncedPhraseId) {
      _lastAnnouncedPhraseId = currentId;
      final key = _rowKeys[currentId];
      if (key != null) {
        GuideAutoFollow.followRow(
          rowKey: key,
          scrollController: widget.scrollController,
          userScrolledManually: _userScrolledManually,
          reduceMotion: widget.reduceMotion,
          onResumeFollowing: () => _userScrolledManually = false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        if (notification.direction != ScrollDirection.idle) {
          _userScrolledManually = true;
        }
        return false;
      },
      child: ListView(
        key: PageStorageKey<String>('unit_guide_scroll_${widget.guide.unitId}'),
        controller: widget.scrollController,
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.sm,
          bottom: 96.0,
        ),
        children: [
          UnitGuideHeader(
            title: widget.guide.title,
            onClosePressed: widget.onClosePressed,
          ),
          if (widget.guide.hasKeyPhrases) ...[
            const SizedBox(height: AppSpacing.md),
            ListenUnitButton(
              isPlaying: widget.playerState.isPlaying,
              phraseCount: widget.guide.keyPhrases.length,
              onPressed: widget.onListenPressed,
            ),
          ],
          GuidePhraseList(
            phrases: widget.guide.keyPhrases,
            playingPhraseId: widget.playerState.playingPhraseId,
            rowKeys: _rowKeys,
            showHelperLine: widget.showHelperLine,
            onPhraseTap: widget.onPhraseTap,
          ),
          GuideNotesSection(notes: widget.guide.notes),
        ],
      ),
    );
  }
}
