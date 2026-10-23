import 'package:flutter/material.dart';
import '../../../../../core/design_system/notice_banner.dart';
import '../../../../../l10n/app_strings.dart';

/// Informational safety notice explaining the AI character scope and privacy guarantee.
///
/// Follows AGENTS.md §3 & §7.3:
/// - Reuses [NoticeBanner] with semantic [NoticeBannerTone.info]
/// - WCAG AAA compliant text contrast in light and dark modes
class BriefSafetyNotice extends StatelessWidget {
  const BriefSafetyNotice({super.key, this.noticeText});

  final String? noticeText;

  @override
  Widget build(BuildContext context) {
    return NoticeBanner(
      tone: NoticeBannerTone.info,
      message: noticeText ?? AppStrings.missionSafetyNotice,
      icon: const ExcludeSemantics(
        child: Text(
          '💡',
          style: TextStyle(fontSize: 16.0),
          textScaler: TextScaler.noScaling,
        ),
      ),
    );
  }
}
