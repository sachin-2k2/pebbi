import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_version_info.dart';
import '../../domain/version_info.dart';

/// Riverpod provider delivering application version metadata.
final versionInfoProvider = Provider<VersionInfo>((ref) {
  return const MockVersionInfo();
});
