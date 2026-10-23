import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/conversation_state.dart';
import '../../domain/session_config.dart';
import '../providers/mission_session_provider.dart';
import '../widgets/session/session_screen_content.dart';
import '../widgets/session/session_unavailable_view.dart';
import 'mission_session_actions.dart';

/// Full-page Role-Play Session screen in Chat mode.
///
/// Follows AGENTS.md §3 (< 100 lines target) & §4 (adaptive layout).
class MissionSessionScreen extends ConsumerStatefulWidget {
  const MissionSessionScreen({super.key, required this.config});

  final SessionConfig config;

  @override
  ConsumerState<MissionSessionScreen> createState() => _MissionSessionScreenState();
}

class _MissionSessionScreenState extends ConsumerState<MissionSessionScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  String _resolveLanguageName(String code) {
    switch (code) {
      case 'fr':
        return 'French';
      case 'es':
        return 'Spanish';
      case 'de':
        return 'German';
      case 'ja':
        return 'Japanese';
      case 'ar':
        return 'Arabic';
      default:
        return 'French';
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final state = ref.watch(missionSessionNotifierProvider(widget.config));
    final notifier = ref.read(missionSessionNotifierProvider(widget.config).notifier);
    final isOffline = ref.watch(missionSessionIsOfflineProvider);
    final languageName = _resolveLanguageName(widget.config.targetLanguageCode);

    ref.listen(missionSessionNotifierProvider(widget.config), (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await MissionSessionActions.handlePop(context);
        if (leave && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: palette.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: state.status == ConversationStatus.unavailable
              ? SessionUnavailableView(targetLanguageName: languageName)
              : SessionScreenContent(
                  state: state,
                  notifier: notifier,
                  config: widget.config,
                  targetLanguageName: languageName,
                  scrollController: _scrollController,
                  textController: _textController,
                  isOffline: isOffline,
                ),
        ),
      ),
    );
  }
}
