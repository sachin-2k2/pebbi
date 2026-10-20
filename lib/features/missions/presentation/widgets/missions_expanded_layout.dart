import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/layout/two_pane_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/mission_access_rules.dart';
import '../providers/missions_provider.dart';
import 'category_chip_row.dart';
import 'mission_list.dart';
import 'mission_preview_pane.dart';
import 'missions_header.dart';
import 'missions_section_title.dart';
import 'quick_action_row.dart';
import 'today_mission_card.dart';

/// Two-pane responsive layout for Expanded screens (tablets & desktop).
class MissionsExpandedLayout extends ConsumerWidget {
  const MissionsExpandedLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsState = ref.watch(missionsStateProvider);
    final selectedCategory = ref.watch(selectedMissionCategoryProvider);
    final filteredMissions = ref.watch(filteredMissionsProvider);
    final visibleCategories = ref.watch(visibleCategoriesProvider);
    final userProfile = ref.watch(currentUserProvider);
    final selectedMissionId = ref.watch(selectedMissionForPreviewProvider);

    return missionsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (state) {
        final today = state.todayMission;
        final selectedMission = state.missions
            .where((m) => m.id == selectedMissionId)
            .firstOrNull;

        return TwoPaneLayout(
          primaryFlex: 3,
          secondaryFlex: 2,
          spacing: AppSpacing.lg,
          primaryPane: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const MissionsHeader(),
              if (today != null) ...[
                const SizedBox(height: AppSpacing.xs),
                TodayMissionCard(
                  todayMission: today,
                  onTap: () {
                    ref.read(selectedMissionForPreviewProvider.notifier).state =
                        today.mission.id;
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              QuickActionRow(
                onEmergencyTap: () =>
                    context.push('/missions/emergency-phrasebook'),
                onFreeTalkTap: () => context.push('/missions/free-talk'),
              ),
              const SizedBox(height: AppSpacing.md),
              const MissionsSectionTitle(),
              const SizedBox(height: AppSpacing.xs),
              CategoryChipRow(
                categories: visibleCategories,
                selectedCategoryId: selectedCategory,
                matchingMissionsCount: filteredMissions.length,
                onCategorySelected: (id) =>
                    ref.read(selectedMissionCategoryProvider.notifier).state =
                        id,
              ),
              const SizedBox(height: AppSpacing.sm),
              MissionList(
                missions: filteredMissions,
                userProfile: userProfile,
                onMissionTap: (m) {
                  final access = MissionAccessRules.missionAccess(
                    userProfile,
                    m,
                  );
                  if (access == MissionAccessResult.needsPremium) {
                    context.push('/premium/options');
                  } else {
                    ref.read(selectedMissionForPreviewProvider.notifier).state =
                        m.id;
                  }
                },
              ),
            ],
          ),
          secondaryPane: MissionPreviewPane(
            selectedMission: selectedMission,
            onStartMission: (m) => context.push('/missions/brief/${m.id}'),
          ),
        );
      },
    );
  }
}
