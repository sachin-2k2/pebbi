import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_mode.dart';
import '../../data/mock_placement_repository.dart';
import '../../data/remote_placement_repository.dart';
import '../../domain/placement_repository.dart';

/// Provider for the active [PlacementRepository].
///
/// Follows AGENTS.md §2.3: Injects [RemotePlacementRepository] when
/// [ApiConfig.placementApiMode] is `ApiMode.real`, otherwise [MockPlacementRepository].
final placementRepositoryProvider = Provider<PlacementRepository>((ref) {
  final config = ApiConfig.instance;

  if (config.placementApiMode == ApiMode.real) {
    final client = ref.watch(apiClientProvider);
    return RemotePlacementRepository(apiClient: client);
  }

  return const MockPlacementRepository();
});
