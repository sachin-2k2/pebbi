import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/notice_banner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/mission_access_rules.dart';
import '../../domain/mission_summary.dart';
import '../providers/missions_provider.dart';
import 'category_chip_row.dart';
import 'mission_list.dart';
import 'missions_header.dart';
import 'missions_section_title.dart';
import 'quick_action_row.dart';
import 'today_mission_card.dart';

/// Single-column scrolling layout for Compact and Medium window classes.
class MissionsCompactLayout extends ConsumerWidget {
  const MissionsCompactLayout({super.key});

  void _handleMissionTap(
    BuildContext context,
    MissionSummary mission,
    WidgetRef ref,
    bool isOffline,
  ) {
    final user = ref.read(currentUserProvider);
    final access = MissionAccessRules.missionAccess(user, mission);

    if (access == MissionAccessResult.needsPremium) {
      context.push('/premium/options');
      return;
    }

    if (isOffline) {
      _showNeedsInternetDialog(context);
      return;
    }

    context.push('/missions/brief/${mission.id}');
  }

  void _showNeedsInternetDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text(AppStrings.offlineMissionBlockedTitle),
        content: const Text(AppStrings.offlineMissionBlockedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsState = ref.watch(missionsStateProvider);
    final selectedCategory = ref.watch(selectedMissionCategoryProvider);
    final filteredMissions = ref.watch(filteredMissionsProvider);
    final visibleCategories = ref.watch(visibleCategoriesProvider);
    final userProfile = ref.watch(currentUserProvider);

    return missionsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading situations: $err'),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.refresh(missionsStateProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (state) {
        final today = state.todayMission;

        return ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl + 48.0),
          children: [
            if (state.isOffline) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: NoticeBanner(
                  message: AppStrings.offlineBannerNotice,
                  icon: Icon(
                    Icons.wifi_off_rounded,
                    color: AppColors.noticeWarningText,
                    size: 20.0,
                  ),
                ),
              ),
            ],
            const MissionsHeader(),
            if (today != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TodayMissionCard(
                  todayMission: today,
                  onTap: () {
                    if (state.isOffline) {
                      _showNeedsInternetDialog(context);
                    } else {
                      context.push('/missions/brief/${today.mission.id}');
                    }
                  },
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: QuickActionRow(
                onEmergencyTap: () =>
                    context.push('/missions/emergency-phrasebook'),
                onFreeTalkTap: () {
                  if (state.isOffline) {
                    _showNeedsInternetDialog(context);
                  } else {
                    context.push('/missions/free-talk');
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const MissionsSectionTitle(),
            const SizedBox(height: AppSpacing.xs),
            CategoryChipRow(
              categories: visibleCategories,
              selectedCategoryId: selectedCategory,
              matchingMissionsCount: filteredMissions.length,
              onCategorySelected: (id) =>
                  ref.read(selectedMissionCategoryProvider.notifier).state = id,
            ),
            const SizedBox(height: AppSpacing.sm),
            MissionList(
              missions: filteredMissions,
              userProfile: userProfile,
              onMissionTap: (m) =>
                  _handleMissionTap(context, m, ref, state.isOffline),
            ),
          ],
        );
      },
    );
  }
}
